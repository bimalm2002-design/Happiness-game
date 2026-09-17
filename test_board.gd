extends SceneTree

func _init():
	var scene = load("res://Scenes/NewMain.tscn")
	var root = scene.instantiate()
	
	var board = root.get_node("Board")
	print("--- BOARD NODES ---")
	for i in range(12):
		var sq = board.get_node("Square_" + str(i))
		print("Square_", i, " at ", sq.position)
		
	print("\n--- AVATAR MOVE TEST ---")
	var avatar = root.get_node("RatAvatar")
	print("Avatar initial position: ", avatar.position)
	
	print("\nIf Avatar is at Square_9 and moves 2 spaces (rolls a 2):")
	var current = 9
	for i in range(2):
		var next_idx = (current + 1) % 40
		var sq = board.get_node("Square_" + str(next_idx))
		print("Hop ", i+1, ": Avatar moves to Square_", next_idx, " at ", sq.position)
		current = next_idx
		
	quit()
