@tool
extends EditorScript

func _run():
	var root = Node3D.new()
	root.name = "Main"
	
	var cam = Camera3D.new()
	cam.name = "MainCamera"
	cam.position = Vector3(0, 22, 22)
	cam.rotation_degrees = Vector3(-45, 0, 0)
	cam.set_script(load("res://Scripts/CameraManager.gd"))
	
	# Solid Green Background for the 3D scene (Matches Figma)
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.html("#8BBD43")
	cam.environment = env
	
	root.add_child(cam)
	cam.owner = root
	
	# Load UI
	var ui_scene = load("res://MainUI.tscn")
	if ui_scene:
		var ui = ui_scene.instantiate()
		ui.name = "MainUI"
		root.add_child(ui)
		ui.owner = root
	
	var light = DirectionalLight3D.new()
	light.name = "DirectionalLight"
	light.rotation_degrees = Vector3(-60, 45, 0)
	root.add_child(light)
	light.owner = root
	
	# Floor for Physics Dice (Raised so top surface is at Y=0.15, matching the squares)
	var floor_body = StaticBody3D.new()
	floor_body.name = "Floor"
	var f_col = CollisionShape3D.new()
	var f_shape = BoxShape3D.new()
	f_shape.size = Vector3(200, 1, 200)
	f_col.shape = f_shape
	f_col.position = Vector3(0, -0.35, 0)
	floor_body.add_child(f_col)
	root.add_child(floor_body)
	floor_body.owner = root
	f_col.owner = root
	
	# Invisible Walls to keep dice inside the board area
	var wall_positions = [
		Vector3(0, 5, -11.5), # Top
		Vector3(0, 5, 11.5),  # Bottom
		Vector3(-11.5, 5, 0), # Left
		Vector3(11.5, 5, 0),   # Right
		Vector3(0, 10, 0)   # Ceiling
	]
	var wall_sizes = [
		Vector3(25, 10, 1),
		Vector3(25, 10, 1),
		Vector3(1, 10, 25),
		Vector3(1, 10, 25),
		Vector3(25, 1, 25)  # Ceiling size
	]
	
	var walls_node = Node3D.new()
	walls_node.name = "InvisibleWalls"
	root.add_child(walls_node)
	walls_node.owner = root
	
	for w in range(5):
		var wall = StaticBody3D.new()
		wall.name = "Wall_" + str(w)
		var wcol = CollisionShape3D.new()
		var wshape = BoxShape3D.new()
		wshape.size = wall_sizes[w]
		wcol.shape = wshape
		wall.position = wall_positions[w]
		wall.add_child(wcol)
		walls_node.add_child(wall)
		wall.owner = root
		wcol.owner = root
	
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
		
		# Define exact positions for the 40 colored squares.
		# They form a rectangle with corners at +/- 10, +/- 10.
		# Total width is 20, step size is 2.
		if i == 0:
			x = 10; z = 10
		elif i >= 1 and i <= 9:
			x = 10 - (i * 2); z = 10
		elif i == 10:
			x = -10; z = 10
		elif i >= 11 and i <= 19:
			x = -10; z = 10 - ((i - 10) * 2)
		elif i == 20:
			x = -10; z = -10
		elif i >= 21 and i <= 29:
			x = -10 + ((i - 20) * 2); z = -10
		elif i == 30:
			x = 10; z = -10
		elif i >= 31 and i <= 39:
			x = 10; z = -10 + ((i - 30) * 2)

		# Colored Square
		var square_mesh = MeshInstance3D.new()
		square_mesh.name = "Square_" + str(i)
		var s_box = BoxMesh.new()
		s_box.size = Vector3(1.9, 0.2, 1.9)
		square_mesh.mesh = s_box
		var s_mat = StandardMaterial3D.new()
		s_mat.albedo_color = inner_square_types[i]
		s_box.surface_set_material(0, s_mat)
		square_mesh.position = Vector3(x, 0.05, z)
		board.add_child(square_mesh)
		square_mesh.owner = root

	# Load 3D Avatar
	var avatar_scene = load("res://Scenes/RatAvatar.tscn")
	var avatar = avatar_scene.instantiate()
	avatar.name = "RatAvatar"
	
	# Initial position on Square_0
	avatar.position = Vector3(10, 0.05, 10)
	root.add_child(avatar)
	avatar.owner = root
	
	# Load true 3D Dice with Dots
	var dice_scene = load("res://Scenes/Dice.tscn")
	var dice = dice_scene.instantiate()
	dice.name = "Dice3D"
	dice.scale = Vector3(0.5, 0.5, 0.5) # Scale down dice by 50%
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
	print("NewMain.tscn fully generated with UI, Dice, and Invisible Walls!")
