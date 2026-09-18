extends Node

var financials: PlayerFinancials
var ledger_history: Array[Dictionary] = []

var jobs = [
	{ "title": "Mechanic (කාර්මික ශිල්පී)", "sal": 40000, "ess": 13000, "elec": 3200, "trans": 6600, "carP": 1200, "houseP": 1000, "tExp": 25000, "carL": 30000, "houseL": 100000 },
	{ "title": "Teacher (ගුරුවරයා)", "sal": 50000, "ess": 16500, "elec": 4900, "trans": 8100, "carP": 2000, "houseP": 1500, "tExp": 33000, "carL": 50000, "houseL": 150000 },
	{ "title": "Police Officer (පොලිස් නිලධාරී)", "sal": 60000, "ess": 21700, "elec": 5400, "trans": 9100, "carP": 2800, "houseP": 2000, "tExp": 41000, "carL": 70000, "houseL": 200000 },
	{ "title": "Nurse (හෙද නිලධාරී)", "sal": 80000, "ess": 20500, "elec": 6200, "trans": 10300, "carP": 8000, "houseP": 4000, "tExp": 49000, "carL": 200000, "houseL": 400000 },
	{ "title": "Bank Officer (බැංකු නිලධාරී)", "sal": 100000, "ess": 27600, "elec": 7400, "trans": 11000, "carP": 6000, "houseP": 5000, "tExp": 57000, "carL": 150000, "houseL": 500000 },
	{ "title": "Civil Engineer (සිවිල් ඉංජිනේරු)", "sal": 120000, "ess": 30600, "elec": 8500, "trans": 11900, "carP": 8000, "houseP": 6000, "tExp": 65000, "carL": 200000, "houseL": 600000 },
	{ "title": "Software Engineer (මෘදුකාංග ඉංජිනේරු)", "sal": 150000, "ess": 31500, "elec": 7800, "trans": 15700, "carP": 10000, "houseP": 8000, "tExp": 73000, "carL": 250000, "houseL": 800000 },
	{ "title": "Lawyer (නීතිඥ)", "sal": 180000, "ess": 35000, "elec": 8300, "trans": 16700, "carP": 12000, "houseP": 9000, "tExp": 81000, "carL": 300000, "houseL": 900000 },
	{ "title": "Business Executive (විධායක නිලධාරී)", "sal": 200000, "ess": 35000, "elec": 9400, "trans": 17600, "carP": 16000, "houseP": 10000, "tExp": 88000, "carL": 400000, "houseL": 1000000 },
	{ "title": "Doctor (වෛද්‍යවරයා)", "sal": 250000, "ess": 34000, "elec": 9700, "trans": 19300, "carP": 20000, "houseP": 12000, "tExp": 95000, "carL": 500000, "houseL": 1200000 }
]

func _ready():
	financials = PlayerFinancials.new()
	# Game will initialize financials when a job is picked.

func add_ledger_entry(type: String, desc: String, amount: int, allow_zero: bool = false):
	if amount == 0 and not allow_zero: return
	ledger_history.append({"type": type, "desc": desc, "amount": amount})
	financials.update_cash(amount)

