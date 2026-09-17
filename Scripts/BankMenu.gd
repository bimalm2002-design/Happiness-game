extends TextureButton

@export var borrow_btn_path: NodePath
@export var repay_btn_path: NodePath

var borrow_btn: Button
var repay_btn: Button
var is_dragging = false

func _ready():
	if has_node(borrow_btn_path):
		borrow_btn = get_node(borrow_btn_path)
	if has_node(repay_btn_path):
		repay_btn = get_node(repay_btn_path)
		
	# Connect to standard mouse events if needed, but we'll override gui_input
	pass

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Mouse pressed, show menu
				is_dragging = true
				if borrow_btn: borrow_btn.show()
				if repay_btn: repay_btn.show()
			else:
				# Mouse released, execute action if hovering over a button
				is_dragging = false
				
				if borrow_btn and borrow_btn.visible and _is_mouse_over(borrow_btn):
					print("ACTION: Borrow selected!")
					# Trigger borrow logic here
					
				if repay_btn and repay_btn.visible and _is_mouse_over(repay_btn):
					print("ACTION: Repay selected!")
					# Trigger repay logic here
					
				# Hide menu
				if borrow_btn: borrow_btn.hide()
				if repay_btn: repay_btn.hide()

func _process(delta):
	if is_dragging:
		# Optional: Add hover highlighting logic here
		if borrow_btn and borrow_btn.visible:
			if _is_mouse_over(borrow_btn):
				borrow_btn.modulate = Color(1.2, 1.2, 1.2) # Highlight
			else:
				borrow_btn.modulate = Color(1.0, 1.0, 1.0)
				
		if repay_btn and repay_btn.visible:
			if _is_mouse_over(repay_btn):
				repay_btn.modulate = Color(1.2, 1.2, 1.2)
			else:
				repay_btn.modulate = Color(1.0, 1.0, 1.0)

func _is_mouse_over(control: Control) -> bool:
	var local_mouse_pos = control.get_local_mouse_position()
	var rect = Rect2(Vector2.ZERO, control.size)
	return rect.has_point(local_mouse_pos)
