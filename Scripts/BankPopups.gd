extends CanvasLayer

signal loan_taken(amount: int)
signal loan_repaid(type: String, amount: int)
signal insufficient_cash_resolved(accepted: bool)

@onready var bg_dim = $BackgroundDim
@onready var borrow_panel = $BorrowPanel
@onready var repay_panel = $RepayPanel
@onready var prompt_panel = $PromptPanel
@onready var toast_label = $ToastLabel

# Borrow Panel Nodes
@onready var borrow_amount_input = $BorrowPanel/AmountInput
@onready var borrow_dynamic_lbl = $BorrowPanel/DynamicTextLabel
@onready var borrow_confirm_btn = $BorrowPanel/BorrowButton
@onready var borrow_cancel_btn = $BorrowPanel/CancelButton
@onready var borrow_close_btn = $BorrowPanel/CloseButton

# Repay Panel Nodes
@onready var repay_bg = $RepayPanel/BackgroundTexture
@onready var tab_housing_btn = $RepayPanel/TabHousingButton
@onready var tab_vehicle_btn = $RepayPanel/TabVehicleButton
@onready var tab_bank_btn = $RepayPanel/TabBankButton
@onready var repay_info_lbl = $RepayPanel/InfoLabel
@onready var bank_repay_row = $RepayPanel/BankRepayRow
@onready var bank_repay_input = $RepayPanel/BankRepayRow/BankRepayInput
@onready var repay_confirm_btn = $RepayPanel/RepayButton
@onready var repay_cancel_btn = $RepayPanel/CancelButton
@onready var repay_close_btn = $RepayPanel/CloseButton

# Prompt Panel Nodes (Insufficient Cash)
@onready var prompt_bg = $PromptPanel/PromptBackgroundTexture
@onready var prompt_text_lbl = $PromptPanel/PromptTextLabel
@onready var prompt_borrow_btn = $PromptPanel/PromptBorrowButton
@onready var prompt_cancel_btn = $PromptPanel/PromptCancelButton

const TEX_REPAY_HOUSING = preload("res://Assets/UI/Bank/Bank loan repay pop up for housing loan.svg")
const TEX_REPAY_VEHICLE = preload("res://Assets/UI/Bank/Bank loan repay pop up for vehicle loan.svg")
const TEX_REPAY_BANK = preload("res://Assets/UI/Bank/Bank loan repay pop up for bank loan.svg")

const TEX_PROMPT_MANDATORY = preload("res://Assets/UI/Bank/not_enough_cash_mandatory.svg")
const TEX_PROMPT_OPTIONAL = preload("res://Assets/UI/Bank/not_enough_cash_optional.svg")

enum RepayTab { HOUSING, VEHICLE, BANK }
var current_repay_tab: RepayTab = RepayTab.HOUSING

var pending_needed_cash: int = 0
var pending_is_mandatory: bool = false
var toast_tween: Tween = null

func _ready():
	layer = 15
	hide_all()
	
	# Borrow Signal Connections
	if borrow_close_btn: borrow_close_btn.pressed.connect(close_all)
	if borrow_cancel_btn: borrow_cancel_btn.pressed.connect(close_all)
	if borrow_confirm_btn: borrow_confirm_btn.pressed.connect(_on_borrow_confirmed)
	if borrow_amount_input: borrow_amount_input.text_changed.connect(_on_borrow_amount_changed)
	
	# Repay Signal Connections
	if repay_close_btn: repay_close_btn.pressed.connect(close_all)
	if repay_cancel_btn: repay_cancel_btn.pressed.connect(close_all)
	if repay_confirm_btn: repay_confirm_btn.pressed.connect(_on_repay_confirmed)
	
	if tab_housing_btn: tab_housing_btn.pressed.connect(func(): set_repay_tab(RepayTab.HOUSING))
	if tab_vehicle_btn: tab_vehicle_btn.pressed.connect(func(): set_repay_tab(RepayTab.VEHICLE))
	if tab_bank_btn: tab_bank_btn.pressed.connect(func(): set_repay_tab(RepayTab.BANK))
	
	# Prompt Signal Connections
	if prompt_borrow_btn: prompt_borrow_btn.pressed.connect(_on_prompt_borrow_clicked)
	if prompt_cancel_btn: prompt_cancel_btn.pressed.connect(_on_prompt_cancel_clicked)
	
	if bg_dim:
		bg_dim.gui_input.connect(_on_bg_gui_input)

func _on_bg_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not prompt_panel.visible:
			close_all()

func hide_all():
	hide()
	borrow_panel.hide()
	repay_panel.hide()
	prompt_panel.hide()
	if toast_label: toast_label.hide()
	if bg_dim: bg_dim.color.a = 0.0

func close_all():
	var tw = create_tween()
	tw.set_parallel(true)
	if bg_dim: tw.tween_property(bg_dim, "color:a", 0.0, 0.2)
	tw.chain().tween_callback(func():
		hide_all()
	)

# -------------------------------------------------------------
# 1. SHOW BORROW POPUP ("Take a loan")
# -------------------------------------------------------------
func open_borrow_popup(default_amount: int = 10000):
	hide_all()
	show()
	borrow_panel.show()
	bg_dim.color.a = 0.4
	
	if borrow_amount_input:
		borrow_amount_input.text = str(default_amount)
	_on_borrow_amount_changed(str(default_amount))

func _on_borrow_amount_changed(new_text: String):
	var amt = new_text.to_int()
	if amt < 0: amt = 0
	var installment = int(amt * 0.10)
	if borrow_dynamic_lbl:
		borrow_dynamic_lbl.text = "Take a loan %s/= with a Monthly Installment of %s/=" % [_format_money(amt), _format_money(installment)]

func _on_borrow_confirmed():
	var amt = borrow_amount_input.text.to_int() if borrow_amount_input else 0
	if amt <= 0:
		show_toast("Please enter a valid loan amount")
		return
		
	if PlayerData and PlayerData.financials:
		PlayerData.financials.take_bank_loan(amt)
		if PlayerData.has_method("add_ledger_entry"):
			PlayerData.add_ledger_entry("income", "Bank Loan", amt)
			
	emit_signal("loan_taken", amt)
	show_toast("✓ Bank Loan of %s/= granted!" % _format_money(amt))
	get_tree().create_timer(1.2).timeout.connect(close_all)

# -------------------------------------------------------------
# 2. SHOW REPAY POPUP ("Repay loan")
# -------------------------------------------------------------
func open_repay_popup(initial_tab: RepayTab = RepayTab.HOUSING):
	hide_all()
	show()
	repay_panel.show()
	bg_dim.color.a = 0.4
	set_repay_tab(initial_tab)

func set_repay_tab(tab: RepayTab):
	current_repay_tab = tab
	var financials = PlayerData.financials if PlayerData else null
	var current_cash = financials.cash if financials else 0
	
	match tab:
		RepayTab.HOUSING:
			if repay_bg: repay_bg.texture = TEX_REPAY_HOUSING
			if repay_info_lbl:
				repay_info_lbl.text = "Housing loan and vehical leasing can full settle only"
				repay_info_lbl.show()
			if bank_repay_row: bank_repay_row.hide()
			
			var h_loan = financials.housing_loan if financials else 0
			var can_repay = (h_loan > 0 and current_cash >= h_loan)
			_set_repay_button_state(can_repay)
			
		RepayTab.VEHICLE:
			if repay_bg: repay_bg.texture = TEX_REPAY_VEHICLE
			if repay_info_lbl:
				repay_info_lbl.text = "Housing loan and vehical leasing can full settle only"
				repay_info_lbl.show()
			if bank_repay_row: bank_repay_row.hide()
			
			var v_lease = financials.car_leasing if financials else 0
			var can_repay = (v_lease > 0 and current_cash >= v_lease)
			_set_repay_button_state(can_repay)
			
		RepayTab.BANK:
			if repay_bg: repay_bg.texture = TEX_REPAY_BANK
			if repay_info_lbl: repay_info_lbl.hide()
			if bank_repay_row: bank_repay_row.show()
			
			var b_loan = financials.bank_loan if financials else 0
			if bank_repay_input:
				bank_repay_input.text = str(b_loan)
			_set_repay_button_state(b_loan > 0 and current_cash > 0)

func _set_repay_button_state(enabled: bool):
	if not repay_confirm_btn: return
	if enabled:
		repay_confirm_btn.modulate = Color.WHITE
		repay_confirm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		repay_confirm_btn.modulate = Color(0.5, 0.5, 0.5, 0.8)
		repay_confirm_btn.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN

func _on_repay_confirmed():
	var financials = PlayerData.financials if PlayerData else null
	if not financials: return
	
	var current_cash = financials.cash
	
	match current_repay_tab:
		RepayTab.HOUSING:
			var amount = financials.housing_loan
			if amount <= 0:
				show_toast("No active Housing Loan to repay")
				return
			if current_cash < amount:
				show_toast("Not enough cash")
				return
			financials.repay_housing_loan()
			show_toast("✓ Housing Loan fully settled!")
			get_tree().create_timer(1.2).timeout.connect(close_all)
			
		RepayTab.VEHICLE:
			var amount = financials.car_leasing
			if amount <= 0:
				show_toast("No active Vehicle Leasing to repay")
				return
			if current_cash < amount:
				show_toast("Not enough cash")
				return
			financials.repay_car_leasing()
			show_toast("✓ Vehicle Leasing fully settled!")
			get_tree().create_timer(1.2).timeout.connect(close_all)
			
		RepayTab.BANK:
			var amount = bank_repay_input.text.to_int() if bank_repay_input else 0
			var b_loan = financials.bank_loan
			if amount <= 0 or b_loan <= 0:
				show_toast("Please enter a valid repayment amount")
				return
			if amount > b_loan:
				show_toast("Repayment exceeds active Bank Loan (%s/=)" % _format_money(b_loan))
				return
			if current_cash < amount:
				show_toast("Not enough cash")
				return
			financials.repay_bank_loan(amount)
			show_toast("✓ Repaied bank loan!")
			get_tree().create_timer(1.2).timeout.connect(close_all)

# -------------------------------------------------------------
# 3. SHOW INSUFFICIENT CASH PROMPT ("Not enough cash!")
# -------------------------------------------------------------
func open_insufficient_cash_prompt(needed_cash: int, is_mandatory: bool):
	hide_all()
	show()
	prompt_panel.show()
	bg_dim.color.a = 0.5
	
	pending_needed_cash = needed_cash
	pending_is_mandatory = is_mandatory
	
	var recommended_loan = int(ceil(needed_cash / 1000.0) * 1000)
	if recommended_loan < 1000: recommended_loan = 1000
	var installment = int(recommended_loan * 0.10)
	
	if is_mandatory:
		if prompt_bg: prompt_bg.texture = TEX_PROMPT_MANDATORY
		if prompt_cancel_btn: prompt_cancel_btn.hide()
	else:
		if prompt_bg: prompt_bg.texture = TEX_PROMPT_OPTIONAL
		if prompt_cancel_btn: prompt_cancel_btn.show()
		
	if prompt_text_lbl:
		prompt_text_lbl.text = "Take a loan %s/= with a Monthy installment of %s/=" % [_format_money(recommended_loan), _format_money(installment)]

func _on_prompt_borrow_clicked():
	var recommended_loan = int(ceil(pending_needed_cash / 1000.0) * 1000)
	if recommended_loan < 1000: recommended_loan = 1000
	
	if PlayerData and PlayerData.financials:
		PlayerData.financials.take_bank_loan(recommended_loan)
		if PlayerData.has_method("add_ledger_entry"):
			PlayerData.add_ledger_entry("income", "Bank Loan", recommended_loan)
			
	emit_signal("insufficient_cash_resolved", true)
	hide_all()

func _on_prompt_cancel_clicked():
	emit_signal("insufficient_cash_resolved", false)
	hide_all()

# -------------------------------------------------------------
# UTILITIES: Fading Toast Notification (1-2 seconds)
# -------------------------------------------------------------
func show_toast(message: String, duration: float = 1.8):
	if not toast_label: return
	
	toast_label.text = message
	toast_label.show()
	toast_label.modulate.a = 0.0
	
	if toast_tween and toast_tween.is_running():
		toast_tween.kill()
		
	toast_tween = create_tween()
	toast_tween.tween_property(toast_label, "modulate:a", 1.0, 0.2)
	toast_tween.tween_interval(duration)
	toast_tween.tween_property(toast_label, "modulate:a", 0.0, 0.4)
	toast_tween.tween_callback(toast_label.hide)

func _format_money(value: int) -> String:
	var s = str(abs(value))
	var res = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i != 0:
			res = " " + res
	if value < 0: res = "-" + res
	return res
