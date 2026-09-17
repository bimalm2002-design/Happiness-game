@tool
extends EditorScript

func _run():
	var scene = load("res://Scenes/NewMain.tscn")
	var root = scene.instantiate()
	var board = root.get_node("Board")
	
	print("--- CHILDREN OF BOARD ---")
	for child in board.get_children():
		print(child.name, " - ", child.get_class())

