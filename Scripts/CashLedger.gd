extends Control

var main_panel: Control
var bg_dim: ColorRect
var is_animating: bool = false
var panel_target_pos: Vector2 = Vector2(0, 10)
var panel_start_pos: Vector2 = Vector2(-700, 10)

var font = preload("res://LilitaOne-Regular.ttf")

func _ready():
	main_panel = get_node_or_null("%MainPanel")
	# If %MainPanel doesn't exist yet because it's not unique in the old scene, let's just find it by name
	if not main_panel:
		main_panel = get_node_or_null("MainPanel")
		
	bg_dim = get_node_or_null("BackgroundDim")
	
	if main_panel:
		# Calculate actual centered target pos based on the real viewport size.
		var panel_size = main_panel.size
		if panel_size == Vector2.ZERO:
			panel_size = Vector2(588, 664) # Fallback to our SVG dimensions just in case
			
		var viewport_size = get_viewport_rect().size
		panel_target_pos = (viewport_size - panel_size) / 2.0
		panel_start_pos = Vector2(-panel_size.x - 50, panel_target_pos.y)
		main_panel.position = panel_start_pos
		
	if bg_dim:
		bg_dim.color.a = 0.0
		bg_dim.gui_input.connect(_on_bg_gui_input)

	if get_node_or_null("%CloseButton"):
		get_node_or_null("%CloseButton").pressed.connect(toggle)
	elif get_node_or_null("CloseButton"):
		get_node_or_null("CloseButton").pressed.connect(toggle)
		
	# Try to connect to main UI button automatically
	var cash_btn = get_parent().get_node_or_null("BottomLeftMenu/CashLedgerButton")
	if cash_btn:
		cash_btn.pressed.connect(toggle)
		
	get_viewport().size_changed.connect(_on_viewport_size_changed)
		
	hide()

	# Initial render
	if PlayerData and PlayerData.financials:
		PlayerData.financials.changed.connect(_on_player_data_changed)
		_on_player_data_changed()

func _on_player_data_changed():
	if PlayerData and PlayerData.financials:
		render_ledger(PlayerData.financials.cash, PlayerData.ledger_history)

func _on_viewport_size_changed():
	if main_panel:
		var panel_size = main_panel.size
		if panel_size == Vector2.ZERO:
			panel_size = Vector2(588, 664)
		var viewport_size = get_viewport_rect().size
		panel_target_pos = (viewport_size - panel_size) / 2.0
		panel_start_pos = Vector2(-panel_size.x - 50, panel_target_pos.y)
		
		if visible and not is_animating:
			main_panel.position = panel_target_pos
		elif not visible and not is_animating:
			main_panel.position = panel_start_pos

func _on_bg_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if visible and not is_animating:
			toggle()
			get_viewport().set_input_as_handled()

func toggle():
	if is_animating:
		return
		
	is_animating = true
	var tween = create_tween()
	tween.set_parallel(true)
	
	if visible:
		# Close
		if main_panel:
			tween.tween_property(main_panel, "position", panel_start_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		if bg_dim:
			tween.tween_property(bg_dim, "color:a", 0.0, 0.3)
		tween.chain().tween_callback(func():
			hide()
			is_animating = false
		)
	else:
		# Open
		show()
		if main_panel:
			tween.tween_property(main_panel, "position", panel_target_pos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if bg_dim:
			tween.tween_property(bg_dim, "color:a", 0.4, 0.3)
		tween.chain().tween_callback(func():
			is_animating = false
		)

func render_ledger(total_cash: int, entries: Array):
	var cash_lbl = get_node_or_null("%TotalCashLabel")
	if not cash_lbl: cash_lbl = get_node_or_null("MainPanel/VBoxContainer/Control/VBoxContainer/TotalCashLabel")
	if cash_lbl:
		cash_lbl.text = format_money(total_cash) + " LKR"
		
	var list = get_node_or_null("%EntriesList")
	if not list: list = get_node_or_null("MainPanel/VBoxContainer/MarginContainer/ScrollContainer/EntriesList")
	if list:
		for child in list.get_children():
			child.queue_free()
		
		var display_entries = entries.duplicate()
		display_entries.reverse()
		
		for entry in display_entries:
			var is_income = entry.get("type", "income") == "income"
			var desc = entry.get("desc", "Unknown")
			var amount = entry.get("amount", 0)
			
			var card = PanelContainer.new()
			var style = StyleBoxFlat.new()
			style.bg_color = Color(62/255.0, 169/255.0, 114/255.0) if is_income else Color(255/255.0, 30/255.0, 32/255.0)
			style.corner_radius_top_left = 20
			style.corner_radius_bottom_left = 20
			style.corner_radius_top_right = 20
			style.corner_radius_bottom_right = 20
			card.add_theme_stylebox_override("panel", style)
			card.custom_minimum_size = Vector2(0, 40)
			list.add_child(card)
			
			var margin = MarginContainer.new()
			margin.add_theme_constant_override("margin_left", 20)
			margin.add_theme_constant_override("margin_right", 20)
			card.add_child(margin)
			
			var row = HBoxContainer.new()
			margin.add_child(row)
			
			var title_lbl = Label.new()
			title_lbl.text = desc
			title_lbl.add_theme_font_override("font", font)
			title_lbl.add_theme_font_size_override("font_size", 22)
			title_lbl.add_theme_color_override("font_color", Color.WHITE)
			title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row.add_child(title_lbl)
			
			var amount_lbl = Label.new()
			amount_lbl.text = ("+" if is_income and amount > 0 else "") + format_money(amount)
			amount_lbl.add_theme_font_override("font", font)
			amount_lbl.add_theme_font_size_override("font_size", 24)
			amount_lbl.add_theme_color_override("font_color", Color.WHITE)
			amount_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			amount_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			row.add_child(amount_lbl)

func format_money(value: int) -> String:
	var s = str(abs(value))
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count == 3 and i > 0:
			result = " " + result
			count = 0
	if value < 0:
		result = "-" + result
	return result
