extends Node

var is_moving = false
var card_popup = null

var has_job_selected = false

func _ready():
	var popup_scene = load("res://Scenes/CardPopup.tscn")
	if popup_scene:
		card_popup = popup_scene.instantiate()
		# Add as sibling so it renders on top (it's a CanvasLayer anyway)
		call_deferred("add_sibling", card_popup)
		
		# Connect signals
		card_popup.connect("card_accepted", Callable(self, "_on_card_accepted"))
		card_popup.connect("card_declined", Callable(self, "_on_card_declined"))

	# Show Job Selection Popup before playing
	var job_sel = load("res://Scripts/JobSelection.gd").new()
	job_sel.job_selected.connect(func():
		has_job_selected = true
		print("Job Selected! Game begins.")
	)
	call_deferred("add_sibling", job_sel)

func on_dice_thrown():
	print("Dice thrown! Waiting for it to settle...")

func dice_rolled(result: int):
	if not has_job_selected:
		print("Wait! You must select a job first.")
		var dice = get_node_or_null("../Dice3D")
		if dice and dice.has_method("reset_dice"): dice.reset_dice()
		return
		
	print("Dice rolled: ", result)
	if is_moving: return
	is_moving = true
	
	var cam = get_node_or_null("../MainCamera")
	if cam and cam.has_method("set_state"):
		cam.set_state(1) # State.FOLLOW = 1
		
	# Wait for camera to zoom in
	await get_tree().create_timer(1.2).timeout
	
	var avatar = get_node_or_null("../RatAvatar")
	if avatar:
		var raw_board_nodes = []
		var board = get_node_or_null("../Board")
		if board:
			var all_meshes = []
			var to_check = board.get_children()
			while to_check.size() > 0:
				var c = to_check.pop_front()
				if c is MeshInstance3D and c.has_meta("path_index"):
					all_meshes.append(c)
				to_check.append_array(c.get_children())
			
			# Sort by path_index metadata to restore correct path order
			all_meshes.sort_custom(func(a, b): return a.get_meta("path_index", 999) < b.get_meta("path_index", 999))
			
			for m in all_meshes:
				raw_board_nodes.append(m)
					
			# Connect passed_square signal if not already connected
			if not avatar.is_connected("passed_square", Callable(self, "_on_avatar_passed_square")):
				avatar.connect("passed_square", Callable(self, "_on_avatar_passed_square"))
				
			if raw_board_nodes.size() > 0:
				avatar.move_spaces(result, raw_board_nodes)
				await avatar.move_finished
				
				# Check which square the avatar landed on
				var current_square = raw_board_nodes[avatar.current_index]
				var square_type = current_square.get_parent().name

			
				if card_popup:
					var card_data = {}
					if square_type == "OpportunitySquares":
						card_data = CardManager.get_random_card_by_type("Opportunity")
					elif square_type == "OopsSquares":
						card_data = CardManager.get_random_card_by_type("Oops")
					elif square_type == "FlashSquares":
						card_data = CardManager.get_random_card_by_type("Flash")
					elif square_type == "StockSquares":
						card_data = CardManager.get_random_card_by_type("Stock")
					
					if not card_data.is_empty():
						card_popup.show_card_data(card_data)

		# Wait a bit after move finishes
		await get_tree().create_timer(1.0).timeout
		
		if cam and cam.has_method("set_state"):
			cam.set_state(0) # State.OVERVIEW = 0
			await get_tree().create_timer(1.0).timeout
			
		# Reset dice position for next throw safely
		var dice = get_node_or_null("../Dice3D")
		if dice:
			if dice.has_method("reset_dice"):
				dice.reset_dice()
			
		is_moving = false

func _on_card_accepted(card_data: Dictionary):
	if CardManager and CardManager.card_logic_controller:
		CardManager.card_logic_controller.card_popup = card_popup
		CardManager.card_logic_controller.execute_card_accepted(card_data)

func _on_card_declined(card_data: Dictionary):
	if CardManager and CardManager.card_logic_controller:
		CardManager.card_logic_controller.card_popup = card_popup
		CardManager.card_logic_controller.execute_card_declined(card_data)


func _on_avatar_passed_square(square_node: Node3D):
	if not square_node: return
	var p = square_node.get_parent()
	if not p: return
	var square_type = p.name
	
	# Payday triggers ONLY when passing/landing on the yellow GO square (OtherSquares / go_1)
	if square_type == "OtherSquares" or square_node.name.begins_with("go"):
		_trigger_payday()

func _trigger_payday():
	print("Passed Payday (GO Square)!")
	var f = PlayerData.financials
	
	# Check for active salary penalty
	var salary = f.salary
	if f.has_status_effect("no_salary"):
		print("No salary due to penalty!")
		salary = 0
	elif f.has_status_effect("half_salary"):
		print("Half salary due to penalty!")
		salary = salary / 2
		
	var passive_income = 0
	for inc in f.incomes:
		passive_income += int(inc.get("amount", 0))
		
	var total_expenses = 0
	for exp in f.expenses:
		total_expenses += int(exp.get("amount", 0))
		
	var payday_amount = (salary + passive_income) - total_expenses
	
	if payday_amount < 0:
		# Insufficient cash for payday deficit
		if f.cash + payday_amount < 0:
			var shortage = -(f.cash + payday_amount)
			print("Mandatory loan of exact shortfall: ", shortage)
			var loan_needed = shortage # Exact shortfall amount
			f.set_fixed_liability("bank_loan", f.bank_loan + loan_needed)
			f.add_expense("බැංකු ණය", int(loan_needed * 0.1))
			PlayerData.add_ledger_entry("income", "අනිවාර්ය බැංකු ණය", loan_needed)
			
	if payday_amount == 0:
		PlayerData.add_ledger_entry("income", "Payday", 0, true)
	else:
		PlayerData.add_ledger_entry("income", "Payday", payday_amount)
	
	# Decrement status effects after Payday
	f.decrement_status_effects()
