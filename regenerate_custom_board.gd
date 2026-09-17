@tool
extends EditorScript

func _run():
	var scene_path = "res://Scenes/NewMain.tscn"
	var packed_scene = load(scene_path)
	if not packed_scene:
		print("Failed to load scene.")
		return
		
	var root = packed_scene.instantiate()
	var board = root.get_node_or_null("Board")
	if not board:
		board = Node3D.new()
		board.name = "Board"
		root.add_child(board)
		board.owner = root
	
	# Remove old children
	for child in board.get_children():
		board.remove_child(child)
		child.queue_free()
		
	var custom_names = [
		"oops!", "opportunity", "monopoly1", "land1", "flash1", "stock1", "oops1", "opportunity1",
		"opportunity2", "monopoly2", "land2", "stock2", "oops2", "opportunity3", "oops3", "monopoly3",
		"land3", "stock3", "flash2", "opportunity4", "monopoly4", "land4", "flash3", "stock4",
		"oops5", "opportunity5", "monopoly5", "land5", "flash4", "stock5", "oops6", "opportunity6",
		"oops7", "monopoly6", "land6", "stock6", "flash5", "opportunity7", "oops8", "monopoly7",
		"land7", "Square_34", "stock7", "opportunity8", "monopoly8", "land8", "stock8", "Square_39"
	]
	
	var groups = {
		"land": "LandSquares",
		"opportunity": "OpportunitySquares",
		"oops": "OopsSquares",
		"stock": "StockSquares",
		"flash": "FlashSquares",
		"monopoly": "MonopolySquares",
		"square": "OtherSquares"
	}
	
	var colors = {
		"land": Color(0.2, 0.8, 0.2), # Green
		"opportunity": Color(0.2, 0.2, 0.8), # Blue
		"oops": Color(0.8, 0.2, 0.2), # Red
		"stock": Color(0.8, 0.8, 0.2), # Yellow
		"flash": Color(0.6, 0.2, 0.8), # Purple
		"monopoly": Color(0.1, 0.1, 0.1), # Black
		"square": Color(0.5, 0.5, 0.5) # Grey
	}
	
	var group_nodes = {}
	for k in groups.keys():
		var g_node = Node3D.new()
		g_node.name = groups[k]
		board.add_child(g_node)
		g_node.owner = root
		group_nodes[k] = g_node
	
	var square_size = 1.9
	var spacing = 2.0
	var total_squares = 48
	var side_length = 12
	
	var x = 0
	var z = 0
	
	# Calculate offset to center the board
	var offset = (side_length * spacing) / 2.0
	
	for i in range(total_squares):
		var sq_name = custom_names[i] if i < custom_names.size() else ("Square_" + str(i))
		var lname = sq_name.to_lower()
		var matched_type = "square"
		
		for k in groups.keys():
			if lname.begins_with(k):
				matched_type = k
				break
				
		var mesh = BoxMesh.new()
		mesh.size = Vector3(square_size, 0.2, square_size)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = colors[matched_type]
		mesh.surface_set_material(0, mat)
		
		var node = MeshInstance3D.new()
		node.mesh = mesh
		node.name = sq_name
		node.position = Vector3(x * spacing - offset, 0, z * spacing - offset)
		node.set_meta("path_index", i)
		
		group_nodes[matched_type].add_child(node)
		node.owner = root
		
		# Move to next position (Clockwise)
		if z == 0 and x < side_length:
			x += 1
		elif x == side_length and z < side_length:
			z += 1
		elif z == side_length and x > 0:
			x -= 1
		elif x == 0 and z > 0:
			z -= 1

	var new_packed = PackedScene.new()
	new_packed.pack(root)
	ResourceSaver.save(new_packed, scene_path)
	print("Restored ", total_squares, " custom squares!")
