extends SceneTree

func _init():
	var root = Node3D.new()
	root.name = "Main"
	
	var cam = Camera3D.new()
	cam.name = "MainCamera"
	cam.position = Vector3(0, 18, 22)
	cam.rotation_degrees = Vector3(-45, 0, 0)
	root.add_child(cam)
	cam.owner = root
	
	var light = DirectionalLight3D.new()
	light.name = "DirectionalLight"
	light.rotation_degrees = Vector3(-60, 45, 0)
	root.add_child(light)
	light.owner = root
	
	# Board setup
	var inner_square_types = []
	var colors = [
		Color(0.9, 0.7, 0.1), Color(0.3, 0.7, 0.3), Color(0.9, 0.2, 0.2), Color(0.6, 0.3, 0.9), Color(0.2, 0.5, 0.9)
	]
	for i in range(36):
		inner_square_types.append(colors[i % colors.size()])
		
	var board = Node3D.new()
	board.name = "Board"
	root.add_child(board)
	board.owner = root
	
	var spacing = 2.0
	var inner_index = 0
	
	for i in range(40):
		var x = 0.0
		var z = 0.0
		var is_corner = false
		var inner_dir = Vector3.ZERO
		var dash_size = Vector3(0.1, 0.11, 1.0)
		
		if i == 0:
			x = 10; z = 10; is_corner = true
		elif i >= 1 and i <= 9:
			x = 10 - (i * 2); z = 10
			inner_dir = Vector3(0, 0, -1)
			dash_size = Vector3(1.0, 0.11, 0.1)
		elif i == 10:
			x = -10; z = 10; is_corner = true
		elif i >= 11 and i <= 19:
			x = -10; z = 10 - ((i - 10) * 2)
			inner_dir = Vector3(1, 0, 0)
			dash_size = Vector3(0.1, 0.11, 1.0)
		elif i == 20:
			x = -10; z = -10; is_corner = true
		elif i >= 21 and i <= 29:
			x = -10 + ((i - 20) * 2); z = -10
			inner_dir = Vector3(0, 0, 1)
			dash_size = Vector3(1.0, 0.11, 0.1)
		elif i == 30:
			x = 10; z = -10; is_corner = true
		elif i >= 31 and i <= 39:
			x = 10; z = -10 + ((i - 30) * 2)
			inner_dir = Vector3(-1, 0, 0)
			dash_size = Vector3(0.1, 0.11, 1.0)

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
		
		if not is_corner:
			var dash_mesh = MeshInstance3D.new()
			dash_mesh.name = "Dash"
			var d_box = BoxMesh.new()
			d_box.size = dash_size
			dash_mesh.mesh = d_box
			var d_mat = StandardMaterial3D.new()
			d_mat.albedo_color = Color(1.0, 1.0, 1.0)
			d_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # Ensure it's purely white regardless of lighting
			d_box.surface_set_material(0, d_mat)
			dash_mesh.position = Vector3(0, 0, 0)
			path_mesh.add_child(dash_mesh)
			dash_mesh.owner = root

			var square_mesh = MeshInstance3D.new()
			square_mesh.name = "Square_" + str(inner_index)
			var s_box = BoxMesh.new()
			s_box.size = Vector3(1.9, 0.2, 1.9)
			square_mesh.mesh = s_box
			var s_mat = StandardMaterial3D.new()
			s_mat.albedo_color = inner_square_types[inner_index]
			s_box.surface_set_material(0, s_mat)
			square_mesh.position = Vector3(x, 0.05, z) + (inner_dir * spacing)
			board.add_child(square_mesh)
			square_mesh.owner = root
			inner_index += 1

	var avatar = Node3D.new()
	avatar.name = "RatAvatar"
	avatar.set_script(load("res://Scripts/Avatar.gd"))
	var body = MeshInstance3D.new()
	body.name = "Body"
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.3; cyl.bottom_radius = 0.4; cyl.height = 1.0
	body.mesh = cyl
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.8, 0.8, 0.8)
	cyl.surface_set_material(0, body_mat)
	body.position = Vector3(0, 0.5, 0)
	avatar.add_child(body)
	
	var head = MeshInstance3D.new()
	head.name = "Head"
	var sph = SphereMesh.new()
	sph.radius = 0.4; sph.height = 0.8
	head.mesh = sph
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.9, 0.9, 0.9)
	sph.surface_set_material(0, head_mat)
	head.position = Vector3(0, 1.2, 0)
	avatar.add_child(head)
	
	avatar.position = Vector3(10, 0.05, 10)
	root.add_child(avatar)
	avatar.owner = root
	body.owner = root
	head.owner = root
	
	var dice = MeshInstance3D.new()
	dice.name = "Dice3D"
	dice.set_script(load("res://Scripts/Dice.gd"))
	var d_box = BoxMesh.new()
	d_box.size = Vector3(1.5, 1.5, 1.5)
	dice.mesh = d_box
	var d_mat = StandardMaterial3D.new()
	d_mat.albedo_color = Color(1.0, 0.2, 0.2)
	d_box.surface_set_material(0, d_mat)
	dice.position = Vector3(0, 2, 0)
	root.add_child(dice)
	dice.owner = root
	
	var gm = Node.new()
	gm.name = "GameManager"
	gm.set_script(load("res://Scripts/GameManager.gd"))
	root.add_child(gm)
	gm.owner = root
	
	var packed_main = PackedScene.new()
	packed_main.pack(root)
	ResourceSaver.save(packed_main, "res://Scenes/NewMain.tscn")
	print("NewMain.tscn fully generated with scripts attached!")
	quit()
