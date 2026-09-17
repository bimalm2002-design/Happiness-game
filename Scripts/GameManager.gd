extends Node

var is_moving = false

func on_dice_thrown():
	print("Dice thrown! Waiting for it to settle...")

func dice_rolled(result: int):
	print("Dice rolled: ", result)
	if is_moving: return
	is_moving = true
	
	var cam = get_node_or_null("../MainCamera")
	if cam and cam.has_method("set_state"):
		cam.set_state(1) # State.FOLLOW = 1
		
	# Wait for camera to zoom in
	await get_tree().create_timer(1.2).timeout
	
	var avatar = get_node_or_null("../RatAvatar")
	if avatar:
		var raw_board_nodes = []
		var board = get_node_or_null("../Board")
		if board:
			var all_meshes = []
			var to_check = board.get_children()
			while to_check.size() > 0:
				var c = to_check.pop_front()
				if c is MeshInstance3D:
					all_meshes.append(c)
				to_check.append_array(c.get_children())
			
			# Sort by path_index metadata to restore correct path order
			all_meshes.sort_custom(func(a, b): return a.get_meta("path_index", 999) < b.get_meta("path_index", 999))
			
			# Add to path
			for m in all_meshes:
				raw_board_nodes.append(m)
					
		if raw_board_nodes.size() > 0:
			avatar.move_spaces(result, raw_board_nodes)
			await avatar.move_finished
		
		# Wait a bit after move finishes
		await get_tree().create_timer(1.0).timeout
		
		if cam and cam.has_method("set_state"):
			cam.set_state(0) # State.OVERVIEW = 0
			# Wait for the camera to finish its 1.0 second tween back to the center!
			# If we reset the dice immediately, it gets placed relative to the avatar's last position!
			await get_tree().create_timer(1.0).timeout
			
		# Reset dice position for next throw safely
		var dice = get_node_or_null("../Dice3D")
		if dice:
			if dice.has_method("reset_dice"):
				dice.reset_dice()
			
		is_moving = false
