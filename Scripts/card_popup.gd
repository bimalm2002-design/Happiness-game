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
	"participate": preload("res://Assets/UI/card_buttons/participate button.svg")
}

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

func _ready():
	hide()
	bg_dim.modulate.a = 0
	rays.modulate.a = 0
	
	tap_area.gui_input.connect(_on_tap_area_input)
	
	if back_face:
		back_face.gui_input.connect(_on_back_face_input)
	if bg_dim:
		bg_dim.gui_input.connect(_on_back_face_input)
		
	if stock_input:
		stock_input.text_changed.connect(_on_stock_input_changed)

func _input(event: InputEvent):
	if not visible: return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_flipped:
			flip_card()
			get_viewport().set_input_as_handled()
		elif current_card_data.get("buttons", []).is_empty():
			get_viewport().set_input_as_handled()
			_on_accept("dismiss")

func _on_tap_area_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_flipped:
			flip_card()

func _on_back_face_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_flipped and current_card_data.get("buttons", []).is_empty():
			_on_accept("dismiss")

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
	if "BTC" in desc or "බිට්කොයින්" in desc:
		return "BTC"
	elif "Techno" in desc:
		return "Techno"
	elif "සිකුරු" in desc:
		return "සිකුරු"
	elif "කිරිකොකා" in desc:
		return "කිරිකොකා"
	return ""

func _get_owned_stock_qty(card_data: Dictionary) -> int:
	if not PlayerData or not PlayerData.financials: return 0
	var ticker = _get_stock_ticker(card_data)
	if ticker.is_empty(): return 0
	for s in PlayerData.financials.stocks:
		if s.get("ticker", "") == ticker or ticker in s.get("ticker", ""):
			return int(s.get("qty", 0))
	return 0

func show_card_data(card_data: Dictionary):
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
		# buy, invest, party, participate
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
		hide_card()

func _show_loan_popup(shortage: int):
	var dialog = ConfirmationDialog.new()
	dialog.title = "Insufficient Cash"
	var loan_needed = ceil(shortage / 10000.0) * 10000
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
		PlayerData.financials.update_cash(loan_amount)
		PlayerData.financials.set_fixed_liability("bank_loan", PlayerData.financials.bank_loan + loan_amount)
		PlayerData.financials.add_expense("බැංකු ණය", loan_amount * 0.1)
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
