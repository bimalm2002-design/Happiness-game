extends SceneTree

func _init():
	var root = Node3D.new()
	root.name = "Main"
	
	# Camera
	var cam = Camera3D.new()
	cam.name = "MainCamera"
	cam.position = Vector3(0, 18, 22)
	cam.rotation_degrees = Vector3(-45, 0, 0)
	cam.set_script(load("res://Scripts/CameraManager.gd"))
	root.add_child(cam)
	cam.owner = root
	
	var light = DirectionalLight3D.new()
	light.name = "DirectionalLight"
	light.rotation_degrees = Vector3(-60, 45, 0)
	root.add_child(light)
	light.owner = root
	
	# Floor for Physics Dice
	var floor_body = StaticBody3D.new()
	floor_body.name = "Floor"
	var f_col = CollisionShape3D.new()
	var f_shape = BoxShape3D.new()
	f_shape.size = Vector3(200, 1, 200)
	f_col.shape = f_shape
	f_col.position = Vector3(0, -0.5, 0)
	floor_body.add_child(f_col)
	root.add_child(floor_body)
	floor_body.owner = root
	f_col.owner = root
	
	# Board setup
	var inner_square_types = []
	var colors = [
		Color(0.9, 0.7, 0.1), Color(0.3, 0.7, 0.3), Color(0.9, 0.2, 0.2), Color(0.6, 0.3, 0.9), Color(0.2, 0.5, 0.9)
	]
	# Now we have 40 inner squares (including corners)
	for i in range(40):
		inner_square_types.append(colors[i % colors.size()])
		
	var board = Node3D.new()
	board.name = "Board"
	root.add_child(board)
	board.owner = root
	
	var inner_index = 0
	
	for i in range(40):
		var x = 0.0
		var z = 0.0
		var is_corner = false
		var inner_dir = Vector3.ZERO
		var dash_size = Vector3(0.1, 0.11, 1.0)
		
		# Define positions and inner square directions
		if i == 0:
			x = 10; z = 10; is_corner = true
			inner_dir = Vector3(-1, 0, -1) # Point to (8, 8)
		elif i >= 1 and i <= 9:
			x = 10 - (i * 2); z = 10
			inner_dir = Vector3(0, 0, -1)
			dash_size = Vector3(1.0, 0.11, 0.1)
		elif i == 10:
			x = -10; z = 10; is_corner = true
			inner_dir = Vector3(1, 0, -1) # Point to (-8, 8)
		elif i >= 11 and i <= 19:
			x = -10; z = 10 - ((i - 10) * 2)
			inner_dir = Vector3(1, 0, 0)
			dash_size = Vector3(0.1, 0.11, 1.0)
		elif i == 20:
			x = -10; z = -10; is_corner = true
			inner_dir = Vector3(1, 0, 1) # Point to (-8, -8)
		elif i >= 21 and i <= 29:
			x = -10 + ((i - 20) * 2); z = -10
			inner_dir = Vector3(0, 0, 1)
			dash_size = Vector3(1.0, 0.11, 0.1)
		elif i == 30:
			x = 10; z = -10; is_corner = true
			inner_dir = Vector3(-1, 0, 1) # Point to (8, -8)
		elif i >= 31 and i <= 39:
			x = 10; z = -10 + ((i - 30) * 2)
			inner_dir = Vector3(-1, 0, 0)
			dash_size = Vector3(0.1, 0.11, 1.0)

		# Outer Path
		var path_mesh = MeshInstance3D.new()
		path_mesh.name = "Path_" + str(i)
		var p_box = BoxMesh.new()
		p_box.size = Vector3(2.0, 0.1, 2.0)
		path_mesh.mesh = p_box
		var p_mat = StandardMaterial3D.new()
		p_mat.albedo_color = Color(0.15, 0.15, 0.15)
		p_box.surface_set_material(0, p_mat)
		path_mesh.position = Vector3(x, 0, z)
		board.add_child(path_mesh)
		path_mesh.owner = root
		
		# Dashed Line (Only on straight paths)
		if not is_corner:
			var dash_mesh = MeshInstance3D.new()
			dash_mesh.name = "Dash"
			var d_box = BoxMesh.new()
			d_box.size = dash_size
			dash_mesh.mesh = d_box
			var d_mat = StandardMaterial3D.new()
			d_mat.albedo_color = Color(1.0, 1.0, 1.0)
			d_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			d_box.surface_set_material(0, d_mat)
			dash_mesh.position = Vector3(0, 0, 0)
			path_mesh.add_child(dash_mesh)
			dash_mesh.owner = root

		# Inner Square (Now added for EVERY tile, including corners)
		var square_mesh = MeshInstance3D.new()
		square_mesh.name = "Square_" + str(inner_index)
		var s_box = BoxMesh.new()
		s_box.size = Vector3(1.9, 0.2, 1.9)
		square_mesh.mesh = s_box
		var s_mat = StandardMaterial3D.new()
		s_mat.albedo_color = inner_square_types[inner_index]
		s_box.surface_set_material(0, s_mat)
		
		# Calculate position. Corners are diagonal, so they move by 2.0 in both X and Z.
		# Straight paths move by 2.0 in one axis.
		if is_corner:
			square_mesh.position = Vector3(x, 0.05, z) + (inner_dir * 2.0)
		else:
			square_mesh.position = Vector3(x, 0.05, z) + (inner_dir * 2.0)
			
		board.add_child(square_mesh)
		square_mesh.owner = root
		inner_index += 1

	# Load 3D Avatar
	var avatar_scene = load("res://Scenes/RatAvatar.tscn")
	var avatar = avatar_scene.instantiate()
	avatar.name = "RatAvatar"
	avatar.position = Vector3(10, 0.05, 10)
	root.add_child(avatar)
	avatar.owner = root
	
	# PHYSICS DICE
	var dice = RigidBody3D.new()
	dice.name = "Dice3D"
	dice.set_script(load("res://Scripts/Dice.gd"))
	
	var d_col = CollisionShape3D.new()
	var col_shape = BoxShape3D.new()
	col_shape.size = Vector3(1.5, 1.5, 1.5)
	d_col.shape = col_shape
	dice.add_child(d_col)
	
	var dice_mesh = MeshInstance3D.new()
	var d_box = BoxMesh.new()
	d_box.size = Vector3(1.5, 1.5, 1.5)
	dice_mesh.mesh = d_box
	var dm_mat = StandardMaterial3D.new()
	dm_mat.albedo_color = Color(1.0, 0.2, 0.2)
	d_box.surface_set_material(0, dm_mat)
	dice.add_child(dice_mesh)
	
	dice.position = Vector3(0, 2, 0)
	root.add_child(dice)
	dice.owner = root
	d_col.owner = root
	dice_mesh.owner = root
	
	var gm = Node.new()
	gm.name = "GameManager"
	gm.set_script(load("res://Scripts/GameManager.gd"))
	root.add_child(gm)
	gm.owner = root
	
	var packed_main = PackedScene.new()
	packed_main.pack(root)
	ResourceSaver.save(packed_main, "res://Scenes/NewMain.tscn")
	print("NewMain.tscn fully generated with corner squares included!")
	quit()
