extends CanvasLayer

var main_panel: PanelContainer
var bg_dim: ColorRect
var is_animating: bool = false
var panel_target_pos: Vector2 = Vector2(0, 10)
var panel_start_pos: Vector2 = Vector2(-580, 10)

var data: PlayerFinancials

var font: FontFile
var sinhala_font: FontFile

func _ready():
	layer = 10
	main_panel = get_node_or_null("%MainPanel")
	bg_dim = get_node_or_null("BackgroundDim")
	
	if main_panel:
		main_panel.scale = Vector2(1, 1)
		main_panel.position = panel_start_pos
	if bg_dim:
		bg_dim.color.a = 0.0
		
	# Connect the background dim click to close the statement
	if bg_dim:
		bg_dim.gui_input.connect(_on_bg_gui_input)
		
	# Auto-connect to the Final Statement button
	var fs_btn = null
	if get_parent():
		fs_btn = get_parent().get_node_or_null("BottomLeftMenu/FinalStatementButton")
	if not fs_btn:
		var tree = get_tree()
		if tree and tree.root:
			fs_btn = tree.root.find_child("FinalStatementButton", true, false)
	if fs_btn:
		if not fs_btn.pressed.is_connected(toggle):
			fs_btn.pressed.connect(toggle)
		
	var close_btn = find_child("CloseButton", true, false)
	if close_btn:
		if close_btn.pressed.is_connected(toggle):
			close_btn.pressed.disconnect(toggle)
		close_btn.pressed.connect(toggle)
		
	font = load("res://LilitaOne-Regular.ttf")
	sinhala_font = load("res://Assets/Fonts/AbhayaLibre-Regular.ttf")
	
	# Use global PlayerData
	data = PlayerData.financials
		
	data.changed.connect(render)
	render()
		
	hide()

func _is_sinhala_text(t: String) -> bool:
	for c in t:
		var code = c.unicode_at(0)
		if code >= 0x0D80 and code <= 0x0DFF:
			return true
	return false

func _apply_thin_stroke(lbl: Label, outline_px: int = 2, outline_color: Color = Color(0, 0, 0, 0.85)):
	if lbl:
		lbl.add_theme_constant_override("outline_size", outline_px)
		lbl.add_theme_color_override("font_outline_color", outline_color)

func _stroke_node_labels(node: Node, outline_px: int = 2, stroke_color: Color = Color(0, 0, 0, 0.85)):
	if not node: return
	if node is Label:
		_apply_thin_stroke(node, outline_px, stroke_color)
	for child in node.get_children():
		_stroke_node_labels(child, outline_px, stroke_color)

func _on_bg_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if visible and not is_animating:
			toggle()
			get_viewport().set_input_as_handled()

var current_tween: Tween = null

func toggle():
	if current_tween and current_tween.is_running():
		current_tween.kill()
		
	is_animating = true
	current_tween = create_tween()
	current_tween.set_parallel(true)
	
	if visible:
		# Animate closing
		_notify_card_popup_shift(false)
		if main_panel:
			current_tween.tween_property(main_panel, "position", panel_start_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		if bg_dim:
			current_tween.tween_property(bg_dim, "color:a", 0.0, 0.3)
		
		current_tween.chain().tween_callback(func():
			hide()
			is_animating = false
		)
	else:
		# Animate opening
		show()
		_notify_card_popup_shift(true)
		if main_panel:
			current_tween.tween_property(main_panel, "position", panel_target_pos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if bg_dim:
			current_tween.tween_property(bg_dim, "color:a", 0.4, 0.3)
			
		current_tween.chain().tween_callback(func():
			is_animating = false
		)

func _notify_card_popup_shift(is_fs_opening: bool):
	var tree = get_tree()
	if tree and tree.root:
		var popup = tree.root.find_child("CardPopupLayer", true, false)
		if popup and popup.has_method("_update_card_position"):
			popup._update_card_position(true, is_fs_opening)

func format_money(amount: int) -> String:
	var s = str(amount)
	var res = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i != 0:
			res = " " + res
	return res

func clear_children(node_name: String):
	var node = get_node_or_null("%" + node_name)
	if node:
		for c in node.get_children():
			c.queue_free()
	return node

func create_row(parent: Control, left_text: String, right_text: String, font_size: int, l_color: Color, r_color: Color, right_w: int = 100):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 16)
	parent.add_child(row)
	
	var l_lbl = Label.new()
	l_lbl.text = left_text
	if _is_sinhala_text(left_text) and sinhala_font:
		l_lbl.add_theme_font_override("font", sinhala_font)
		l_lbl.add_theme_font_size_override("font_size", font_size + 3)
		l_lbl.add_theme_constant_override("outline_size", 1)
		l_lbl.add_theme_color_override("font_outline_color", l_color)
	else:
		l_lbl.add_theme_font_override("font", font)
		l_lbl.add_theme_font_size_override("font_size", font_size)
	l_lbl.add_theme_color_override("font_color", l_color)
	l_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l_lbl.clip_text = true
	row.add_child(l_lbl)
	
	var r_lbl = Label.new()
	r_lbl.text = right_text
	r_lbl.add_theme_font_override("font", font)
	r_lbl.add_theme_font_size_override("font_size", font_size)
	r_lbl.add_theme_color_override("font_color", r_color)
	r_lbl.custom_minimum_size = Vector2(right_w, 0)
	r_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_thin_stroke(r_lbl, 2, Color(0, 0, 0, 0.85))
	row.add_child(r_lbl)
	return row

func add_stock_row(parent: Control, name: String, qty: int, cost: int, blue_c: Color, orange_c: Color):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 16)
	parent.add_child(row)
	
	var l1 = Label.new()
	l1.text = name
	if _is_sinhala_text(name) and sinhala_font:
		l1.add_theme_font_override("font", sinhala_font)
		l1.add_theme_font_size_override("font_size", 16)
		l1.add_theme_constant_override("outline_size", 1)
		l1.add_theme_color_override("font_outline_color", blue_c)
	else:
		l1.add_theme_font_override("font", font)
		l1.add_theme_font_size_override("font_size", 14)
	l1.add_theme_color_override("font_color", blue_c)
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l1.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l1.clip_text = true
	row.add_child(l1)
	
	var l2 = Label.new()
	l2.text = str(qty); l2.add_theme_font_override("font", font); l2.add_theme_font_size_override("font_size", 14); l2.add_theme_color_override("font_color", blue_c)
	l2.custom_minimum_size = Vector2(70, 0)
	_apply_thin_stroke(l2, 2, Color(0, 0, 0, 0.85))
	row.add_child(l2)
	
	var l3 = Label.new()
	l3.text = format_money(cost); l3.add_theme_font_override("font", font); l3.add_theme_font_size_override("font_size", 14); l3.add_theme_color_override("font_color", orange_c)
	l3.custom_minimum_size = Vector2(100, 0)
	l3.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_thin_stroke(l3, 2, Color(0, 0, 0, 0.85))
	row.add_child(l3)

func render():
	if not main_panel or not data: return
	
	var blue_color = Color(86/255.0, 138/255.0, 214/255.0)
	var green_color = Color(41/255.0, 203/255.0, 20/255.0)
	var red_color = Color(255/255.0, 30/255.0, 32/255.0)
	var orange_color = Color(255/255.0, 112/255.0, 0/255.0)
	var black_color = Color.BLACK
	
	# Salary
	var sal_container = clear_children("SalaryContainer")
	if sal_container:
		create_row(sal_container, "Salary", format_money(data.salary), 14, blue_color, green_color)
		
	# Incomes
	var inc_container = clear_children("IncomeList")
	if inc_container:
		for inc in data.incomes:
			create_row(inc_container, inc["name"], format_money(inc["amount"]), 13, blue_color, green_color)
			
	# Expenses
	var exp_container = clear_children("ExpensesList")
	if exp_container:
		for exp in data.expenses:
			create_row(exp_container, exp["name"], format_money(exp["amount"]), 13, blue_color, red_color)
			
	# Assets - Stocks
	var st_container = clear_children("StocksList")
	if st_container:
		for st in data.stocks:
			add_stock_row(st_container, st["ticker"], st["qty"], st["cost_per_share"], blue_color, orange_color)
			
	# Assets - Real Estate
	var rea_container = clear_children("RealEstateAssetsList")
	if rea_container:
		for re in data.real_estate_assets:
			create_row(rea_container, re["name"], format_money(re["cost"]), 11, blue_color, orange_color)
			
	# Liabilities - Fixed
	var fl_container = clear_children("FixedLiabilitiesList")
	if fl_container:
		# User asked: if it's 0, should we hide it? Let's always show it with 0 for now as assumed.
		create_row(fl_container, "Housing loan", format_money(data.housing_loan), 11, blue_color, red_color)
		create_row(fl_container, "Car leasing", format_money(data.car_leasing), 11, blue_color, red_color)
		create_row(fl_container, "Bank loan", format_money(data.bank_loan), 11, blue_color, red_color)

	# Liabilities - Real Estate
	var rel_container = clear_children("RealEstateLiabilitiesList")
	if rel_container:
		for rel in data.real_estate_liabilities:
			create_row(rel_container, rel["name"], format_money(rel["amount"]), 11, blue_color, orange_color)

	_update_summary()

func _update_summary():
	# Calculate totals
	var total_income = data.salary
	var passive_income = 0
	for inc in data.incomes:
		total_income += inc["amount"]
		passive_income += inc["amount"]
		
	var total_expenses = 0
	for exp in data.expenses:
		total_expenses += exp["amount"]
		
	var payday = total_income - total_expenses
	
	# Update UI Labels
	var cash_lbl = get_node_or_null("%CashLabel")
	if cash_lbl:
		cash_lbl.text = format_money(data.cash)
		_apply_thin_stroke(cash_lbl, 2, Color(0, 0, 0, 0.85))
		if cash_lbl.get_parent():
			_stroke_node_labels(cash_lbl.get_parent(), 2, Color(0, 0, 0, 0.85))
	
	var tot_inc_lbl = get_node_or_null("%TotalIncomeLabel")
	if tot_inc_lbl:
		tot_inc_lbl.text = format_money(total_income)
		_apply_thin_stroke(tot_inc_lbl, 2, Color(0, 0, 0, 0.85))
		if tot_inc_lbl.get_parent():
			_stroke_node_labels(tot_inc_lbl.get_parent(), 2, Color(0, 0, 0, 0.85))
	
	var tot_exp_lbl = get_node_or_null("%TotalExpensesLabel")
	if tot_exp_lbl:
		tot_exp_lbl.text = format_money(total_expenses)
		_apply_thin_stroke(tot_exp_lbl, 2, Color(0, 0, 0, 0.85))
		if tot_exp_lbl.get_parent():
			_stroke_node_labels(tot_exp_lbl.get_parent(), 2, Color(0, 0, 0, 0.85))
	
	var pd_lbl = get_node_or_null("%PaydayLabel")
	if pd_lbl:
		pd_lbl.text = format_money(payday)
		_apply_thin_stroke(pd_lbl, 2, Color(0, 0, 0, 0.85))
		if pd_lbl.get_parent():
			_stroke_node_labels(pd_lbl.get_parent(), 2, Color(0, 0, 0, 0.85))
	
	# Update Rat Race
	var rr_exp = get_node_or_null("%RatRaceExpensesLabel")
	if rr_exp:
		rr_exp.text = "Total Expenses: " + format_money(total_expenses)
	
	var fill = get_node_or_null("%ProgressBarFill")
	var bg = get_node_or_null("%ProgressBarBG")
	var ptr = get_node_or_null("%PassiveIncomePointer")
	
	if fill and bg and ptr:
		var percent = 0.0
		if total_expenses > 0:
			percent = float(passive_income) / float(total_expenses)
		percent = clamp(percent, 0.0, 1.0)
		
		# Inner padding so orange bar progress sits inside the outer track stroke
		var padding = 3.0
		var bg_w = 220.0
		var bg_h = 24.0
		if bg.size.x > 0: bg_w = bg.size.x
		if bg.size.y > 0: bg_h = bg.size.y
			
		var avail_width = max(0.0, bg_w - (padding * 2.0))
		var fill_width = avail_width * percent
		
		fill.position = Vector2(padding, padding)
		fill.size = Vector2(fill_width, max(0.0, bg_h - (padding * 2.0)))
		fill.visible = (fill_width > 0)
		
		# Clamping and dynamic Left/Center/Right alignment for PassiveIncomePointer
		var bar_left_x = padding
		var bar_right_x = bg_w - padding
		var fill_edge_x = bar_left_x + fill_width
		
		var ptr_w = ptr.size.x if ptr.size.x > 0 else 120.0
		var ptr_target_x = fill_edge_x - (ptr_w / 2.0)
		
		if ptr_target_x < bar_left_x:
			ptr_target_x = bar_left_x
			ptr.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		elif ptr_target_x + ptr_w > bar_right_x:
			ptr_target_x = bar_right_x - ptr_w
			ptr.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		else:
			ptr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			
		ptr.position.x = ptr_target_x
		ptr.position.y = bg_h + 2.0
		ptr.text = "▲\nPassive Incomes\n" + format_money(passive_income)
