extends SceneTree

func _init():
	var avatar = Node3D.new()
	avatar.name = "RatAvatar"
	avatar.set_script(load("res://Scripts/Avatar.gd"))
	
	var rig = Node3D.new()
	rig.name = "Rig"
	avatar.add_child(rig)
	rig.owner = avatar
	
	# Materials
	var blue_mat = StandardMaterial3D.new()
	blue_mat.albedo_color = Color(0.2, 0.4, 0.6) # Mechanic blue
	
	var brown_mat = StandardMaterial3D.new()
	brown_mat.albedo_color = Color(0.6, 0.3, 0.1) # Rat brown
	
	var pink_mat = StandardMaterial3D.new()
	pink_mat.albedo_color = Color(0.9, 0.6, 0.6) # Nose/Tail pink
	
	var black_mat = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.1, 0.1, 0.1) # Eyes
	
	# Body
	var body = MeshInstance3D.new()
	body.name = "Body"
	var body_mesh = CapsuleMesh.new()
	body_mesh.radius = 0.3
	body_mesh.height = 0.9
	body.mesh = body_mesh
	body.set_surface_override_material(0, blue_mat)
	body.position = Vector3(0, 0.6, 0)
	rig.add_child(body)
	body.owner = avatar
	
	# Head Pivot
	var head_pivot = Node3D.new()
	head_pivot.name = "HeadPivot"
	head_pivot.position = Vector3(0, 1.1, 0)
	rig.add_child(head_pivot)
	head_pivot.owner = avatar
	
	var head = MeshInstance3D.new()
	head.name = "Head"
	var head_mesh = BoxMesh.new()
	head_mesh.size = Vector3(0.4, 0.35, 0.5)
	head.mesh = head_mesh
	head.set_surface_override_material(0, brown_mat)
	head.position = Vector3(0, 0, 0.1)
	head_pivot.add_child(head)
	head.owner = avatar
	
	# Snout
	var snout = MeshInstance3D.new()
	snout.name = "Snout"
	var snout_mesh = BoxMesh.new()
	snout_mesh.size = Vector3(0.2, 0.15, 0.4)
	snout.mesh = snout_mesh
	snout.set_surface_override_material(0, brown_mat)
	snout.position = Vector3(0, -0.05, 0.4)
	head.add_child(snout)
	snout.owner = avatar
	
	# Nose
	var nose = MeshInstance3D.new()
	nose.name = "Nose"
	var nose_mesh = SphereMesh.new()
	nose_mesh.radius = 0.08
	nose_mesh.height = 0.16
	nose.mesh = nose_mesh
	nose.set_surface_override_material(0, pink_mat)
	nose.position = Vector3(0, 0, 0.2)
	snout.add_child(nose)
	nose.owner = avatar
	
	# Eyes
	for x in [-0.15, 0.15]:
		var eye = MeshInstance3D.new()
		var eye_mesh = SphereMesh.new()
		eye_mesh.radius = 0.05; eye_mesh.height = 0.1
		eye.mesh = eye_mesh
		eye.set_surface_override_material(0, black_mat)
		eye.position = Vector3(x, 0.1, 0.25)
		head.add_child(eye)
		eye.owner = avatar
		
	# Ears
	for x in [-0.25, 0.25]:
		var ear = MeshInstance3D.new()
		var ear_mesh = CylinderMesh.new()
		ear_mesh.top_radius = 0.15; ear_mesh.bottom_radius = 0.15; ear_mesh.height = 0.05
		ear.mesh = ear_mesh
		ear.set_surface_override_material(0, pink_mat)
		ear.rotation_degrees = Vector3(90, 0, 0)
		ear.position = Vector3(x, 0.2, -0.1)
		head.add_child(ear)
		ear.owner = avatar
		
	# Hat
	var hat = MeshInstance3D.new()
	hat.name = "Hat"
	var hat_mesh = CylinderMesh.new()
	hat_mesh.top_radius = 0.2; hat_mesh.bottom_radius = 0.22; hat_mesh.height = 0.15
	hat.mesh = hat_mesh
	hat.set_surface_override_material(0, blue_mat)
	hat.position = Vector3(0, 0.25, 0)
	head.add_child(hat)
	hat.owner = avatar
	
	# Hat Brim
	var brim = MeshInstance3D.new()
	var brim_mesh = CylinderMesh.new()
	brim_mesh.top_radius = 0.25; brim_mesh.bottom_radius = 0.25; brim_mesh.height = 0.02
	brim.mesh = brim_mesh
	brim.set_surface_override_material(0, blue_mat)
	brim.position = Vector3(0, -0.05, 0.1)
	hat.add_child(brim)
	brim.owner = avatar
	
	# Arms
	var arm_dist = 0.35
	var arm_height = 0.8
	
	var l_arm_pivot = Node3D.new()
	l_arm_pivot.name = "LeftArmPivot"
	l_arm_pivot.position = Vector3(arm_dist, arm_height, 0)
	rig.add_child(l_arm_pivot)
	l_arm_pivot.owner = avatar
	
	var l_arm = MeshInstance3D.new()
	l_arm.name = "LeftArm"
	var arm_mesh = CapsuleMesh.new()
	arm_mesh.radius = 0.08; arm_mesh.height = 0.5
	l_arm.mesh = arm_mesh
	l_arm.set_surface_override_material(0, blue_mat)
	l_arm.position = Vector3(0, -0.2, 0)
	l_arm_pivot.add_child(l_arm)
	l_arm.owner = avatar
	
	var r_arm_pivot = Node3D.new()
	r_arm_pivot.name = "RightArmPivot"
	r_arm_pivot.position = Vector3(-arm_dist, arm_height, 0)
	rig.add_child(r_arm_pivot)
	r_arm_pivot.owner = avatar
	
	var r_arm = MeshInstance3D.new()
	r_arm.name = "RightArm"
	r_arm.mesh = arm_mesh
	r_arm.set_surface_override_material(0, blue_mat)
	r_arm.position = Vector3(0, -0.2, 0)
	r_arm_pivot.add_child(r_arm)
	r_arm.owner = avatar
	
	# Legs
	var leg_dist = 0.15
	var leg_height = 0.3
	
	var l_leg_pivot = Node3D.new()
	l_leg_pivot.name = "LeftLegPivot"
	l_leg_pivot.position = Vector3(leg_dist, leg_height, 0)
	rig.add_child(l_leg_pivot)
	l_leg_pivot.owner = avatar
	
	var l_leg = MeshInstance3D.new()
	l_leg.name = "LeftLeg"
	var leg_mesh = CapsuleMesh.new()
	leg_mesh.radius = 0.1; leg_mesh.height = 0.4
	l_leg.mesh = leg_mesh
	l_leg.set_surface_override_material(0, blue_mat)
	l_leg.position = Vector3(0, -0.15, 0)
	l_leg_pivot.add_child(l_leg)
	l_leg.owner = avatar
	
	var r_leg_pivot = Node3D.new()
	r_leg_pivot.name = "RightLegPivot"
	r_leg_pivot.position = Vector3(-leg_dist, leg_height, 0)
	rig.add_child(r_leg_pivot)
	r_leg_pivot.owner = avatar
	
	var r_leg = MeshInstance3D.new()
	r_leg.name = "RightLeg"
	r_leg.mesh = leg_mesh
	r_leg.set_surface_override_material(0, blue_mat)
	r_leg.position = Vector3(0, -0.15, 0)
	r_leg_pivot.add_child(r_leg)
	r_leg.owner = avatar
	
	# Tail
	var tail_pivot = Node3D.new()
	tail_pivot.name = "TailPivot"
	tail_pivot.position = Vector3(0, 0.4, -0.3)
	rig.add_child(tail_pivot)
	tail_pivot.owner = avatar
	
	var tail = MeshInstance3D.new()
	tail.name = "Tail"
	var tail_mesh = CylinderMesh.new()
	tail_mesh.top_radius = 0.02; tail_mesh.bottom_radius = 0.04; tail_mesh.height = 0.8
	tail.mesh = tail_mesh
	tail.set_surface_override_material(0, pink_mat)
	tail.rotation_degrees = Vector3(45, 0, 0)
	tail.position = Vector3(0, 0.3, -0.3)
	tail_pivot.add_child(tail)
	tail.owner = avatar
	
	var packed_avatar = PackedScene.new()
	packed_avatar.pack(avatar)
	ResourceSaver.save(packed_avatar, "res://Scenes/RatAvatar.tscn")
	print("Procedural 3D RatAvatar.tscn generated successfully!")
	quit()
