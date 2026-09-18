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

func set_fixed_liability(type: String, amount: int) -> void:
	if type == "housing_loan":
		housing_loan = amount
	elif type == "car_leasing":
		car_leasing = amount
	elif type == "bank_loan":
		bank_loan = amount
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

