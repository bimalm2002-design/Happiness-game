class_name CardResource
extends Resource

@export var id: int = 0
@export var title: String = ""
@export var card_type: String = "" # "Opportunity", "Flash", "Oops", "Stock"
@export_multiline var description: String = ""
@export_multiline var values: String = ""

# Financial numerical values
@export var cost: int = 0
@export var down_payment: int = 0
@export var cashflow: int = 0
@export var penalty: int = 0
@export var price_per_share: int = 0

# UI buttons (e.g. ["invest", "pass"], ["ok"], ["pay"], ["buy", "sell", "pass"])
@export var buttons: Array[String] = []

# Financial rules & principles
@export_multiline var financial_statement_effect: String = ""
@export_multiline var cash_ledger_effect: String = ""
@export_multiline var ignore_skip_rule: String = ""
@export_multiline var insufficient_funds_rule: String = ""
@export_multiline var interdependencies: String = ""

# Programmatic action handler key
@export var action_key: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": card_type,
		"back_title": title,
		"title": title,
		"back_desc": description,
		"values": values,
		"cost": cost,
		"down_payment": down_payment,
		"cashflow": cashflow,
		"penalty": penalty,
		"price": price_per_share,
		"buttons": buttons,
		"financial_statement_effect": financial_statement_effect,
		"cash_ledger_effect": cash_ledger_effect,
		"ignore_skip_rule": ignore_skip_rule,
		"insufficient_funds_rule": insufficient_funds_rule,
		"interdependencies": interdependencies,
		"action_key": action_key
	}