class_name CardLogicController
extends Node

# Reference to popup if needed to draw free opportunity card
var card_popup = null

func _ready():
	pass

# Helper to check if player has a specific real estate / business asset
func has_asset(asset_name: String) -> bool:
	if not PlayerData or not PlayerData.financials: return false
	for a in PlayerData.financials.real_estate_assets:
		if a.get("name", "") == asset_name:
			return true
	return false

# Helper to check if a card is eligible to be drawn based on prerequisites
func can_draw_card(card_id: int) -> bool:
	if not PlayerData or not PlayerData.financials: return true
	var f = PlayerData.financials
	
	match card_id:
		# Investment sell / event prerequisites
		15, 18:
			return has_asset("Musical Show")
		16, 17:
			return has_asset("Stage Drama")
		19:
			return has_asset("Software Project")
		20:
			return has_asset("Parking Lot")
		21:
			return has_asset("Book Patent")
		23:
			return has_asset("River Land")
		25:
			return f.has_status_effect("has_bicycle")
		31:
			return has_asset("Zoo Land")
			
		# Life event prerequisites
		35, 40, 43:
			return f.has_status_effect("has_child")
		39:
			return f.has_status_effect("is_married")
		53:
			return f.has_status_effect("is_married")
		37:
			# Can marry if not currently married
			return not f.has_status_effect("is_married")
			
	return true

# Helper to ensure sufficient cash for mandatory expenses / oops
func ensure_cash(amount_needed: int, reason: String):
	if not PlayerData or not PlayerData.financials: return
	var f = PlayerData.financials
	if f.cash < amount_needed:
		var deficit = amount_needed - f.cash
		var loan_amount = int(ceil(deficit / 10000.0)) * 10000
		f.set_fixed_liability("bank_loan", f.bank_loan + loan_amount)
		# Add 10% monthly repayment/installment to expenses
		f.add_expense("බැංකු ණය", int(loan_amount * 0.1))
		PlayerData.add_ledger_entry("income", "අනිවාර්ය බැංකු ණය (" + reason + ")", loan_amount)
		print("Auto-loan granted: ", loan_amount, " for ", reason)

# Called when player accepts a card (e.g., Invest, Buy, Party, OK, Dismiss)
func execute_card_accepted(card_data: Dictionary):
	if not PlayerData or not PlayerData.financials: return
	var f = PlayerData.financials
	var cid = int(card_data.get("id", 0))
	var type = str(card_data.get("type", ""))
	var title = str(card_data.get("title", card_data.get("back_title", "Card " + str(cid))))
	
	print("Executing Card Accepted: #", cid, " (", type, ") - ", title)
	
	# Extract financial fields safely
	var cost = int(card_data.get("cost", 0))
	var dp = int(card_data.get("down_payment", 0))
	var cf = int(card_data.get("cashflow", 0))
	var action = str(card_data.get("action_key", ""))
	
	# Handle based on Card ID / Category
	match cid:
		# --- OPPORTUNITY CARDS ---
		1:
			_buy_opportunity("විශ්වවිද්‍යාල ගොඩනැගිල්ල", 80000, 20000, 12000, "විශ්වවිද්‍යාල ගොඩනැගිල්ල සඳහා Downpayment එක")
		2:
			_buy_opportunity("Parking Lot", 40000, 10000, 6000, "Parking lot එක සඳහා Downpayment එක")
		3:
			_buy_opportunity("කඩකාමර 6", 90000, 25000, 15000, "කඩකාමර 6 සඳහා Downpayment එක")
		4:
			_buy_opportunity("කුරුඳු ඉඩම", 30000, 5000, 3000, "කුරුඳු ඉඩම සඳහා Downpayment එක")
		5:
			_buy_opportunity("පොල් ඉඩම", 60000, 15000, 9000, "පොල් ඉඩම සඳහා Downpayment එක")
		6: # Taxi Tuk Tuk (15,000 / DP: 3,000 / CF: 3,000)
			_buy_opportunity("ත්‍රීරෝද රථය", 15000, 3000, 3000, "ත්‍රීරෝද රථය සඳහා Downpayment එක")
		7: # School Van (25,000 / DP: 5,000 / CF: 4,500)
			_buy_opportunity("School වෑන්", 25000, 5000, 4500, "School වෑන් එක සඳහා Downpayment එක")
		8: # Leisure Park (20,000 / CF: 7,500)
			_buy_opportunity("Leisure Park", 20000, 20000, 7500, "Leisure Park එකක් ඉදිකිරීම")
		9: # Roti Shop (5,000 / CF: 2,400)
			_buy_opportunity("රොටී කඩය", 5000, 5000, 2400, "රොටී කඩයක් ආරම්භ කිරීම")
		10:
			# Software project: full cost 10,000, no loan liability, no cashflow yet
			ensure_cash(10000, "Software Project")
			f.add_real_estate("මෘදුකාංග ව්‍යාපෘතිය", 10000, 0)
			PlayerData.add_ledger_entry("expense", "මෘදුකාංග ව්‍යාපෘතියකට ආයෝජනය", -10000)
		11:
			# Book patent: full cost 2,000, no liability, cashflow 1,500
			ensure_cash(2000, "Book Patent")
			f.add_real_estate("පොතේ පේටන්ට් බලපත්‍රය", 2000, 0)
			f.add_income("පොතේ පේටන්ට් බලපත්‍රය", 1500)
			PlayerData.add_ledger_entry("expense", "පොතේ පේටන්ට් අයිතිය මිලදී ගැනීම", -2000)
		12: # Family Restaurant (35,000 / CF: 12,000)
			_buy_opportunity("Family Restaurant", 35000, 35000, 12000, "Family Restaurant එකක් ආරම්භ කිරීම")
		52:
			# Solar panel: cost 35,000, removes electricity expense, adds 1000 passive income
			ensure_cash(35000, "Solar Panel System")
			f.add_real_estate("සූර්ය කෝෂ පද්ධතිය", 35000, 0)
			f.remove_expense("විදුලි වියදම්")
			f.add_income("සූර්ය කෝෂ පද්ධතිය", 1000)
			PlayerData.add_ledger_entry("expense", "සූර්ය කෝෂ පද්ධතියක් සවි කිරීම", -35000)

		# --- FLASH CARDS ---
		13: # Stage Drama
			ensure_cash(15000, "Stage Drama")
			f.add_real_estate("Stage drama", 15000, 0)
			PlayerData.add_ledger_entry("expense", "Stage drama එකක් නිෂ්පාදනය", -15000)
		14: # Musical Show
			ensure_cash(25000, "Musical Show")
			f.add_real_estate("Musical show", 25000, 0)
			PlayerData.add_ledger_entry("expense", "Musical show එකක් පැවැත්වීම", -25000)
		15: # Concert Success
			f.remove_real_estate("Musical show")
			PlayerData.add_ledger_entry("income", "Musical show එකේ ආදායම", 55000)
		16: # Drama Profit
			f.remove_real_estate("Stage drama")
			PlayerData.add_ledger_entry("income", "Stage drama එකේ ආදායම", 35000)
		17: # Drama Crash
			f.remove_real_estate("Stage drama")
			ensure_cash(5000, "Drama Loss")
			PlayerData.add_ledger_entry("expense", "Stage drama එකේ අලාභය", -5000)
		18: # Concert Risk
			f.remove_real_estate("Musical show")
			PlayerData.add_ledger_entry("income", "Musical show එකේ ආදායම", 10000)
		19: # Sell Software
			f.remove_real_estate("මෘදුකාංග ව්‍යාපෘතිය")
			PlayerData.add_ledger_entry("income", "මෘදුකාංග ව්‍යාපෘතිය විකිණීම", 50000)
		20: # Sell Parking Lot
			f.remove_real_estate("Parking Lot")
			f.remove_income("Parking Lot")
			PlayerData.add_ledger_entry("income", "Parking lot එක විකිණීම", 80000)
		21: # Sell Book Patent
			f.remove_real_estate("පොතේ පේටන්ට් බලපත්‍රය")
			f.remove_income("පොතේ පේටන්ට් බලපත්‍රය")
			PlayerData.add_ledger_entry("income", "පොතේ පේටන්ට් අයිතිය විකිණීම", 15000)
		22: # Techno Crash
			f.remove_stock("ටෙක්නෝ")
		23: # Sell River Land
			f.remove_real_estate("ගඟ අසල ඉඩම")
			PlayerData.add_ledger_entry("income", "ගඟ අසල ඉඩම විකිණීම", 120000)
		24: # Buy River Land
			ensure_cash(60000, "River Land")
			f.add_real_estate("ගඟ අසල ඉඩම", 60000, 0)
			PlayerData.add_ledger_entry("expense", "ගඟ අසල ඉඩමක් මිලදී ගැනීම", -60000)
		25: # Sell Sport Bike
			f.status_effects.erase("has_bicycle")
			PlayerData.add_ledger_entry("income", "Sport Bike එක විකිණීම", 25000)
		26: # Bonus
			PlayerData.add_ledger_entry("income", "සමාගම් බෝනස් මුදල", 3000)
		27: # Salary increment
			f.salary += 2000
			f.changed.emit()
		28: # Poultry Farm
			ensure_cash(40000, "Poultry Farm")
			f.add_real_estate("කුකුළු ගොවිපොළ", 40000, 0)
			f.add_income("කුකුළු ගොවිපොළ", 5000)
			PlayerData.add_ledger_entry("expense", "කුකුළු ගොවිපොළක ආයෝජනය", -40000)
		29: # Zoo Land
			ensure_cash(50000, "Zoo Land")
			f.add_real_estate("සත්ත්ව උද්‍යාන ඉඩම", 50000, 0)
			PlayerData.add_ledger_entry("expense", "සත්ත්ව උද්‍යාන ඉඩම මිලදී ගැනීම", -50000)
		30: # Inherit Jewelry
			f.add_real_estate("රන් ආභරණ", 100000, 0)
		31: # Sell Zoo Land
			f.remove_real_estate("සත්ත්ව උද්‍යාන ඉඩම")
			PlayerData.add_ledger_entry("income", "සත්ත්ව උද්‍යාන ඉඩම විකිණීම", 90000)

		# --- OOPS CARDS ---
		32: # Unpaid Leave 3 Months
			f.add_status_effect("no_salary", 3)
		33: # Vehicle Service / Repair (1/8 of vehicle or standard 8000)
			_deduct_oops(8000, "Vehicle Repair")
		34: # Accident half salary
			f.add_status_effect("half_salary", 2)
		35: # Child exam / Special class (1000/=)
			_deduct_oops(1000, "දරුවාගේ විශේෂ පන්ති ගාස්තු")
		36: # Home repair (2000/=)
			_deduct_oops(2000, "නිවස repair කිරීම")
		37: # Marriage (20,000/=)
			ensure_cash(20000, "Wedding Party")
			f.add_status_effect("is_married", 9999)
			f.add_expense("සහකරුගේ වියදම්", 2000)
			PlayerData.add_ledger_entry("expense", "Wedding", -20000)
		38: # Buy Phone (15,000/=)
			_deduct_oops(15000, "අලුත් phone එකක් ගැනීම")
		39: # Baby born (1,000/= monthly)
			f.add_status_effect("has_child", 9999)
			f.add_expense("දරුවාගේ වියදම්", 1000)
		40: # Puberty party (5,000/=)
			ensure_cash(5000, "Puberty Party")
			f.add_expense("දියණියගේ වියදම්", 1000)
			PlayerData.add_ledger_entry("expense", "Big girl party", -5000)
		41: # Parents emergency money (4,000/=)
			_deduct_oops(4000, "දෙමව්පියන්ට හදිසි මුදල් දුන්නා")
		42: # Parents Care (3,000/= monthly)
			f.add_expense("දෙමාපියන්ගේ වියදම්", 3000)
		43: # Child computer (3,000/=)
			_deduct_oops(3000, "Computer Purchase")
		44: # Trip with friends (1,500/=)
			_deduct_oops(1500, "ට්‍රිප් එක")
		45: # Finance seminar / workshop (2,000/=)
			ensure_cash(2000, "Financial Education Seminar")
			PlayerData.add_ledger_entry("expense", "Investing workshop", -2000)
			_draw_free_opportunity()
		46: # Broken TV replacement (1,000/=)
			_deduct_oops(1000, "TV")
		47: # Salary cut (1,000/=)
			f.salary = max(10000, f.salary - 1000)
			f.changed.emit()
		48: # Buy sport bike (18,000/=)
			ensure_cash(18000, "Sport Bike")
			f.add_status_effect("has_bicycle", 9999)
			PlayerData.add_ledger_entry("expense", "Sport Bike එකක් මිලදී ගැනීම", -18000)
		49: # Hospital emergency (1,500/=)
			_deduct_oops(1500, "හදිසි රෝහල්ගත වීමක්")
		50: # Buy medicine (2,000/=)
			_deduct_oops(2000, "හදිසි වෛද්‍ය වියදම්")
		51: # Private hospital tests / checkup (3,000/=)
			_deduct_oops(3000, "Medical checkup")
		53: # Divorce (5,000/=)
			ensure_cash(5000, "Divorce Legal Fees")
			f.remove_expense("සහකරුගේ වියදම්")
			f.status_effects.erase("is_married")
			PlayerData.add_ledger_entry("expense", "දික්කසාද නීතිඥ ගාස්තු", -5000)

		# --- STOCKS & CRYPTO (54-73) ---
		_:
			if type == "Stock" or (cid >= 54 and cid <= 73):
				_execute_stock_trade(card_data)

# Helper for buying standard real estate opportunity cards
func _buy_opportunity(asset_name: String, total_cost: int, down_payment: int, cashflow: int, ledger_name: String = ""):
	var f = PlayerData.financials
	ensure_cash(down_payment, asset_name)
	var liability = total_cost - down_payment
	f.add_real_estate(asset_name, total_cost, liability)
	f.add_income(asset_name, cashflow)
	var entry_desc = ledger_name if ledger_name != "" else (asset_name + " සඳහා Downpayment එක")
	PlayerData.add_ledger_entry("expense", entry_desc, -down_payment)

# Helper for standard Oops deductions with mandatory loan guarantee
func _deduct_oops(amount: int, desc: String):
	ensure_cash(amount, desc)
	PlayerData.add_ledger_entry("expense", desc, -amount)

# Helper for Stock/Crypto transactions
func _execute_stock_trade(card_data: Dictionary):
	var f = PlayerData.financials
	var ticker = _get_stock_ticker(card_data)
	var price = int(card_data.get("price", 0))
	var qty = int(card_data.get("selected_qty", 0))
	var is_sell = card_data.get("is_sell_action", false)
	
	if qty <= 0: return
	
	if is_sell:
		# Sell stock
		var total_proceeds = qty * price
		var owned_qty = _get_owned_stock_qty(ticker)
		var new_qty = max(0, owned_qty - qty)
		if new_qty > 0:
			f.update_stock_qty(ticker, new_qty)
		else:
			f.remove_stock(ticker)
		PlayerData.add_ledger_entry("income", ticker + " කොටස් " + str(qty) + " ක් විකිණීම", total_proceeds)
	else:
		# Buy stock
		var total_cost = qty * price
		ensure_cash(total_cost, "Stock " + ticker)
		var owned_qty = _get_owned_stock_qty(ticker)
		if owned_qty > 0:
			f.update_stock_qty(ticker, owned_qty + qty)
		else:
			f.add_stock(ticker, qty, price)
		PlayerData.add_ledger_entry("expense", ticker + " කොටස් " + str(qty) + " ක් මිලදී ගැනීම", -total_cost)

func _get_stock_ticker(card_data: Dictionary) -> String:
	var desc = card_data.get("back_desc", "")
	var cid = int(card_data.get("id", 0))
	if (cid >= 54 and cid <= 58) or "BTC" in desc or "බිට්කොයින්" in desc:
		return "බිට්කොයින්"
	elif (cid >= 59 and cid <= 62) or "Techno" in desc:
		return "ටෙක්නෝ"
	elif (cid >= 63 and cid <= 67) or "සිකුරු" in desc:
		return "සිකුරු සබන්"
	elif (cid >= 68 and cid <= 73) or "කිරිකොකා" in desc:
		return "කිරිකොකා"
	return "කොටස්"

func _get_owned_stock_qty(ticker: String) -> int:
	if not PlayerData or not PlayerData.financials: return 0
	for s in PlayerData.financials.stocks:
		if s.get("ticker", "") == ticker:
			return int(s.get("qty", 0))
	return 0

# Called when player declines or skips a card
func execute_card_declined(card_data: Dictionary):
	var cid = int(card_data.get("id", 0))
	print("Executing Card Declined: #", cid)
	
	# Certain skipped cards award a free Opportunity card!
	match cid:
		37: # Skipped marriage party -> draw free opportunity
			print("Declined marriage party -> Bonus free Opportunity card drawn!")
			_draw_free_opportunity()
		40: # Skipped puberty party -> draw free opportunity
			print("Declined puberty party -> Bonus free Opportunity card drawn!")
			_draw_free_opportunity()
		48: # Skipped sport bike -> draw free opportunity
			print("Skipped sport bike -> Bonus free Opportunity card drawn!")
			_draw_free_opportunity()

# Trigger free Opportunity card draw
func _draw_free_opportunity():
	# Handled directly by card_popup._trigger_free_opportunity_flow()
	pass