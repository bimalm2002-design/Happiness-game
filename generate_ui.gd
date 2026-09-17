@tool
extends EditorScript

func _run():
	print("Starting UI Generation...")
	
	# Root Node
	var root = Node.new()
	root.name = "MainUI"
	
	# No BackgroundLayer needed! The 3D Environment will provide the background.
	
	# Foreground CanvasLayer (Layer 1)
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.layer = 1
	root.add_child(ui_layer)
	ui_layer.owner = root
	
	var ui_container = Control.new()
	ui_container.name = "UIContainer"
	ui_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(ui_container)
	ui_container.owner = root
	
	# Font setup (still needed for labels or anything missing)
	var font = FontFile.new()
	font.load_dynamic_font("res://LilitaOne-Regular.ttf")
	
	# ----------------------------------------------------
	# 1. Settings Button (Top Left)
	# ----------------------------------------------------
	var settings_btn = TextureButton.new()
	settings_btn.name = "SettingsButton"
	if ResourceLoader.exists("res://Assets/UI/Settings.svg"):
		settings_btn.texture_normal = load("res://Assets/UI/Settings.svg")
	settings_btn.ignore_texture_size = true
	settings_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	settings_btn.position = Vector2(30, 30)
	settings_btn.size = Vector2(173, 50) # Estimated size for Settings SVG
	ui_container.add_child(settings_btn)
	settings_btn.owner = root
	
	# ----------------------------------------------------
	# 2. Rat Race Progress Bar (Top Right)
	# ----------------------------------------------------
	var progress_vbox = VBoxContainer.new()
	progress_vbox.name = "ProgressBars"
	ui_container.add_child(progress_vbox)
	progress_vbox.owner = root
	
	progress_vbox.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
	progress_vbox.offset_right = -30
	progress_vbox.offset_left = -261 # 201 + 60 for avatar space
	progress_vbox.offset_top = 30
	progress_vbox.offset_bottom = 90
	
	var rat_progress_container = Control.new()
	rat_progress_container.name = "Player1Progress"
	rat_progress_container.custom_minimum_size = Vector2(243, 66) # 201 + overhang
	progress_vbox.add_child(rat_progress_container)
	rat_progress_container.owner = root
	
	# The Progress Bar
	var pb = ProgressBar.new()
	pb.name = "Bar"
	pb.set_anchors_preset(Control.PRESET_TOP_LEFT)
	pb.position = Vector2(0, 20) # Centered vertically
	pb.size = Vector2(201, 25)
	pb.show_percentage = false
	pb.value = 68
	pb.fill_mode = 1 # FILL_END_TO_BEGIN (Right to Left)
	
	var pb_bg = StyleBoxFlat.new()
	pb_bg.bg_color = Color(0, 0, 0, 0.35) # Translucent dark background
	pb_bg.corner_radius_top_left = 12 # Pill shape
	pb_bg.corner_radius_bottom_left = 12
	pb_bg.corner_radius_top_right = 12
	pb_bg.corner_radius_bottom_right = 12
	pb.add_theme_stylebox_override("background", pb_bg)
	
	var pb_fill = StyleBoxFlat.new()
	pb_fill.bg_color = Color.html("#C10098") # Vibrant Magenta
	pb_fill.corner_radius_top_left = 0 # Flat on the left edge because it's filling from the right
	pb_fill.corner_radius_bottom_left = 0
	pb_fill.corner_radius_top_right = 12
	pb_fill.corner_radius_bottom_right = 12
	pb.add_theme_stylebox_override("fill", pb_fill)
	
	rat_progress_container.add_child(pb)
	pb.owner = root
	
	# The "Glass Tube Shine" Effect
	var shine = Panel.new()
	shine.name = "GlassShine"
	shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shine.position = Vector2(8, 22) # 8px padding. Y=20+2=22
	shine.size = Vector2(185, 10) 
	var shine_style = StyleBoxFlat.new()
	shine_style.bg_color = Color(1.0, 1.0, 1.0, 0.3) # Increased opacity so it is clearly visible over the magenta
	shine_style.corner_radius_top_left = 10 
	shine_style.corner_radius_bottom_left = 10
	shine_style.corner_radius_top_right = 10
	shine_style.corner_radius_bottom_right = 10
	shine.add_theme_stylebox_override("panel", shine_style)
	rat_progress_container.add_child(shine)
	shine.owner = root
	
	# The Border Overlay (Drawn ON TOP of everything to contain the liquid and shine)
	var border_overlay = Panel.new()
	border_overlay.name = "BorderOverlay"
	border_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_overlay.position = pb.position
	border_overlay.size = pb.size
	var border_style = StyleBoxFlat.new()
	border_style.draw_center = false # DO NOT fill with color, only draw border
	border_style.border_color = Color.BLACK
	border_style.border_width_bottom = 2
	border_style.border_width_top = 2
	border_style.border_width_left = 2
	border_style.border_width_right = 2
	border_style.corner_radius_top_left = 12
	border_style.corner_radius_bottom_left = 12
	border_style.corner_radius_top_right = 12
	border_style.corner_radius_bottom_right = 12
	border_overlay.add_theme_stylebox_override("panel", border_style)
	rat_progress_container.add_child(border_overlay)
	border_overlay.owner = root
	
	# The Rat Avatar
	var rat_icon = TextureRect.new()
	rat_icon.name = "RatAvatar"
	if ResourceLoader.exists("res://Assets/UI/rat_avatar_03.png"):
		rat_icon.texture = load("res://Assets/UI/rat_avatar_03.png")
	rat_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rat_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rat_icon.size = Vector2(63, 66)
	rat_icon.position = Vector2(165, -19) # Moved left to 165 for perfect overlap
	rat_progress_container.add_child(rat_icon)
	rat_icon.owner = root
	
	# ----------------------------------------------------
	# 3. Bottom Left (CASH Ledger & Final Statement)
	# ----------------------------------------------------
	var bl_vbox = VBoxContainer.new()
	bl_vbox.name = "BottomLeftMenu"
	ui_container.add_child(bl_vbox)
	bl_vbox.owner = root
	
	bl_vbox.set_anchors_preset(Control.PRESET_BOTTOM_LEFT, true)
	bl_vbox.offset_left = 30
	bl_vbox.offset_right = 323
	bl_vbox.offset_bottom = -30
	bl_vbox.offset_top = -230
	
	bl_vbox.add_theme_constant_override("separation", 20)
	bl_vbox.alignment = BoxContainer.ALIGNMENT_END
	
	var cash_btn = TextureButton.new()
	cash_btn.name = "CashLedgerButton"
	if ResourceLoader.exists("res://Assets/UI/cash ledger button.svg"):
		cash_btn.texture_normal = load("res://Assets/UI/cash ledger button.svg")
	cash_btn.ignore_texture_size = true
	cash_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	cash_btn.custom_minimum_size = Vector2(198, 60)
	cash_btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bl_vbox.add_child(cash_btn)
	cash_btn.owner = root
	
	var fs_btn = TextureButton.new()
	fs_btn.name = "FinalStatementButton"
	if ResourceLoader.exists("res://Assets/UI/Financial statement button.svg"):
		fs_btn.texture_normal = load("res://Assets/UI/Financial statement button.svg")
	fs_btn.ignore_texture_size = true
	fs_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	fs_btn.custom_minimum_size = Vector2(293, 99)
	fs_btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bl_vbox.add_child(fs_btn)
	fs_btn.owner = root
	
	# ----------------------------------------------------
	# 4. Bottom Right (Bank, Borrow, Repay)
	# ----------------------------------------------------
	var br_container = Control.new()
	br_container.name = "BottomRightMenu"
	ui_container.add_child(br_container)
	br_container.owner = root
	
	br_container.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT, true)
	br_container.offset_right = -30
	br_container.offset_bottom = -30
	br_container.offset_left = -330
	br_container.offset_top = -230
	br_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# BANK BUTTON
	var bank_btn = TextureButton.new()
	bank_btn.name = "BankButton"
	if ResourceLoader.exists("res://Assets/UI/Bank Button.svg"):
		bank_btn.texture_normal = load("res://Assets/UI/Bank Button.svg")
	bank_btn.ignore_texture_size = true
	bank_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	bank_btn.size = Vector2(100, 100) # Ensure it's exactly 100x100
	bank_btn.position = Vector2(200, 100) # Bottom right corner of 300x200 container
	bank_btn.set_script(load("res://Scripts/BankMenu.gd"))
	br_container.add_child(bank_btn)
	bank_btn.owner = root
	
	# Add the Bank 3D Image inside the SVG Background
	var bank_img = TextureRect.new()
	bank_img.name = "BankImage"
	if ResourceLoader.exists("res://Assets/UI/Bank image.png"):
		bank_img.texture = load("res://Assets/UI/Bank image.png")
	bank_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bank_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bank_img.size = Vector2(81, 69)
	bank_img.position = Vector2(9, 4) # Centered approx
	bank_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bank_btn.add_child(bank_img)
	bank_img.owner = root
	
	# BORROW BUTTON (Exact relative position: -58, -69)
	var borrow_btn = Button.new()
	borrow_btn.name = "BorrowButton"
	borrow_btn.size = Vector2(104, 45.3)
	borrow_btn.position = Vector2(-58, -69)
	borrow_btn.text = "Borrow"
	borrow_btn.add_theme_font_override("font", font)
	borrow_btn.add_theme_font_size_override("font_size", 26)
	borrow_btn.add_theme_color_override("font_color", Color.WHITE)
	borrow_btn.add_theme_color_override("font_outline_color", Color(56.0/255.0, 65.0/255.0, 96.0/255.0)) # rgb(56, 65, 96)
	borrow_btn.add_theme_constant_override("outline_size", 1) # Very thin stroke
	borrow_btn.position = Vector2(-20, -70)
	borrow_btn.size = Vector2(104, 45) # From JSON
	borrow_btn.visible = false
	
	var borrow_style = StyleBoxFlat.new()
	borrow_style.bg_color = Color.html("#FE7D1D") # Orange from image
	borrow_style.border_width_bottom = 2
	borrow_style.border_width_top = 2
	borrow_style.border_width_left = 2
	borrow_style.border_width_right = 2
	borrow_style.border_color = Color(56.0/255.0, 56.0/255.0, 56.0/255.0) # rgb(56, 56, 56)
	borrow_style.corner_radius_top_left = 15
	borrow_style.corner_radius_bottom_left = 15
	borrow_style.corner_radius_top_right = 15
	borrow_style.corner_radius_bottom_right = 15
	borrow_btn.add_theme_stylebox_override("normal", borrow_style)
	borrow_btn.add_theme_stylebox_override("hover", borrow_style)
	borrow_btn.add_theme_stylebox_override("pressed", borrow_style)
	
	bank_btn.add_child(borrow_btn)
	borrow_btn.owner = root
	
	# REPAY BUTTON
	var repay_btn = Button.new()
	repay_btn.name = "RepayButton"
	repay_btn.text = "Repay"
	repay_btn.add_theme_font_override("font", font)
	repay_btn.add_theme_font_size_override("font_size", 28)
	repay_btn.add_theme_color_override("font_color", Color.WHITE)
	repay_btn.add_theme_color_override("font_outline_color", Color(56.0/255.0, 65.0/255.0, 96.0/255.0)) # rgb(56, 65, 96)
	repay_btn.add_theme_constant_override("outline_size", 1) # Very thin stroke
	repay_btn.position = Vector2(-120, 20)
	repay_btn.size = Vector2(104, 45) # From JSON
	repay_btn.visible = false
	
	var repay_style = StyleBoxFlat.new()
	repay_style.bg_color = Color.html("#FCE53C") # Yellow from image
	repay_style.border_width_bottom = 2
	repay_style.border_width_top = 2
	repay_style.border_width_left = 2
	repay_style.border_width_right = 2
	repay_style.border_color = Color(56.0/255.0, 56.0/255.0, 56.0/255.0) # rgb(56, 56, 56)
	repay_style.corner_radius_top_left = 15
	repay_style.corner_radius_bottom_left = 15
	repay_style.corner_radius_top_right = 15
	repay_style.corner_radius_bottom_right = 15
	repay_btn.add_theme_stylebox_override("normal", repay_style)
	repay_btn.hide()
	bank_btn.add_child(repay_btn)
	repay_btn.owner = root
	
	# Assign references to BankMenu script
	bank_btn.set("borrow_btn_path", bank_btn.get_path_to(borrow_btn))
	bank_btn.set("repay_btn_path", bank_btn.get_path_to(repay_btn))
	
	# Save Scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	ResourceSaver.save(packed_scene, "res://MainUI.tscn")
	print("MainUI.tscn generated successfully with exact SVG sizing and Bank Menu logic!")
