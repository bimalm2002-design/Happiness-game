class_name PlayerFinancials
extends RefCounted

var salary: int = 150000
var cash: int = 1200000

# Fixed liability categories
var housing_loan: int = 0
var car_leasing: int = 0
var bank_loan: int = 0

# Dynamic lists
var incomes: Array[Dictionary] = []      # [{ "name": "Taxi Tuk Tuk", "amount": 5550000 }]
var expenses: Array[Dictionary] = []     # [{ "name": "Commercial loan", "amount": 50000 }]
var stocks: Array[Dictionary] = []       # [{ "ticker": "JKH N1564", "qty": 1000, "cost_per_share": 20 }]
var real_estate_assets: Array[Dictionary] = []      # [{ "name": "Apartment - Colombo", "cost": 7000000 }]
var real_estate_liabilities: Array[Dictionary] = [] # [{ "name": "Apartment - Colombo", "amount": 5500000 }]

# Status effects (e.g. {"no_salary": 3} means 3 paydays remaining without salary)
var status_effects: Dictionary = {}

signal changed

func _init():
	pass

func set_job(job_data: Dictionary) -> void:
	salary = job_data["sal"]
	# Savings (cash) is half the salary according to user request
	cash = salary / 2
	
	housing_loan = job_data["houseL"]
	car_leasing = job_data["carL"]
	bank_loan = 0
	
	# Clear arrays in case of restart
	incomes.clear()
	expenses.clear()
	stocks.clear()
	real_estate_assets.clear()
	real_estate_liabilities.clear()
	status_effects.clear()
	
	add_expense("අත්‍යවශ්‍ය වියදම්", job_data["ess"])
	add_expense("විදුලි වියදම්", job_data["elec"])
	add_expense("ප්‍රවාහන වියදම්", job_data["trans"])
	add_expense("නිවාස ණය", job_data["houseP"])
	add_expense("වාහන ලීසිං", job_data["carP"])
	
	changed.emit()

# Helper methods to manipulate lists and emit the signal
func add_income(name: String, amount: int) -> void:
	incomes.append({"name": name, "amount": amount})
	changed.emit()

func remove_income(name: String) -> void:
	incomes = incomes.filter(func(e): return e["name"] != name)
	changed.emit()

func add_expense(name: String, amount: int) -> void:
	expenses.append({"name": name, "amount": amount})
	changed.emit()

func remove_expense(name: String) -> void:
	expenses = expenses.filter(func(e): return e["name"] != name)
	changed.emit()

func add_stock(ticker: String, qty: int, cost_per_share: int) -> void:
	stocks.append({"ticker": ticker, "qty": qty, "cost_per_share": cost_per_share})
	changed.emit()

func update_stock_qty(ticker: String, new_qty: int) -> void:
	for s in stocks:
		if s["ticker"] == ticker:
			s["qty"] = new_qty
			break
	changed.emit()

func remove_stock(ticker: String) -> void:
	stocks = stocks.filter(func(e): return e["ticker"] != ticker)
	changed.emit()

func add_real_estate(name: String, cost: int, liability_amount: int) -> void:
	real_estate_assets.append({"name": name, "cost": cost})
	if liability_amount > 0:
		real_estate_liabilities.append({"name": name, "amount": liability_amount})
	changed.emit()

func remove_real_estate(name: String) -> void:
	real_estate_assets = real_estate_assets.filter(func(e): return e["name"] != name)
	real_estate_liabilities = real_estate_liabilities.filter(func(e): return e["name"] != name)
	changed.emit()

func update_cash(amount: int) -> void:
	cash += amount
	changed.emit()

func update_bank_loan_expense() -> void:
	var interest_expense = int(bank_loan * 0.10)
	var found = false
	for i in range(expenses.size() - 1, -1, -1):
		if expenses[i].get("name", "") == "බැංකු ණය":
			if not found and interest_expense > 0:
				expenses[i]["amount"] = interest_expense
				found = true
			else:
				expenses.remove_at(i)
	if not found and interest_expense > 0:
		expenses.append({"name": "බැංකු ණය", "amount": interest_expense})
	changed.emit()

func take_bank_loan(amount: int) -> void:
	bank_loan += amount
	cash += amount
	update_bank_loan_expense()

func repay_housing_loan() -> bool:
	if housing_loan <= 0 or cash < housing_loan:
		return false
	var amount = housing_loan
	cash -= amount
	housing_loan = 0
	remove_expense("නිවාස ණය")
	if PlayerData and PlayerData.has_method("add_ledger_entry"):
		PlayerData.add_ledger_entry("expense", "Full settled - Housing loan", amount)
	changed.emit()
	return true

func repay_car_leasing() -> bool:
	if car_leasing <= 0 or cash < car_leasing:
		return false
	var amount = car_leasing
	cash -= amount
	car_leasing = 0
	remove_expense("වාහන ලීසිං")
	if PlayerData and PlayerData.has_method("add_ledger_entry"):
		PlayerData.add_ledger_entry("expense", "Full settled - vehicle leasing", amount)
	changed.emit()
	return true

func repay_bank_loan(repay_amount: int) -> bool:
	if repay_amount <= 0 or bank_loan <= 0 or cash < repay_amount:
		return false
	var actual_repay = mini(repay_amount, bank_loan)
	cash -= actual_repay
	bank_loan -= actual_repay
	update_bank_loan_expense()
	if PlayerData and PlayerData.has_method("add_ledger_entry"):
		PlayerData.add_ledger_entry("expense", "Repaied bank loan", actual_repay)
	changed.emit()
	return true

func process_payday_bank_loan_reduction() -> void:
	if bank_loan <= 0: return
	var reduction = int(bank_loan * 0.10)
	if reduction <= 0 and bank_loan > 0:
		reduction = bank_loan
	bank_loan = max(0, bank_loan - reduction)
	update_bank_loan_expense()

func set_fixed_liability(type: String, amount: int) -> void:
	if type == "housing_loan":
		housing_loan = amount
	elif type == "car_leasing":
		car_leasing = amount
	elif type == "bank_loan":
		bank_loan = amount
		update_bank_loan_expense()
		return
	changed.emit()

func add_status_effect(effect_name: String, duration_in_paydays: int) -> void:
	status_effects[effect_name] = duration_in_paydays
	changed.emit()

func has_status_effect(effect_name: String) -> bool:
	return status_effects.has(effect_name) and status_effects[effect_name] > 0

func decrement_status_effects() -> Array:
	var active_effects = []
	for effect in status_effects.keys():
		status_effects[effect] -= 1
		if status_effects[effect] > 0:
			active_effects.append(effect)
		else:
			status_effects.erase(effect)
	changed.emit()
	return active_effects

