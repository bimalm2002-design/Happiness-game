@tool
extends EditorScript

func _run():
	var dice = RigidBody3D.new()
	dice.name = "Dice3D"
	dice.set_script(load("res://Scripts/Dice.gd"))
	
	var s = 0.4
	var box_dim = 1.5 * s
	
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(box_dim, box_dim, box_dim)
	col.shape = box
	dice.add_child(col)
	col.owner = dice
	
	var mesh = MeshInstance3D.new()
	mesh.name = "Mesh"
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(box_dim, box_dim, box_dim)
	mesh.mesh = box_mesh
	
	var mat_white = StandardMaterial3D.new()
	mat_white.albedo_color = Color(1, 1, 1)
	box_mesh.surface_set_material(0, mat_white)
	
	dice.add_child(mesh)
	mesh.owner = dice
	
	var mat_black = StandardMaterial3D.new()
	mat_black.albedo_color = Color(0, 0, 0)
	
	# Helper to place a dot
	var add_dot = func(pos: Vector3, rot: Vector3):
		var dot = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.15 * s; cyl.bottom_radius = 0.15 * s; cyl.height = 0.02 * s
		dot.mesh = cyl
		dot.set_surface_override_material(0, mat_black)
		dot.position = pos
		dot.rotation_degrees = rot
		mesh.add_child(dot)
		dot.owner = dice
		
	var h = 0.76 * s # Slightly outside the box
	var d = 0.35 * s # Dot offset
	
	# Face 1 (+Y)
	add_dot.call(Vector3(0, h, 0), Vector3(0, 0, 0))
	
	# Face 6 (-Y)
	add_dot.call(Vector3(-d, -h, -d), Vector3(180, 0, 0))
	add_dot.call(Vector3(0, -h, -d), Vector3(180, 0, 0))
	add_dot.call(Vector3(d, -h, -d), Vector3(180, 0, 0))
	add_dot.call(Vector3(-d, -h, d), Vector3(180, 0, 0))
	add_dot.call(Vector3(0, -h, d), Vector3(180, 0, 0))
	add_dot.call(Vector3(d, -h, d), Vector3(180, 0, 0))
	
	# Face 2 (+Z)
	add_dot.call(Vector3(-d, d, h), Vector3(90, 0, 0))
	add_dot.call(Vector3(d, -d, h), Vector3(90, 0, 0))
	
	# Face 5 (-Z)
	add_dot.call(Vector3(-d, d, -h), Vector3(-90, 0, 0))
	add_dot.call(Vector3(d, -d, -h), Vector3(-90, 0, 0))
	add_dot.call(Vector3(-d, -d, -h), Vector3(-90, 0, 0))
	add_dot.call(Vector3(d, d, -h), Vector3(-90, 0, 0))
	add_dot.call(Vector3(0, 0, -h), Vector3(-90, 0, 0))
	
	# Face 3 (+X)
	add_dot.call(Vector3(h, d, -d), Vector3(0, 0, -90))
	add_dot.call(Vector3(h, 0, 0), Vector3(0, 0, -90))
	add_dot.call(Vector3(h, -d, d), Vector3(0, 0, -90))
	
	# Face 4 (-X)
	add_dot.call(Vector3(-h, d, -d), Vector3(0, 0, 90))
	add_dot.call(Vector3(-h, d, d), Vector3(0, 0, 90))
	add_dot.call(Vector3(-h, -d, -d), Vector3(0, 0, 90))
	add_dot.call(Vector3(-h, -d, d), Vector3(0, 0, 90))
	
	var packed = PackedScene.new()
	packed.pack(dice)
	ResourceSaver.save(packed, "res://Scenes/Dice.tscn")
	print("Dice.tscn generated!")
