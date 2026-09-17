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
		print("Board not found.")
		return
		
	# 1. Get all current MeshInstance3D squares in order and assign path_index
	var squares = []
	for child in board.get_children():
		if child is MeshInstance3D:
			squares.append(child)
			
	for i in range(squares.size()):
		squares[i].set_meta("path_index", i)
		
	# 2. Create groups
	var groups = {
		"land": "LandSquares",
		"opportunity": "OpportunitySquares",
		"oops": "OopsSquares",
		"stock": "StockSquares",
		"flash": "FlashSquares",
		"monopoly": "MonopolySquares",
		"square": "OtherSquares"
	}
	
	var group_nodes = {}
	for k in groups.keys():
		var g_name = groups[k]
		var g_node = Node3D.new()
		g_node.name = g_name
		board.add_child(g_node)
		g_node.owner = root
		group_nodes[k] = g_node
		
	# 3. Reparent squares
	for sq in squares:
		var lname = sq.name.to_lower()
		var assigned = false
		for k in groups.keys():
			if lname.begins_with(k):
				sq.get_parent().remove_child(sq)
				group_nodes[k].add_child(sq)
				sq.owner = root
				assigned = true
				break
		if not assigned:
			sq.get_parent().remove_child(sq)
			group_nodes["square"].add_child(sq)
			sq.owner = root
			
	var new_packed = PackedScene.new()
	new_packed.pack(root)
	ResourceSaver.save(new_packed, scene_path)
	print("Grouped ", squares.size(), " squares and saved ", scene_path)

