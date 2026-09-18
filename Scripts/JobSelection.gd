extends CanvasLayer

signal job_selected

var bg: ColorRect
var title_label: Label
var grid: GridContainer
var is_job_selected: bool = false
var selected_job_data: Dictionary = {}
var accept_btn: Button

# Panel for showing the selected job details
var details_panel: Panel
var details_label: RichTextLabel

func _ready():
	self.layer = 100 # Put it above everything else
	
	# Background
	bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Title
	title_label = Label.new()
	title_label.text = "Select a Job Card to Begin!"
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_label.position.y = 50
	bg.add_child(title_label)
	
	# CenterContainer for Grid
	var grid_center = CenterContainer.new()
	grid_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_child(grid_center)
	
	# Grid
	grid = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 30)
	grid.add_theme_constant_override("v_separation", 30)
	grid_center.add_child(grid)
	
	# Shuffle jobs
	var jobs = PlayerData.jobs.duplicate()
	jobs.shuffle()
	
	# Create 10 cards
	for i in range(10):
		var card_btn = Button.new()
		card_btn.custom_minimum_size = Vector2(150, 220)
		
		# Style
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color("#4071B4") # A nice blue for card back
		sb.set_corner_radius_all(10)
		sb.border_width_bottom = 5
		sb.border_color = Color("#1a3a6e")
		card_btn.add_theme_stylebox_override("normal", sb)
		
		var sb_hover = sb.duplicate()
		sb_hover.bg_color = sb.bg_color.lightened(0.2)
		card_btn.add_theme_stylebox_override("hover", sb_hover)
		
		var sb_pressed = sb.duplicate()
		sb_pressed.bg_color = sb.bg_color.darkened(0.2)
		card_btn.add_theme_stylebox_override("pressed", sb_pressed)
		
		card_btn.text = "Job Card"
		card_btn.add_theme_font_size_override("font_size", 20)
		
		card_btn.pressed.connect(func(): _on_card_clicked(card_btn, jobs[i]))
		grid.add_child(card_btn)
		
	# CenterContainer for Details Panel
	var panel_center = CenterContainer.new()
	panel_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_child(panel_center)
	
	# Details panel (hidden initially)
	details_panel = Panel.new()
	details_panel.custom_minimum_size = Vector2(500, 400)
	
	var ds = StyleBoxFlat.new()
	ds.bg_color = Color.WHITE
	ds.set_corner_radius_all(16)
	ds.shadow_color = Color(0,0,0,0.5)
	ds.shadow_size = 10
	details_panel.add_theme_stylebox_override("panel", ds)
	panel_center.hide() # Hide the container instead of just the panel
	panel_center.add_child(details_panel)
	
	details_label = RichTextLabel.new()
	details_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	details_label.offset_left = 20
	details_label.offset_top = 20
	details_label.offset_right = -20
	details_label.offset_bottom = -70
	details_label.bbcode_enabled = true
	details_label.add_theme_color_override("default_color", Color.BLACK)
	details_label.add_theme_font_size_override("normal_font_size", 22)
	details_panel.add_child(details_label)
	
	accept_btn = Button.new()
	accept_btn.text = "Start Game"
	accept_btn.custom_minimum_size = Vector2(200, 50)
	accept_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	accept_btn.position.y = -60
	
	var asb = StyleBoxFlat.new()
	asb.bg_color = Color("#70B440")
	asb.set_corner_radius_all(10)
	accept_btn.add_theme_stylebox_override("normal", asb)
	var asb_hover = asb.duplicate()
	asb_hover.bg_color = asb.bg_color.lightened(0.2)
	accept_btn.add_theme_stylebox_override("hover", asb_hover)
	var asb_pressed = asb.duplicate()
	asb_pressed.bg_color = asb.bg_color.darkened(0.2)
	accept_btn.add_theme_stylebox_override("pressed", asb_pressed)
	
	accept_btn.pressed.connect(_on_accept)
	details_panel.add_child(accept_btn)

func _format_money(value) -> String:
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

func _on_card_clicked(btn: Button, job_data: Dictionary):
	if is_job_selected: return
	is_job_selected = true
	selected_job_data = job_data
	
	# Animate card reveal
	var tw = create_tween()
	tw.tween_property(grid, "modulate:a", 0.0, 0.3)
	tw.tween_property(title_label, "modulate:a", 0.0, 0.3)
	await tw.finished
	grid.hide()
	
	# Show details
	var text = "[center][b][font_size=28]" + job_data["title"] + "[/font_size][/b][/center]\n\n"
	text += "[table=2]"
	text += "[cell][b]Salary:[/b][/cell][cell]" + _format_money(job_data["sal"]) + "/=[/cell]"
	text += "[cell][b]Savings (Cash):[/b][/cell][cell]" + _format_money(job_data["sal"] / 2) + "/=[/cell]"
	text += "[cell][b]Total Expenses:[/b][/cell][cell]" + _format_money(job_data["tExp"]) + "/=[/cell]"
	text += "[cell][b]Payday Amount:[/b][/cell][cell][color=green]" + _format_money(job_data["sal"] - job_data["tExp"]) + "/=[/color][/cell]"
	text += "[/table]\n\n"
	text += "[center]You will start the game with this job![/center]"
	
	details_label.text = text
	
	var panel_center = details_panel.get_parent()
	panel_center.modulate.a = 0
	panel_center.show()
	var tw2 = create_tween()
	tw2.tween_property(panel_center, "modulate:a", 1.0, 0.4)

func _on_accept():
	PlayerData.financials.set_job(selected_job_data)
	emit_signal("job_selected")
	queue_free()
