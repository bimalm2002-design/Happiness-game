
extends SceneTree

func _init():
	var file = FileAccess.open("H:/Game development/Happiness/UI elements/Quick JSON/02.json", FileAccess.READ)
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	if err != OK:
		print("JSON Error")
		quit()
		return
	
	var data = json.data
	var colors = {
		"rgb(74, 130, 251)": "stock",
		"rgb(89, 212, 52)": "opportunity",
		"rgb(207, 106, 232)": "flash",
		"rgb(251, 50, 50)": "oops",
		"rgb(132, 132, 132)": "monopoly",
		"rgb(252, 222, 26)": "go"
	}
	
	var queue = [data.structure]
	var rects = []
	while queue.size() > 0:
		var node = queue.pop_front()
		if typeof(node) == TYPE_DICTIONARY:
			if node.has("type") and node.type == "RECTANGLE" and node.has("styles") and node.styles.has("bg"):
				var c = node.styles.bg
				if colors.has(c):
					c = colors[c]
				if c != "rgb(110, 57, 15)" and c != "rgb(255, 255, 255)":
					var w = 0
					var h = 0
					if node.has("size"):
						w = node.size.w
						h = node.size.h
					var x = 0
					var y = 0
					if node.has("absoluteBoundingBox"):
						x = node.absoluteBoundingBox.x
						y = node.absoluteBoundingBox.y
					rects.append({"name": node.name, "w": w, "h": h, "c": c, "x": x, "y": y})
			if node.has("children"):
				for child in node.children:
					queue.push_back(child)
					
	var out = FileAccess.open("H:/Game development/Happiness/Project folder/board_rects.txt", FileAccess.WRITE)
	for r in rects:
		out.store_line(r.name + " " + str(r.w) + "x" + str(r.h) + " @ " + str(r.x) + "," + str(r.y) + " color: " + r.c)
	out.close()
	print("Done parsing")
	quit()

