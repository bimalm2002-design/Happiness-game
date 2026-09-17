extends RigidBody3D

signal dice_roll_finished(value: int)

enum State { IDLE, ANTICIPATION, AIRBORNE, SETTLING, SHOW_VALUE, RESULT }
var current_state = State.IDLE

@export_group("Physics Tuning")
@export_range(1.0, 5.0) var custom_mass: float = 3.0 # Make it feel like solid resin/plastic
@export_range(0.0, 0.3) var custom_linear_damp: float = 0.0 # Remove air resistance so it falls fast
@export_range(0.0, 0.6) var custom_angular_damp: float = 0.1
@export_range(1.0, 10.0) var custom_gravity_scale: float = 6.0 # Fall extremely fast to avoid "feather" effect

@export_group("Throw Parameters")
@export_range(0.0, 5.0) var initial_vertical_vel: float = 1.0 # Barely pop up, just fall and roll
@export_range(1.0, 10.0) var horizontal_vel_multiplier: float = 3.0
@export_range(1.0, 5.0) var initial_horizontal_vel_max: float = 3.0
@export_range(15.0, 30.0) var angular_vel_multiplier: float = 20.0

@export_group("Settle Thresholds")
@export var pre_settle_linear_vel: float = 1.5
@export var pre_settle_angular_vel: float = 4.0
@export var settle_tween_duration: float = 0.35

@export_group("Face Mapping")
# You can change these vectors in the Godot Inspector to match your 3D model!
@export var face_up_normals: Dictionary = {
	1: Vector3(0, 1, 0),
	6: Vector3(0, -1, 0),
	2: Vector3(0, 0, 1),
	5: Vector3(0, 0, -1),
	3: Vector3(1, 0, 0),
	4: Vector3(-1, 0, 0)
}

var predetermined_result: int = 1
var time_in_airborne: float = 0.0
var bounce_count: int = 0
var input_history = []
var game_manager: Node = null
var in_hand_pos: Vector3 = Vector3.ZERO

var _pending_launch: bool = false
var _launch_linear_vel: Vector3 = Vector3.ZERO
var _launch_angular_vel: Vector3 = Vector3.ZERO
var _nudge_tween: Tween = null

func _ready():
	randomize()
	mass = custom_mass
	linear_damp = custom_linear_damp
	angular_damp = custom_angular_damp
	gravity_scale = custom_gravity_scale
	
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	
	if not physics_material_override:
		physics_material_override = PhysicsMaterial.new()
		physics_material_override.bounce = 0.35
		physics_material_override.friction = 0.7
		
	# Delay reset slightly to ensure camera is ready
	call_deferred("reset_dice")

func _on_body_entered(body):
	bounce_count += 1

func get_camera_basis() -> Basis:
	if game_manager == null:
		game_manager = get_node_or_null("../GameManager")
	if game_manager and game_manager.has_node("../MainCamera"):
		var cam = game_manager.get_node("../MainCamera")
		if cam:
			return cam.global_transform.basis
	return Basis()

func get_camera_pos() -> Vector3:
	if game_manager == null:
		game_manager = get_node_or_null("../GameManager")
	if game_manager and game_manager.has_node("../MainCamera"):
		var cam = game_manager.get_node("../MainCamera")
		if cam:
			return cam.global_position
	return Vector3(0, 22, 22)

func reset_dice():
	current_state = State.IDLE
	freeze = true
	
	var cam_pos = get_camera_pos()
	if cam_pos.y > 20: # Overview mode (Top-down plan view)
		# Place dice at fixed position above the center of the board
		# Lowered from Y=10 but raised from Y=4 to Y=7.5 to give a satisfying drop height
		in_hand_pos = Vector3(0, 7.5, 0)
	else:
		var cam_basis = get_camera_basis()
		var cam_forward = -cam_basis.z
		in_hand_pos = cam_pos + (cam_forward * 1.6)
		in_hand_pos -= cam_basis.y * 0.4 # Slightly lower than center
	
	global_position = in_hand_pos
	scale = Vector3(1, 1, 1) # Reset any scale to prevent physics bugs
	rotation_degrees = Vector3(randf_range(0, 360), randf_range(0, 360), randf_range(0, 360))

func _unhandled_input(event):
	if current_state != State.IDLE and current_state != State.ANTICIPATION:
		return
		
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or event is InputEventScreenTouch:
		if event.pressed:
			current_state = State.ANTICIPATION
			input_history.clear()
			input_history.append({"pos": event.position, "time": Time.get_ticks_msec()})
			freeze = true
		elif not event.pressed:
			if current_state == State.ANTICIPATION:
				throw_dice()
				
	elif (event is InputEventMouseMotion or event is InputEventScreenDrag) and current_state == State.ANTICIPATION:
		input_history.append({"pos": event.position, "time": Time.get_ticks_msec()})
		if input_history.size() > 20:
			input_history.pop_front()

func _physics_process(delta):
	match current_state:
		State.ANTICIPATION:
			if input_history.size() > 0:
				var current_screen_pos = input_history[-1]["pos"]
				var start_screen_pos = input_history[0]["pos"]
				var delta_screen = current_screen_pos - start_screen_pos
				
				var cam_basis = get_camera_basis()
				var right = cam_basis.x
				var up = cam_basis.y
				
				# Move dice slightly relative to the screen drag
				var drag_offset = (right * delta_screen.x + -up * delta_screen.y) * 0.015
				if drag_offset.length() > 6.0:
					drag_offset = drag_offset.normalized() * 6.0
					
				global_position = global_position.lerp(in_hand_pos + drag_offset, delta * 15.0)
				
			rotate_x(delta * 5.0)
			rotate_y(delta * 4.0)
			rotate_z(delta * 3.0)
			
		State.AIRBORNE:
			time_in_airborne += delta
			
			if global_position.y < -1.0 or global_position.length() > 50.0:
				global_position = Vector3(0, 2, 0)
				linear_velocity = Vector3.ZERO
				start_settle_nudge()
				return
				
			if time_in_airborne > 3.5:
				start_settle_nudge()
				return
				
			if time_in_airborne < 0.35 or bounce_count == 0:
				return
				
			if linear_velocity.length() < pre_settle_linear_vel and angular_velocity.length() < pre_settle_angular_vel:
				start_settle_nudge()

func _integrate_forces(state):
	if _pending_launch:
		state.linear_velocity = _launch_linear_vel
		state.angular_velocity = _launch_angular_vel
		_pending_launch = false

func throw_dice(forced_value: int = -1):
	if forced_value == -1:
		predetermined_result = randi_range(1, 6)
	else:
		predetermined_result = forced_value
	print("Pre-determined Dice Result: ", predetermined_result)
	
	current_state = State.AIRBORNE
	time_in_airborne = 0.0
	bounce_count = 0
	scale = Vector3(1, 1, 1) # Ensure scale is strictly 1
	freeze = false
	
	var throw_vector = Vector3.ZERO
	var cam_basis = get_camera_basis()
	var cam_forward = -cam_basis.z
	cam_forward.y = 0
	cam_forward = cam_forward.normalized()
	
	if input_history.size() >= 2:
		var current_time = Time.get_ticks_msec()
		var start_point = input_history[0]
		for point in input_history:
			if current_time - point["time"] <= 100:
				start_point = point
				break
				
		var end_point = input_history[-1]
		var diff = end_point["pos"] - start_point["pos"]
		var time_diff = float(end_point["time"] - start_point["time"]) / 1000.0
		
		if time_diff > 0.01:
			var speed_px = diff / time_diff
			var cam_right = cam_basis.x
			cam_right.y = 0
			cam_right = cam_right.normalized()
			
			throw_vector = (cam_right * speed_px.x + cam_forward * (-speed_px.y)) * (horizontal_vel_multiplier * 0.005)
	
	# Guarantee a realistic, powerful throw animation even if the user swiped slowly or just clicked!
	if throw_vector.length() < 8.0:
		var throw_dir = throw_vector.normalized()
		if throw_dir.length_squared() < 0.1:
			throw_dir = cam_forward # Default to throwing forward
		throw_vector = throw_dir * 8.0
		
	if throw_vector.length() > 18.0:
		throw_vector = throw_vector.normalized() * 18.0
			
	# Add a satisfying vertical arc so it doesn't just fall straight down
	throw_vector.y = 6.0
	
	_launch_linear_vel = throw_vector
	
	# Create a realistic tumble (end-over-end) instead of a "horizontal fan" tornado spin
	var horizontal_dir = Vector3(throw_vector.x, 0, throw_vector.z).normalized()
	if horizontal_dir.length_squared() < 0.1:
		horizontal_dir = Vector3(1, 0, 0)
	
	# Tumble axis is perpendicular to the throw direction
	var tumble_axis = horizontal_dir.cross(Vector3.UP).normalized()
	
	# Add slight random wobble, but heavily restrict Y-axis spin to prevent the "tornado" look
	var random_wobble = Vector3(randf_range(-0.2, 0.2), randf_range(-0.1, 0.1), randf_range(-0.2, 0.2))
	var final_spin_axis = (tumble_axis + random_wobble).normalized()
	
	_launch_angular_vel = final_spin_axis * angular_vel_multiplier
	
	_pending_launch = true
	
	if game_manager == null:
		game_manager = get_node_or_null("../GameManager")
	if game_manager and game_manager.has_method("on_dice_thrown"):
		game_manager.on_dice_thrown()

func get_floor_height() -> float:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + Vector3.DOWN * 10.0)
	query.exclude = [self.get_rid()]
	var result = space_state.intersect_ray(query)
	if result:
		return result.position.y
	return 0.0

func start_settle_nudge():
	current_state = State.SETTLING
	freeze = true 
	
	var current_quat = Quaternion(global_transform.basis.orthonormalized())
	var target_quat = get_best_perfect_quaternion(predetermined_result, current_quat)
	
	var rot_diff = rad_to_deg(current_quat.angle_to(target_quat))
	print("Correction Angle: ", rot_diff, " degrees")
	
	var floor_y = get_floor_height()
	var target_pos = global_position
	target_pos.y = floor_y + 0.5 
	
	if _nudge_tween:
		_nudge_tween.kill()
		
	_nudge_tween = create_tween().set_parallel(true)
	if rot_diff > 5.0:
		_nudge_tween.tween_property(self, "quaternion", target_quat, settle_tween_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		quaternion = target_quat
		
	_nudge_tween.tween_property(self, "global_position", target_pos, settle_tween_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_nudge_tween.finished.connect(_on_nudge_finished)

func _on_nudge_finished():
	start_show_value_animation(global_position)

func start_show_value_animation(settled_pos: Vector3):
	current_state = State.SHOW_VALUE
	
	var cam_basis = get_camera_basis()
	var cam_forward = -cam_basis.z
	var target_pos = get_camera_pos() + (cam_forward * 2.0)
	
	# Calculate a rotation that perfectly faces the rolled face to the camera
	var rolled_normal = face_up_normals.get(predetermined_result, Vector3(0, 1, 0))
	# We want local `rolled_normal` to point against camera forward (towards the camera)
	var target_face_dir = -cam_forward
	
	var align_q = Quaternion.IDENTITY
	var axis = rolled_normal.cross(target_face_dir)
	var angle = rolled_normal.angle_to(target_face_dir)
	if axis.length_squared() > 0.0001:
		align_q = Quaternion(axis.normalized(), angle)
	elif rolled_normal.dot(target_face_dir) < 0:
		var ortho = Vector3.RIGHT
		if abs(rolled_normal.x) > 0.9: ortho = Vector3.UP
		align_q = Quaternion(ortho, PI)
		
	# Keep the dice upright relative to the camera
	var cam_up = cam_basis.y
	var base_b = Basis(align_q)
	
	# We have 4 possible rotations around the camera vector. Pick one that keeps it upright.
	var candidate_quats = []
	for i in range(4):
		var rot = Basis(target_face_dir, i * PI / 2.0)
		candidate_quats.append(Quaternion((rot * base_b).orthonormalized()))
		
	var best_q = candidate_quats[0]
	var min_angle = INF
	var current_quat = Quaternion(global_transform.basis.orthonormalized())
	for q in candidate_quats:
		var q_angle = q.angle_to(current_quat)
		if q_angle < min_angle:
			min_angle = q_angle
			best_q = q
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "global_position", target_pos, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "quaternion", best_q, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var tw_seq = create_tween()
	tw_seq.tween_interval(1.2) # Wait to show value
	
	tw_seq.tween_property(self, "global_position", settled_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_seq.finished.connect(_on_show_value_finished)

func _on_show_value_finished():
	current_state = State.RESULT
	emit_signal("dice_roll_finished", predetermined_result)
	
	if game_manager and game_manager.has_method("dice_rolled"):
		game_manager.dice_rolled(predetermined_result)

func get_best_perfect_quaternion(face_val: int, current_quat: Quaternion) -> Quaternion:
	var candidate_quats = []
	var up_normal = face_up_normals.get(face_val, Vector3(0,1,0))
	
	# Determine arbitrary orthogonal axes based on up_normal
	var right = Vector3.RIGHT
	if abs(up_normal.x) > 0.9: right = Vector3.BACK
	
	var fwd = up_normal.cross(right).normalized()
	right = fwd.cross(up_normal).normalized()
	
	# Now X=right, Y=up_normal, Z=fwd is a valid Basis where local Y aligns with up_normal?
	# We want: basis * up_normal = Vector3.UP
	# The easiest way: construct a rotation that aligns up_normal to Vector3.UP
	var align_q = Quaternion.IDENTITY # identity
	var axis = up_normal.cross(Vector3.UP)
	var angle = up_normal.angle_to(Vector3.UP)
	
	if axis.length_squared() > 0.0001:
		align_q = Quaternion(axis.normalized(), angle)
	elif up_normal.dot(Vector3.UP) < 0:
		var ortho = Vector3.RIGHT
		if abs(up_normal.x) > 0.9: ortho = Vector3.UP
		align_q = Quaternion(ortho, PI)
		
	# align_q rotates up_normal to UP. But we need to define 4 orthogonal orientations.
	# Actually, since we need orthogonal bases matching the dice mesh:
	# If we just apply align_q, we get ONE valid basis.
	var base_b = Basis(align_q)
	
	for i in range(4):
		var rot_y = Basis(Vector3.UP, i * PI / 2.0)
		var b = rot_y * base_b
		candidate_quats.append(Quaternion(b.orthonormalized()))
		
	var best_q = candidate_quats[0]
	var min_angle = INF
	
	for q in candidate_quats:
		var q_angle = q.angle_to(current_quat)
		if q_angle < min_angle:
			min_angle = q_angle
			best_q = q
			
	return best_q
