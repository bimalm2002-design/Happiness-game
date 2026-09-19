extends CanvasLayer

signal card_accepted(card_data: Dictionary)
signal card_declined(card_data: Dictionary)

@onready var rotator = $CardCenter/Rotator
@onready var front_face = $CardCenter/Rotator/FrontFace
@onready var back_face = $CardCenter/Rotator/BackFace
@onready var title_lbl = $CardCenter/Rotator/BackFace/TitleLabel
@onready var desc_lbl = get_node_or_null("CardCenter/Rotator/BackFace/InnerPanel/Margin/VBox/DescLabel")
@onready var values_lbl = get_node_or_null("CardCenter/Rotator/BackFace/InnerPanel/Margin/VBox/ValuesLabel")
@onready var stock_input_row = get_node_or_null("CardCenter/Rotator/BackFace/InnerPanel/Margin/VBox/StockInputRow")
@onready var stock_input = get_node_or_null("CardCenter/Rotator/BackFace/InnerPanel/Margin/VBox/StockInputRow/SharesInput")
@onready var stock_cost_lbl = get_node_or_null("CardCenter/Rotator/BackFace/InnerPanel/Margin/VBox/StockInputRow/TotalCostLabel")
@onready var buttons_container = get_node_or_null("CardCenter/Rotator/BackFace/InnerPanel/Margin/VBox/ButtonsContainer")
@onready var anim_player = $AnimationPlayer
@onready var bg_dim = $ColorRect
@onready var rays = $Rays
@onready var tap_area = $CardCenter/Rotator/FrontFace/TapArea
@onready var front_title = $CardCenter/Rotator/FrontFace/TitleLabel
@onready var front_subtitle = $CardCenter/Rotator/FrontFace/SubtitleLabel
@onready var back_gradient = $CardCenter/Rotator/BackFace/Gradient
@onready var inner_panel = $CardCenter/Rotator/BackFace/InnerPanel

const BUTTON_TEXTURES = {
	"invest": preload("res://Assets/UI/card_buttons/Invest button.svg"),
	"buy": preload("res://Assets/UI/card_buttons/Buy button.svg"),
	"pass": preload("res://Assets/UI/card_buttons/pass button.svg"),
	"sell": preload("res://Assets/UI/card_buttons/sell button.svg"),
	"sell_greyed": preload("res://Assets/UI/card_buttons/sell button greyed.svg"),
	"party": preload("res://Assets/UI/card_buttons/party button.svg"),
	"ignore": preload("res://Assets/UI/card_buttons/ignore button.svg"),
	"participate": preload("res://Assets/UI/card_buttons/participate button.svg"),
	"ok": preload("res://Assets/UI/card_buttons/okay button.svg")
}

var hidden_timer_max = 60.0
var visible_timer_max = 60.0
var current_hidden_time = 0.0
var current_visible_time = 0.0
var is_counting_down = false
var visible_timer_label: Label = null

# Figma card colors (front & back base)
var base_colors = {
	"Opportunity": Color("#70B440"),
	"Oops": Color("#FF3335"),
	"Stock": Color("#4071B4"),
	"Flash": Color("#A345EE")
}

var is_flipped = false
var current_card_data: Dictionary = {}

func _process(delta):
	if visible and rays:
		rays.rotation -= delta * 0.1 # Marvel animation spin slower
	
	if is_counting_down and is_flipped:
		if current_hidden_time > 0:
			current_hidden_time -= delta
			if current_hidden_time <= 0:
				current_visible_time = visible_timer_max
				if visible_timer_label:
					visible_timer_label.text = str(ceil(current_visible_time))
					visible_timer_label.show()
		elif current_visible_time > 0:
			current_visible_time -= delta
			if visible_timer_label:
				visible_timer_label.text = str(ceil(current_visible_time))
			if current_visible_time <= 0:
				_handle_timeout()

func _ready():
	hide()
	bg_dim.modulate.a = 0
	rays.modulate.a = 0
	
	_load_timer_config()
	_create_timer_label()
	
	tap_area.gui_input.connect(_on_tap_area_input)
	
	if back_face:
		back_face.gui_input.connect(_on_back_face_input)
	if bg_dim:
		bg_dim.gui_input.connect(_on_back_face_input)
		
	if stock_input:
		stock_input.text_changed.connect(_on_stock_input_changed)

func _load_timer_config():
	if FileAccess.file_exists("res://countdown timer/config.txt"):
		var file = FileAccess.open("res://countdown timer/config.txt", FileAccess.READ)
		if file:
			var content = file.get_as_text()
			for line in content.split("\n"):
				var l = line.strip_edges()
				if l.begins_with("first_countdown="):
					hidden_timer_max = l.get_slice("=", 1).to_float()
				elif l.begins_with("second_countdown="):
					visible_timer_max = l.get_slice("=", 1).to_float()
			file.close()

func _create_timer_label():
	visible_timer_label = Label.new()
	visible_timer_label.add_theme_font_size_override("font_size", 64)
	visible_timer_label.add_theme_color_override("font_color", Color.WHITE)
	visible_timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	visible_timer_label.add_theme_constant_override("outline_size", 12)
	visible_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	visible_timer_label.hide()
	add_child(visible_timer_label)
	visible_timer_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	visible_timer_label.offset_top = 40

func _handle_timeout():
	is_counting_down = false
	if visible_timer_label: visible_timer_label.hide()
	var cid = str(current_card_data.get("id", ""))
	if cid in ["37", "40"]:
		_on_button_clicked("party")
	elif cid == "48":
		_on_button_clicked("buy")
	elif cid in ["15", "16", "17", "18", "19", "22", "26", "27", "30", "32", "33", "34", "35", "36", "38", "39", "41", "42", "43", "44", "46", "47", "49", "50", "51", "53"]:
		_on_button_clicked("ok")
	else:
		_on_button_clicked("pass")

func _input(event: InputEvent):
	if not visible: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_flipped:
			flip_card()
			get_viewport().set_input_as_handled()

func _on_tap_area_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_flipped:
			flip_card()

func _on_back_face_input(event: InputEvent):
	pass

func _on_stock_input_changed(new_text: String):
	var qty = new_text.to_int()
	var price = int(current_card_data.get("price", 0))
	if stock_cost_lbl:
		stock_cost_lbl.text = "for %s/=" % _format_money(qty * price)

func _format_money(value) -> String:
	if typeof(value) == TYPE_STRING and not value.is_valid_int() and not value.is_valid_float():
		return value
	var v := int(value)
	var s := str(abs(v))
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count == 3 and i > 0:
			result = "," + result
			count = 0
	if v < 0:
		result = "-" + result
	return result

func _get_stock_ticker(card_data: Dictionary) -> String:
	var desc = card_data.get("back_desc", "")
	var cid = int(card_data.get("id", 0))
	if (cid >= 54 and cid <= 58) or "BTC" in desc or "බිට්කොයින්" in desc:
		return "බිට්කොයින්"
	elif (cid >= 59 and cid <= 62) or "Techno" in desc or "ටෙක්නෝ" in desc:
		return "ටෙක්නෝ"
	elif (cid >= 63 and cid <= 67) or "සිකුරු" in desc:
		return "සිකුරු සබන්"
	elif (cid >= 68 and cid <= 73) or "කිරිකොකා" in desc:
		return "කිරිකොකා"
	return ""

func _get_owned_stock_qty(card_data: Dictionary) -> int:
	if not PlayerData or not PlayerData.financials: return 0
	var ticker = _get_stock_ticker(card_data)
	if ticker.is_empty(): return 0
	for s in PlayerData.financials.stocks:
		var s_ticker = str(s.get("ticker", ""))
		if s_ticker == ticker or ticker in s_ticker or s_ticker in ticker:
			return int(s.get("qty", 0))
	return 0

func show_card_data(card_data: Dictionary):
	is_counting_down = false
	if visible_timer_label: visible_timer_label.hide()
	current_card_data = card_data
	
	var type: String = card_data.get("type", "Opportunity")
	var base_c: Color = base_colors.get(type, Color.WHITE)
	
	# ---------- FRONT ----------
	front_title.text = card_data.get("front_title", type)
	front_subtitle.text = ""
	
	if front_face.has_theme_stylebox("panel"):
		var sb = front_face.get_theme_stylebox("panel").duplicate()
		if sb is StyleBoxFlat:
			sb.bg_color = base_c
			front_face.add_theme_stylebox_override("panel", sb)
	
	# ---------- BACK ----------
	if back_face.has_theme_stylebox("panel"):
		var sb = back_face.get_theme_stylebox("panel").duplicate()
		if sb is StyleBoxFlat:
			sb.bg_color = base_c
			back_face.add_theme_stylebox_override("panel", sb)
	
	back_gradient.texture = null
	back_gradient.visible = false
	
	var category_name = type
	if type == "Oops": category_name = "Oops!"
	elif type == "Stock": category_name = "Stocks"
	title_lbl.text = category_name
	
	if desc_lbl:
		desc_lbl.text = card_data.get("back_desc", "")
	if values_lbl:
		var val_text = _build_values_bbcode(card_data)
		values_lbl.text = val_text
		if val_text.is_empty():
			values_lbl.hide()
		else:
			values_lbl.show()
	
	# Configure Stock Input Row
	if type == "Stock" and stock_input_row:
		stock_input_row.show()
		var default_qty = 1
		if stock_input:
			stock_input.text = str(default_qty)
		if stock_cost_lbl:
			var p = int(card_data.get("price", 0))
			stock_cost_lbl.text = "for %s/=" % _format_money(default_qty * p)
	elif stock_input_row:
		stock_input_row.hide()
		
	# Configure Solar Panel Card (CID 52) Unit Picker
	var cid = str(card_data.get("id", ""))
	if cid == "52":
		_setup_solar_panel_picker()
	elif solar_options_container:
		solar_options_container.hide()
	
	# Build dynamic buttons in ButtonsContainer
	_populate_card_buttons()
	
	is_flipped = false
	front_face.visible = true
	back_face.visible = false
	rotator.scale = Vector2.ONE
	
	# Rays color matches the card type
	var ray_color = base_c
	ray_color.a = 0.5
	var mat = rays.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("ray_color", ray_color)
	
	show()
	_update_card_position(false)
	bg_dim.visible = false
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(rays, "modulate:a", 1.0, 0.3)
	
	anim_player.play("pop_up")

func _populate_card_buttons():
	if not buttons_container: return
	
	for child in buttons_container.get_children():
		child.queue_free()
	
	var buttons = current_card_data.get("buttons", [])
	var cid = str(current_card_data.get("id", ""))
	if buttons.is_empty() and cid in ["15", "16", "17", "18", "19", "22", "26", "27", "30", "32", "33", "34", "35", "36", "38", "39", "41", "42", "43", "44", "46", "47", "49", "50", "51", "53"]:
		buttons = ["ok"]
		current_card_data["buttons"] = buttons
		
	var type = current_card_data.get("type", "")
	
	for btn_name in buttons:
		var btn = TextureButton.new()
		# Sleek, proportional UI sizing matching exact measurements from Screenshot 2026-09-18 221116.png
		btn.custom_minimum_size = Vector2(126, 35)
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var b_key = str(btn_name).to_lower()
		var is_disabled = false
		
		if b_key == "sell":
			if type == "Stock":
				var owned = _get_owned_stock_qty(current_card_data)
				if owned > 0:
					btn.texture_normal = BUTTON_TEXTURES["sell"]
				else:
					btn.texture_normal = BUTTON_TEXTURES["sell_greyed"]
					is_disabled = true
					btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
			elif type == "Flash":
				var can_sell = _can_execute_flashcard(str(current_card_data.get("id", "")))
				if can_sell:
					btn.texture_normal = BUTTON_TEXTURES["sell"]
				else:
					btn.texture_normal = BUTTON_TEXTURES["sell_greyed"]
					is_disabled = true
					btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
			else:
				btn.texture_normal = BUTTON_TEXTURES["sell"]
		else:
			if BUTTON_TEXTURES.has(b_key):
				btn.texture_normal = BUTTON_TEXTURES[b_key]
		
		btn.disabled = is_disabled
		
		# Micro-interactions for tactile visual feedback
		if not is_disabled:
			btn.mouse_entered.connect(func(): btn.modulate = Color(1.08, 1.08, 1.08))
			btn.mouse_exited.connect(func(): btn.modulate = Color.WHITE)
			btn.button_down.connect(func(): btn.modulate = Color(0.92, 0.92, 0.92))
			btn.button_up.connect(func(): btn.modulate = Color.WHITE)
		
		btn.pressed.connect(_on_button_clicked.bind(b_key))
		buttons_container.add_child(btn)

func _on_button_clicked(action_name: String):
	if current_card_data.get("type") != "Stock" or action_name in ["pass", "ignore", "ok"]:
		is_counting_down = false
		if visible_timer_label: visible_timer_label.hide()
		
	current_card_data["action"] = action_name
	
	if action_name in ["pass", "ignore"]:
		_on_decline()
	elif action_name == "sell":
		if current_card_data.get("type") == "Stock":
			var owned = _get_owned_stock_qty(current_card_data)
			var qty = stock_input.text.to_int() if stock_input else owned
			if qty <= 0: qty = owned
			qty = mini(qty, owned)
			current_card_data["sell_qty"] = qty
			current_card_data["selected_qty"] = qty
			current_card_data["is_sell_action"] = true
		_on_accept(action_name)
	else:
		# ok, buy, invest, party, participate
		if current_card_data.get("type") == "Stock":
			var qty = stock_input.text.to_int() if stock_input else 1
			if qty <= 0: qty = 1
			current_card_data["selected_qty"] = qty
		_on_accept(action_name)

func _build_values_bbcode(card_data: Dictionary) -> String:
	var type = card_data.get("type", "Opportunity")
	
	# For Stocks: display price, trading range, and shares owned dynamically
	if type == "Stock":
		var rows: Array[String] = []
		var price = card_data.get("price", 0)
		var lbl = "price per coin"
		var desc = card_data.get("back_desc", "")
		if "සමාගමේ" in desc or "සිකුරු" in desc or "කිරිකොකා" in desc:
			lbl = "cost per share"
		rows.append("[b]%s[/b] : %s/=" % [lbl, _format_money(price)])
		if card_data.has("range"):
			var r = card_data["range"]
			if r is Array and r.size() >= 2:
				rows.append("[b]Trading range[/b] : %s - %s/=" % [_format_money(r[0]), _format_money(r[1])])
		var owned = _get_owned_stock_qty(card_data)
		rows.append("[b]shares owned[/b] : %d" % owned)
		return "\n".join(rows)

	var raw_val = str(card_data.get("values", "")).trim_prefix("•").strip_edges()
	
	# If raw_val is None or empty, return empty string to completely hide the Values section label
	if raw_val.is_empty() or raw_val == "None":
		return ""
		
	# Format pipe "|" as newlines "\n" so multi-item lines display on separate lines
	var parts = raw_val.split("|")
	var formatted_rows: Array[String] = []
	for p in parts:
		var clean_p = p.strip_edges().trim_prefix("•").strip_edges()
		if not clean_p.is_empty() and clean_p != "None":
			formatted_rows.append(clean_p)
			
	return "\n".join(formatted_rows)

func flip_card():
	if is_flipped: return
	is_flipped = true
	_load_timer_config()
	current_hidden_time = hidden_timer_max
	current_visible_time = visible_timer_max
	is_counting_down = true
	
	var tw = create_tween()
	tw.tween_property(rays, "modulate:a", 0.0, 0.3)
	anim_player.play("flip_card")
	await anim_player.animation_finished

func hide_card():
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(rays, "modulate:a", 0.0, 0.3)
	tw.tween_property(rotator, "modulate:a", 0.0, 0.3)
	await tw.finished
	hide()
	rotator.modulate.a = 1.0

var solar_options_container: VBoxContainer = null
var solar_option_cards: Array = []
var selected_solar_index: int = 1

func _setup_solar_panel_picker():
	if values_lbl:
		values_lbl.hide()
		
	if not solar_options_container:
		solar_options_container = VBoxContainer.new()
		solar_options_container.name = "SolarOptionsContainer"
		solar_options_container.add_theme_constant_override("separation", 6)
		
		var options_data = [
			{"units": 100, "cost": 3000, "cashflow": 300},
			{"units": 500, "cost": 10000, "cashflow": 1000},
			{"units": 1000, "cost": 15000, "cashflow": 1500}
		]
		
		solar_option_cards.clear()
		
		for idx in range(options_data.size()):
			var card_btn = Button.new()
			card_btn.custom_minimum_size = Vector2(0, 42)
			card_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			card_btn.flat = true
			
			card_btn.pressed.connect(_select_solar_option.bind(idx))
			
			solar_options_container.add_child(card_btn)
			solar_option_cards.append(card_btn)
			
		var parent_node = buttons_container.get_parent() if buttons_container else back_face
		if parent_node:
			parent_node.add_child(solar_options_container)
			if buttons_container:
				parent_node.move_child(solar_options_container, buttons_container.get_index())
				
	solar_options_container.show()
	_select_solar_option(1)

func _select_solar_option(index: int):
	selected_solar_index = index
	var options_data = [
		{"units": 100, "cost": 3000, "cashflow": 300},
		{"units": 500, "cost": 10000, "cashflow": 1000},
		{"units": 1000, "cost": 15000, "cashflow": 1500}
	]
	
	var chosen = options_data[index]
	current_card_data["selected_cost"] = chosen["cost"]
	current_card_data["selected_cashflow"] = chosen["cashflow"]
	current_card_data["selected_units"] = chosen["units"]
	current_card_data["cost"] = chosen["cost"]
	current_card_data["cashflow"] = chosen["cashflow"]
	
	for idx in range(solar_option_cards.size()):
		var btn = solar_option_cards[idx] as Button
		if not btn: continue
		var opt = options_data[idx]
		var is_selected = (idx == index)
		
		var sb = StyleBoxFlat.new()
		sb.corner_radius_top_left = 8
		sb.corner_radius_top_right = 8
		sb.corner_radius_bottom_right = 8
		sb.corner_radius_bottom_left = 8
		sb.content_margin_left = 12
		sb.content_margin_right = 12
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		
		if is_selected:
			sb.bg_color = Color(0.12, 0.28, 0.18, 0.92)
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 2
			sb.border_color = Color(0.3, 0.95, 0.5)
			btn.text = "✓  %d Units  —  Cost: %s/=  |  Cashflow: +%s/=" % [opt["units"], _format_money(opt["cost"]), _format_money(opt["cashflow"])]
		else:
			sb.bg_color = Color(0.0, 0.0, 0.0, 0.25)
			sb.border_width_left = 1
			sb.border_width_top = 1
			sb.border_width_right = 1
			sb.border_width_bottom = 1
			sb.border_color = Color(1.0, 1.0, 1.0, 0.25)
			btn.text = "   %d Units  —  Cost: %s/=  |  Cashflow: +%s/=" % [opt["units"], _format_money(opt["cost"]), _format_money(opt["cashflow"])]
			
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		btn.add_theme_font_override("font", preload("res://LilitaOne-Regular.ttf"))
		btn.add_theme_font_size_override("font_size", 13)
		btn.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6) if is_selected else Color(0.9, 0.9, 0.9))

func _on_accept(action: String = "accept"):
	var cost = 0
	
	# Determine cost based on custom values
	if current_card_data.has("values") and current_card_data["values"] is Dictionary:
		var vals = current_card_data["values"]
		if vals.has("Cost"):
			cost = int(vals["Cost"])
		elif vals.has("Total Investment"):
			cost = int(vals["Total Investment"])
			if vals.has("Downpayment"):
				cost = int(vals["Downpayment"])
				
	if current_card_data.has("cost"): cost = current_card_data["cost"]
	if current_card_data.has("down_payment"): cost = current_card_data["down_payment"]
	if current_card_data.has("penalty"): cost = current_card_data["penalty"]
	if current_card_data.has("selected_cost"): cost = int(current_card_data["selected_cost"])
	
	if current_card_data.get("type") == "Stock" and action == "buy":
		var qty = stock_input.text.to_int() if stock_input else 1
		if qty <= 0: return
		cost = qty * int(current_card_data.get("price", 0))
		current_card_data["selected_qty"] = qty
	elif action == "sell":
		cost = 0 # Selling doesn't cost cash
	
	# Only force loan check if it's an expense or buy
	if cost > 0 and PlayerData and PlayerData.financials:
		var cash = PlayerData.financials.cash
		if cash < cost:
			_show_loan_popup(cost - cash)
			return

	var cid = str(current_card_data.get("id", ""))
	var is_free_op = (cid == "45")
	var prev_card_data = current_card_data.duplicate()

	emit_signal("card_accepted", prev_card_data)

	if is_free_op:
		_trigger_free_opportunity_flow()
	else:
		if current_card_data.get("type") == "Stock" and action in ["buy", "sell"]:
			# Real-time refresh of shares owned text label and dynamic button states
			if values_lbl:
				values_lbl.text = _build_values_bbcode(current_card_data)
			_populate_card_buttons()
			_show_stock_transaction_toast(action)
		else:
			hide_card()

func _show_stock_transaction_toast(action: String):
	# Disable buttons in buttons_container for 0.3s to prevent accidental double/triple clicking
	for child in buttons_container.get_children():
		if child is BaseButton:
			child.disabled = true
			
	var toast = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.18, 0.12, 0.95) if action == "buy" else Color(0.22, 0.14, 0.08, 0.95)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.3, 0.9, 0.5, 0.9) if action == "buy" else Color(1.0, 0.65, 0.2, 0.9)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_right = 8
	sb.corner_radius_bottom_left = 8
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	toast.add_theme_stylebox_override("panel", sb)
	
	var lbl = Label.new()
	var qty = current_card_data.get("selected_qty", 1)
	var txt = "✓ Done! Bought %d share(s)" % qty if action == "buy" else "✓ Done! Sold %d share(s)" % qty
	lbl.text = txt
	lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6) if action == "buy" else Color(1.0, 0.8, 0.4))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.add_child(lbl)
	
	back_face.add_child(toast)
	toast.anchor_left = 0.5
	toast.anchor_right = 0.5
	toast.anchor_top = 0.78
	toast.anchor_bottom = 0.78
	toast.grow_horizontal = Control.GROW_DIRECTION_BOTH
	toast.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	toast.modulate.a = 0.0
	
	var tw = create_tween()
	tw.tween_property(toast, "modulate:a", 1.0, 0.15)
	tw.tween_interval(0.9)
	tw.tween_property(toast, "modulate:a", 0.0, 0.25)
	tw.tween_callback(toast.queue_free)
	
	get_tree().create_timer(0.3).timeout.connect(func():
		_populate_card_buttons()
	)

func _show_loan_popup(shortage: int):
	var dialog = ConfirmationDialog.new()
	dialog.title = "Insufficient Cash"
	var loan_needed = shortage
	dialog.dialog_text = "You don't have enough cash.\nYou need a loan of %s/=\nInterest is 10%% per Payday.\nDo you want to take this loan?" % _format_money(loan_needed)
	dialog.get_ok_button().text = "Take Loan"
	dialog.get_cancel_button().text = "Cancel"
	dialog.confirmed.connect(func():
		_take_loan_and_proceed(loan_needed)
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	add_child(dialog)
	dialog.popup_centered()

func _take_loan_and_proceed(loan_amount: int):
	if PlayerData and PlayerData.financials:
		PlayerData.financials.take_bank_loan(loan_amount)
		PlayerData.add_ledger_entry("income", "අනිවාර්ය බැංකු ණය", loan_amount)
	_on_accept()

func _can_execute_flashcard(cid: String) -> bool:
	if not PlayerData or not PlayerData.financials: return true
	var f = PlayerData.financials
	
	var has_asset = func(n: String):
		for a in f.real_estate_assets:
			if a.get("name", "") == n: return true
		for s in f.stocks:
			if s.get("ticker", "") == n: return true
		for i in f.incomes:
			if i.get("name", "") == n: return true
		return false

	if cid == "15" or cid == "18": return has_asset.call("Musical Show") or has_asset.call("Musical show") or has_asset.call("සංගීත ප්‍රසංගය") or has_asset.call("Card 14")
	if cid == "16" or cid == "17": return has_asset.call("Stage Drama") or has_asset.call("Stage drama") or has_asset.call("වේදිකා නාට්‍යය") or has_asset.call("Card 13")
	if cid == "19": return has_asset.call("Software Project") or has_asset.call("මෘදුකාංග ව්‍යාපෘතිය") or has_asset.call("Card 10")
	if cid == "20": return has_asset.call("Parking Lot") or has_asset.call("වාහන නැවතුම්පොළ") or has_asset.call("වාහන නැවතුම්පොල") or has_asset.call("Card 2")
	if cid == "21": return has_asset.call("Book Patent") or has_asset.call("පොතේ පේටන්ට් බලපත්‍රය") or has_asset.call("පොතේ පේටන්ට් අයිතිය") or has_asset.call("Card 11")
	if cid == "23": return has_asset.call("River Land") or has_asset.call("ගඟ අසල ඉඩම") or has_asset.call("Card 24")
	if cid == "25": return has_asset.call("Bicycle") or f.has_status_effect("has_bicycle")
	if cid == "31": return has_asset.call("Zoo Land") or has_asset.call("සත්ත්ව උද්‍යාන ඉඩම") or has_asset.call("සත්වෝද්‍යානය අසල ඉඩම") or has_asset.call("Card 29")
	
	return true

func _on_decline():
	var cid = str(current_card_data.get("id", ""))
	var is_free_op = (cid == "37" or cid == "40" or cid == "48")
	var prev_card_data = current_card_data.duplicate()
	
	emit_signal("card_declined", prev_card_data)
	
	if is_free_op:
		_trigger_free_opportunity_flow()
	else:
		hide_card()

func _trigger_free_opportunity_flow():
	show()
	_play_full_screen_marvel_rays()
	
	var op_card = CardManager.get_random_card_by_type("Opportunity")
	if op_card.is_empty():
		hide_card()
		return
		
	if rotator and rotator.modulate.a > 0.0:
		var fade_tw = create_tween()
		fade_tw.tween_property(rotator, "modulate:a", 0.0, 0.25)
		await fade_tw.finished
		
	show_card_data(op_card)
	
	if rotator:
		rotator.modulate.a = 0
		rotator.scale = Vector2(0.4, 0.4)
		var pop_tw = create_tween().set_parallel(true)
		pop_tw.tween_property(rotator, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		pop_tw.tween_property(rotator, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _play_full_screen_marvel_rays():
	if not rays: return
	
	var viewport_size = get_viewport().get_visible_rect().size
	rays.position = viewport_size / 2.0
	
	var max_dim = max(viewport_size.x, viewport_size.y) * 3.0
	rays.scale = Vector2(max_dim / 100.0, max_dim / 100.0)
	
	var ray_color = Color("#70B440") # Opportunity Green
	var mat = rays.material as ShaderMaterial
	if mat: mat.set_shader_parameter("ray_color", ray_color)
	
	rays.modulate.a = 0
	rays.visible = true
	
	if bg_dim:
		bg_dim.modulate.a = 0.85
		
	var tw = create_tween()
	tw.tween_property(rays, "modulate:a", 1.0, 0.4)

func _play_marvel_rays_animation():
	_play_full_screen_marvel_rays()

func _update_card_position(animate: bool = true, override_fs_open: Variant = null):
	if not rotator: return
	
	var is_open: bool = false
	if override_fs_open != null:
		is_open = bool(override_fs_open)
	else:
		var tree = get_tree()
		if tree and tree.root:
			var fs = tree.root.find_child("FinancialStatement", true, false) as Control
			if fs and fs.visible:
				is_open = true
				
	var target_x = 195.0 if is_open else 0.0
	var target_pos = Vector2(target_x, 0.0)
	
	if animate and is_node_ready() and visible:
		var tw = create_tween()
		tw.tween_property(rotator, "position", target_pos, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		rotator.position = target_pos
