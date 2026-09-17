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
	
	for child in board.get_children():
		board.remove_child(child)
		child.queue_free()

	var w = 13
	var h = 8
	var square_size = 1.85
	var spacing = 2.0
	
	var seq = [
		# Bottom row  (z = 7, x = 12 -> 0)
		"go_1", "flash_1", "oops_1", "monopoly_1", "stock_1", "opportunity_1",
		"monopoly_2", "oops_2", "flash_2", "monopoly_3", "opportunity_2", "oops_3",
		# Left column (x = 0, z = 7 -> 1)
		"stock_2", "stock_3", "monopoly_4", "opportunity_3", "flash_3",
		"monopoly_5", "oops_4",
		# Top row     (z = 0, x = 0 -> 11)
		"stock_4", "oops_5", "opportunity_4", "monopoly_6", "oops_6", "stock_5",
		"monopoly_7", "stock_6", "flash_4", "monopoly_8", "opportunity_5", "oops_7",
		# Right column (x = 12, z = 0 -> 6)
		"opportunity_6", "stock_7", "monopoly_9", "flash_5", "oops_8",
		"monopoly_10", "opportunity_7",
	]
	
	assert(seq.size() == 38, "Sequence must be exactly 38 squares")
	var counts = {"stock":0, "oops":0, "flash":0, "opportunity":0, "monopoly":0, "go":0}
	for s in seq:
		var t = s.split("_")[0]
		if counts.has(t): counts[t] += 1
	assert(counts["stock"] == 7, "Expected 7 stock")
	assert(counts["oops"] == 8, "Expected 8 oops")
	assert(counts["flash"] == 5, "Expected 5 flash")
	assert(counts["opportunity"] == 7, "Expected 7 opportunity")
	assert(counts["monopoly"] == 10, "Expected 10 monopoly")
	assert(counts["go"] == 1, "Expected 1 go")
	
	var groups = {
		"opportunity": "OpportunitySquares",
		"oops": "OopsSquares",
		"stock": "StockSquares",
		"flash": "FlashSquares",
		"monopoly": "MonopolySquares",
		"go": "OtherSquares"
	}
	
	var colors = {
		"opportunity": Color(0.35, 0.83, 0.20),
		"oops": Color(0.98, 0.20, 0.20),
		"stock": Color(0.29, 0.51, 0.98),
		"flash": Color(0.81, 0.42, 0.91),
		"monopoly": Color(0.52, 0.52, 0.52),
		"go": Color(0.99, 0.87, 0.10)
	}
	
	var icons = {
		"opportunity": "res://Assets/Icons/rocket-flying-space-cartoon-vector-icon-illustration-science-technology-icon-isolated-flat_138676-13855.png",
		"stock": "res://Assets/Icons/bear-bull-stock-3840x2160-13812.png",
		"oops": "res://Assets/Icons/expenses.png",
		"flash": "res://Assets/Icons/lightning-icon.png"
	}
	
	var icon_target_sizes = {
		"opportunity": 1.5,
		"stock": 1.8, 
		"oops": 1.4,
		"flash": 1.6
	}
	
	var group_nodes = {}
	for k in groups.values():
		if not group_nodes.has(k):
			var g_node = Node3D.new()
			g_node.name = k
			board.add_child(g_node)
			g_node.owner = root
			group_nodes[k] = g_node
	
	var x = w - 1
	var z = h - 1
	var offset_x = (w * spacing) / 2.0 - (spacing / 2.0)
	var offset_z = (h * spacing) / 2.0 - (spacing / 2.0)
	
	for i in range(seq.size()):
		var sq_name = seq[i]
		var sq_type = sq_name.split("_")[0]
		var group_name = groups[sq_type]
		
		var node = MeshInstance3D.new()
		var mesh = BoxMesh.new()
		mesh.size = Vector3(square_size, 0.2, square_size)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = colors[sq_type]
		mesh.surface_set_material(0, mat)
		node.mesh = mesh
		node.name = sq_name
		node.position = Vector3(x * spacing - offset_x, 0, z * spacing - offset_z)
		node.set_meta("path_index", i)
		
		group_nodes[group_name].add_child(node)
		node.owner = root
		
		var rot_y = 0.0
		if z == 0: rot_y = 180.0
		elif z == h - 1: rot_y = 0.0
		elif x == w - 1: rot_y = 90.0
		elif x == 0: rot_y = -90.0
		
		if sq_type == "go":
			var lbl = Label3D.new()
			lbl.text = "GO"
			lbl.font_size = 140
			lbl.modulate = Color.BLACK
			lbl.position = Vector3(0, 0.11, 0)
			lbl.rotation_degrees = Vector3(-90, rot_y, 0)
			node.add_child(lbl)
			lbl.owner = root
		elif sq_type == "monopoly":
			var neck_length = 1.35 * square_size
			var neck_width = 1.0 * square_size
			var head_length = 1.28 * square_size
			var head_width = 1.29 * square_size
			
			if z == h - 1 or z == 0:
				mesh.size = Vector3(neck_width, 0.2, neck_length)
			else:
				mesh.size = Vector3(neck_length, 0.2, neck_width)
			
			var head = MeshInstance3D.new()
			var hmesh = BoxMesh.new()
			if z == h - 1 or z == 0:
				hmesh.size = Vector3(head_width, 0.2, head_length)
			else:
				hmesh.size = Vector3(head_length, 0.2, head_width)
			var hmat = StandardMaterial3D.new()
			hmat.albedo_color = colors[sq_type]
			hmesh.surface_set_material(0, hmat)
			head.mesh = hmesh
			
			var inward_offset = (neck_length / 2.0) + (head_length / 2.0)
			
			if z == h - 1:
				head.position = Vector3(0, 0, -inward_offset)
			elif x == 0:
				head.position = Vector3(inward_offset, 0, 0)
			elif z == 0:
				head.position = Vector3(0, 0, inward_offset)
			elif x == w - 1:
				head.position = Vector3(-inward_offset, 0, 0)
				
			node.add_child(head)
			head.owner = root
			
			var lbl = Label3D.new()
			lbl.text = "M"
			lbl.font_size = 300
			lbl.modulate = Color8(187, 187, 187)
			lbl.outline_modulate = Color(0,0,0,0)
			lbl.outline_size = 0
			lbl.position = Vector3(0, 0.11, 0)
			lbl.rotation_degrees = Vector3(-90, rot_y, 0)
			head.add_child(lbl)
			lbl.owner = root
			
			var total_reach = neck_length + head_length
			print("Monopoly %s: neck_len=%.3f, head_len=%.3f, total inward reach=%.3f" % [sq_name, neck_length, head_length, total_reach])
		elif icons.has(sq_type):
			var spr = Sprite3D.new()
			var tex = load(icons[sq_type])
			if tex:
				spr.texture = tex
				spr.axis = Vector3.AXIS_Y
				spr.position = Vector3(0, 0.11, 0)
				spr.rotation_degrees = Vector3(0, 0, 0)
				var tex_size = tex.get_size()
				var target_size = icon_target_sizes.get(sq_type, 1.4)
				spr.pixel_size = target_size / max(tex_size.x, tex_size.y)
				node.add_child(spr)
				spr.owner = root

		if z == h - 1 and x > 0: x -= 1
		elif x == 0 and z > 0: z -= 1
		elif z == 0 and x < w - 1: x += 1
		elif x == w - 1 and z < h - 1: z += 1

	var static_body = StaticBody3D.new()
	static_body.name = "BoardFloor"
	var phys_mat = PhysicsMaterial.new()
	phys_mat.bounce = 0.35
	phys_mat.friction = 0.7
	static_body.physics_material_override = phys_mat
	
	var col_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	var playfield_width = w * spacing
	var playfield_depth = h * spacing
	box_shape.size = Vector3(playfield_width, 1.0, playfield_depth)
	col_shape.shape = box_shape
	col_shape.position = Vector3(0, 0.1 - 0.5, 0)
	
	static_body.add_child(col_shape)
	board.add_child(static_body)
	col_shape.owner = root
	static_body.owner = root
	
	var base_plane = MeshInstance3D.new()
	base_plane.name = "BasePlane"
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(playfield_width, playfield_depth)
	base_plane.mesh = plane_mesh
	base_plane.position = Vector3(0, 0, 0)
	var bp_mat = StandardMaterial3D.new()
	bp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bp_mat.albedo_color = Color.BLACK
	plane_mesh.surface_set_material(0, bp_mat)
	board.add_child(base_plane)
	base_plane.owner = root
	
	var wall_thickness = 10.0
	var wall_height = 20.0
	var wall_y = 10.0
	
	var wall_top = CollisionShape3D.new()
	var wt_shape = BoxShape3D.new()
	wt_shape.size = Vector3(playfield_width, wall_height, wall_thickness)
	wall_top.shape = wt_shape
	wall_top.position = Vector3(0, wall_y, -playfield_depth/2.0 - wall_thickness/2.0)
	static_body.add_child(wall_top)
	wall_top.owner = root
	
	var wall_bottom = CollisionShape3D.new()
	var wb_shape = BoxShape3D.new()
	wb_shape.size = Vector3(playfield_width, wall_height, wall_thickness)
	wall_bottom.shape = wb_shape
	wall_bottom.position = Vector3(0, wall_y, playfield_depth/2.0 + wall_thickness/2.0)
	static_body.add_child(wall_bottom)
	wall_bottom.owner = root
	
	var wall_left = CollisionShape3D.new()
	var wl_shape = BoxShape3D.new()
	wl_shape.size = Vector3(wall_thickness, wall_height, playfield_depth)
	wall_left.shape = wl_shape
	wall_left.position = Vector3(-playfield_width/2.0 - wall_thickness/2.0, wall_y, 0)
	static_body.add_child(wall_left)
	wall_left.owner = root
	
	var wall_right = CollisionShape3D.new()
	var wr_shape = BoxShape3D.new()
	wr_shape.size = Vector3(wall_thickness, wall_height, playfield_depth)
	wall_right.shape = wr_shape
	wall_right.position = Vector3(playfield_width/2.0 + wall_thickness/2.0, wall_y, 0)
	static_body.add_child(wall_right)
	wall_right.owner = root

	var new_packed = PackedScene.new()
	new_packed.pack(root)
	ResourceSaver.save(new_packed, scene_path)
	print("Board generation complete.")
