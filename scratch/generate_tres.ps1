$db = Get-Content -Raw "h:\Game development\Happiness\Project folder\Data\cards_db.json" | ConvertFrom-Json

$categoryFolders = @{
    "Opportunity" = "h:\Game development\Happiness\Project folder\Data\Cards\Opportunity";
    "Flash" = "h:\Game development\Happiness\Project folder\Data\Cards\Flash";
    "Oops" = "h:\Game development\Happiness\Project folder\Data\Cards\Oops";
    "Stock" = "h:\Game development\Happiness\Project folder\Data\Cards\Stock"
}

# Metadata map for extra fields
$meta = @{
    # Opportunity
    1 = @{ title = "විශ්වවිද්‍යාල කාමර ගොඩනැගිල්ල (University Bldg)"; fs = "Adds Asset 'University Bldg' (80,000), Adds Liability 'University Bldg' (60,000), Adds Passive Income 'University Bldg' (12,000)"; cl = "Deducts Downpayment (-20,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    2 = @{ title = "වාහන නැවතුම්පොළ (Parking Lot)"; fs = "Adds Asset 'Parking Lot' (40,000), Adds Liability 'Parking Lot' (30,000), Adds Passive Income 'Parking Lot' (6,000)"; cl = "Deducts Downpayment (-10,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Correlates with Card 20"; action = "invest_real_estate" };
    3 = @{ title = "කඩකාමර 06 සංකීර්ණය (6-Shop Complex)"; fs = "Adds Asset '6-Shop Complex' (90,000), Adds Liability '6-Shop Complex' (65,000), Adds Passive Income '6-Shop Complex' (15,000)"; cl = "Deducts Downpayment (-25,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    4 = @{ title = "කුරුදු ඉඩම (Cinnamon Land)"; fs = "Adds Asset 'Cinnamon Land' (30,000), Adds Liability 'Cinnamon Land' (25,000), Adds Passive Income 'Cinnamon Land' (3,000)"; cl = "Deducts Downpayment (-5,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    5 = @{ title = "පොල් ඉඩම (Coconut Land)"; fs = "Adds Asset 'Coconut Land' (60,000), Adds Liability 'Coconut Land' (45,000), Adds Passive Income 'Coconut Land' (9,000)"; cl = "Deducts Downpayment (-15,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    6 = @{ title = "රබර් ඉඩම (Rubber Land)"; fs = "Adds Asset 'Rubber Land' (50,000), Adds Liability 'Rubber Land' (38,000), Adds Passive Income 'Rubber Land' (7,500)"; cl = "Deducts Downpayment (-12,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    7 = @{ title = "තේ ඉඩම (Tea Estate)"; fs = "Adds Asset 'Tea Estate' (70,000), Adds Liability 'Tea Estate' (52,000), Adds Passive Income 'Tea Estate' (10,500)"; cl = "Deducts Downpayment (-18,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    8 = @{ title = "කාමර 02ක නිවස (2-Room House)"; fs = "Adds Asset '2-Room House' (45,000), Adds Liability '2-Room House' (35,000), Adds Passive Income '2-Room House' (5,000)"; cl = "Deducts Downpayment (-10,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    9 = @{ title = "නගරයේ Apartment එක (City Apartment)"; fs = "Adds Asset 'City Apartment' (110,000), Adds Liability 'City Apartment' (80,000), Adds Passive Income 'City Apartment' (18,000)"; cl = "Deducts Downpayment (-30,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    10 = @{ title = "මෘදුකාංග ව්‍යාපෘතිය (Software Project)"; fs = "Adds Asset 'Software Project' (20,000). No liability, No Cashflow."; cl = "Deducts Total Investment (-20,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Correlates with Card 19"; action = "invest_software" };
    11 = @{ title = "පොතේ පේටන්ට් අයිතිය (Book Patent)"; fs = "Adds Asset 'Book Patent' (10,000), Adds Passive Income 'Book Patent' (2,500). No liability."; cl = "Deducts Total Investment (-10,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Correlates with Card 21"; action = "invest_patent" };
    12 = @{ title = "සුපිරි වෙළඳසැල් කොටස් (Supermarket Shares)"; fs = "Adds Asset 'Supermarket Shares' (50,000), Adds Liability 'Supermarket Shares' (35,000), Adds Passive Income 'Supermarket Shares' (8,000)"; cl = "Deducts Downpayment (-15,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_real_estate" };
    52 = @{ title = "සූර්ය බලශක්ති පද්ධතිය (Solar Panel System)"; fs = "Adds Asset 'Solar Panel System' (35,000), Adds Passive Income 'Solar Panel System' (1,000), Removes Electricity Expense (විදුලි වියදම්)"; cl = "Deducts Cost (-35,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Removes electricity expenses"; action = "invest_solar" };

    # Flash
    13 = @{ title = "වේදිකා නාට්‍යය (Stage Drama)"; fs = "Adds Asset 'Stage Drama' (15,000)"; cl = "Deducts Investment (-15,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Correlates with Card 16 and 17"; action = "invest_drama" };
    14 = @{ title = "සංගීත ප්‍රසංගය (Musical Show)"; fs = "Adds Asset 'Musical Show' (25,000)"; cl = "Deducts Investment (-25,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Correlates with Card 15 and 18"; action = "invest_concert" };
    15 = @{ title = "සංගීත ප්‍රසංගයේ ලාභය (Concert Profit)"; fs = "Removes Asset 'Musical Show'"; cl = "Adds Revenue (+55,000)"; ign = "Auto-executes or Sell"; fund = "N/A"; dep = "Requires Card 14"; action = "sell_concert_success" };
    16 = @{ title = "වේදිකා නාට්‍යයේ ලාභය (Drama Profit)"; fs = "Removes Asset 'Stage Drama'"; cl = "Adds Revenue (+35,000)"; ign = "Auto-executes or Sell"; fund = "N/A"; dep = "Requires Card 13"; action = "sell_drama_profit" };
    17 = @{ title = "වේදිකා නාට්‍යයේ පාඩුව (Drama Loss)"; fs = "Removes Asset 'Stage Drama'"; cl = "Deducts Loss (-5,000)"; ign = "Auto-executes if Card 13 owned"; fund = "Mandatory Loan if cash < 5,000"; dep = "Requires Card 13"; action = "loss_drama_crash" };
    18 = @{ title = "සංගීත ප්‍රසංගයේ අවදානම (Concert Risk)"; fs = "Removes Asset 'Musical Show'"; cl = "Adds Partial Return (+10,000)"; ign = "Auto-executes if Card 14 owned"; fund = "N/A"; dep = "Requires Card 14"; action = "return_concert_risk" };
    19 = @{ title = "මෘදුකාංග ව්‍යාපෘතිය විකිණීම (Sell Software)"; fs = "Removes Asset 'Software Project'"; cl = "Adds Sale Price (+50,000)"; ign = "Active only if Card 10 owned"; fund = "N/A"; dep = "Requires Card 10"; action = "sell_software" };
    20 = @{ title = "වාහන නැවතුම්පොළ විකිණීම (Sell Parking Lot)"; fs = "Removes Asset 'Parking Lot', Removes Liability 'Parking Lot', Removes Passive Income 'Parking Lot'"; cl = "Adds Sale Price (+80,000)"; ign = "Active only if Card 2 owned"; fund = "N/A"; dep = "Requires Card 2"; action = "sell_parking_lot" };
    21 = @{ title = "පොතේ පේටන්ට් අයිතිය විකිණීම (Sell Patent)"; fs = "Removes Asset 'Book Patent', Removes Passive Income 'Book Patent'"; cl = "Adds Sale Price (+15,000)"; ign = "Active only if Card 11 owned"; fund = "N/A"; dep = "Requires Card 11"; action = "sell_book_patent" };
    22 = @{ title = "ටෙක්නෝ ක්‍රිප්ටෝ කඩාවැටීම (Techno Crash)"; fs = "Removes all 'Techno' shares/coins from Assets"; cl = "None directly (Investment lost)"; ign = "Auto-executes. Cannot be ignored."; fund = "N/A"; dep = "Targets Techno Crypto"; action = "techno_crash" };
    23 = @{ title = "ගඟ අසල ඉඩම විකිණීම (Sell River Land)"; fs = "Removes Asset 'River Land'"; cl = "Adds Sale Price (+120,000)"; ign = "Active only if Card 24 owned"; fund = "N/A"; dep = "Requires Card 24"; action = "sell_river_land" };
    24 = @{ title = "ගඟ අසල ඉඩම මිලදී ගැනීම (Buy River Land)"; fs = "Adds Asset 'River Land' (60,000)"; cl = "Deducts Investment (-60,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Correlates with Card 23"; action = "buy_river_land" };
    25 = @{ title = "ක්‍රීඩා බයිසිකලය විකිණීම (Sell Sport Bike)"; fs = "Removes status 'has_bicycle'"; cl = "Adds Cash (+25,000)"; ign = "Active only if Card 48 owned"; fund = "N/A"; dep = "Requires Card 48"; action = "sell_sport_bike" };
    26 = @{ title = "සමාගම් බෝනස් මුදල (Company Bonus)"; fs = "None"; cl = "Adds Cash (+3,000)"; ign = "Auto-executes (OK)"; fund = "N/A"; dep = "None"; action = "bonus_cash" };
    27 = @{ title = "වැටුප් වැඩිවීම (Salary Increment)"; fs = "Increases Active Income (Salary) by 2,000"; cl = "None directly (Boosts future Paydays)"; ign = "Auto-executes (OK)"; fund = "N/A"; dep = "None"; action = "salary_increment" };
    28 = @{ title = "කුකුළු ගොවිපල (Poultry Farm)"; fs = "Adds Asset 'Poultry Farm' (40,000), Adds Passive Income 'Poultry Farm' (5,000)"; cl = "Deducts Investment (-40,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "invest_poultry" };
    29 = @{ title = "සත්වෝද්‍යානය අසල ඉඩම (Zoo Land)"; fs = "Adds Asset 'Zoo Land' (50,000)"; cl = "Deducts Investment (-50,000)"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Correlates with Card 31"; action = "buy_zoo_land" };
    30 = @{ title = "පාරම්පරික ස්වර්ණාභරණ (Inherit Jewelry)"; fs = "Adds Asset 'Jewelry' (100,000)"; cl = "None"; ign = "Auto-executes (OK)"; fund = "N/A"; dep = "None"; action = "inherit_jewelry" };
    31 = @{ title = "සත්වෝද්‍යානය අසල ඉඩම විකිණීම (Sell Zoo Land)"; fs = "Removes Asset 'Zoo Land'"; cl = "Adds Sale Price (+90,000)"; ign = "Active only if Card 29 owned"; fund = "N/A"; dep = "Requires Card 29"; action = "sell_zoo_land" };

    # Oops
    32 = @{ title = "මාස 3ක් වැටුප් රහිත නිවාඩු (Unpaid Leave 3 Months)"; fs = "Sets status 'no_salary' for 3 paydays"; cl = "None directly"; ign = "Cannot be ignored"; fund = "Mandatory Loan equal to (3 * Total Expenses) - (Cash + Cashflow)"; dep = "None"; action = "unpaid_leave_3m" };
    33 = @{ title = "හදිසි වෛද්‍ය වියදම් (Medical Emergency)"; fs = "None"; cl = "Deducts Cost (-8,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 8,000"; dep = "None"; action = "emergency_medical" };
    34 = @{ title = "හදිසි අනතුර - අඩ වැටුප් (Accident Half Salary)"; fs = "Sets status 'half_salary' for 2 paydays"; cl = "None directly"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash insufficient for expenses"; dep = "None"; action = "accident_half_sal" };
    35 = @{ title = "දරුවාගේ විභාග වියදම් (Child Exam Retake)"; fs = "None"; cl = "Deducts Cost (-6,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 6,000"; dep = "Requires Child (Card 39)"; action = "child_exam" };
    36 = @{ title = "ගෘහ උපකරණ අලුත්වැඩියාව (Appliance Repair)"; fs = "None"; cl = "Deducts Cost (-4,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 4,000"; dep = "None"; action = "appliance_repair" };
    37 = @{ title = "විවාහය (Marriage)"; fs = "Adds 2,000 to Expenses (සහකරුගේ වියදම්)"; cl = "Deducts 20,000 (If skipped, draw free Opportunity)"; ign = "Can be skipped (Ignore)"; fund = "Optional Loan available"; dep = "Required for 39 and 53"; action = "marriage" };
    38 = @{ title = "වාහන අලුත්වැඩියාව (Vehicle Repair)"; fs = "None"; cl = "Deducts Cost (-7,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 7,000"; dep = "None"; action = "vehicle_repair" };
    39 = @{ title = "දරු උපත (Baby Born)"; fs = "Adds 1,000 to Expenses (දරුවාගේ වියදම්)"; cl = "None"; ign = "Cannot be ignored"; fund = "N/A"; dep = "Requires Marriage (Card 37)"; action = "baby_born" };
    40 = @{ title = "දියණිය වැඩිවියට පත්වීමේ සාදය (Puberty Party)"; fs = "Adds 1,000 to Expenses"; cl = "Deducts 5,000 for party (If skipped, draw free Opportunity)"; ign = "Can be skipped (Ignore)"; fund = "Optional Loan available"; dep = "Requires Child (Card 39)"; action = "puberty_party" };
    41 = @{ title = "නෛතික ආරවුලක් (Legal Dispute)"; fs = "None"; cl = "Deducts Cost (-10,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 10,000"; dep = "None"; action = "legal_dispute" };
    42 = @{ title = "දෙමාපියන්ගේ වෛද්‍ය වියදම් (Parents Care)"; fs = "Adds 3,000 to Expenses permanently"; cl = "None directly"; ign = "Cannot be ignored"; fund = "N/A"; dep = "None"; action = "parents_care" };
    43 = @{ title = "දරුවාට පරිගණකයක් (Child Computer)"; fs = "None"; cl = "Deducts Cost (-12,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 12,000"; dep = "Requires Child (Card 39)"; action = "child_computer" };
    44 = @{ title = "රථවාහන දඩ මුදලක් (Traffic Fine)"; fs = "None"; cl = "Deducts Cost (-3,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 3,000"; dep = "None"; action = "traffic_fine" };
    45 = @{ title = "මූල්‍ය අධ්‍යාපන සම්මන්ත්‍රණය (Finance Seminar)"; fs = "None"; cl = "Deducts Cost (-2,000). If accepted, draw free Opportunity."; ign = "Can be skipped (Pass)"; fund = "Optional Loan available"; dep = "Draws Opportunity card"; action = "finance_seminar" };
    46 = @{ title = "දන්ත සැත්කමක් (Dental Surgery)"; fs = "None"; cl = "Deducts Cost (-5,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 5,000"; dep = "None"; action = "dental_surgery" };
    47 = @{ title = "වැටුප් කප්පාදුව (Salary Cut)"; fs = "Reduces Active Income (Salary) by 1,000 permanently"; cl = "None directly"; ign = "Cannot be ignored"; fund = "N/A"; dep = "None"; action = "salary_cut" };
    48 = @{ title = "ක්‍රීඩා බයිසිකලයක් මිලදී ගැනීම (Buy Sport Bike)"; fs = "Sets status 'has_bicycle'"; cl = "Deducts Cost (-18,000). If skipped, draw free Opportunity."; ign = "Can be skipped (Pass)"; fund = "Optional Loan available"; dep = "Required for Card 25"; action = "buy_bike" };
    49 = @{ title = "නිවසේ වහලය අලුත්වැඩියාව (Roof Repair)"; fs = "None"; cl = "Deducts Cost (-9,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 9,000"; dep = "None"; action = "roof_repair" };
    50 = @{ title = "ඉලෙක්ට්‍රොනික උපකරණ අස්ථානගතවීම (Gadget Theft)"; fs = "None"; cl = "Deducts Cost (-6,000)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 6,000"; dep = "None"; action = "gadget_theft" };
    51 = @{ title = "මිතුරෙකුගේ මංගල තෑග්ග (Wedding Gift)"; fs = "None"; cl = "Deducts Cost (-3,500)"; ign = "Cannot be ignored"; fund = "Mandatory Loan if cash < 3,500"; dep = "None"; action = "wedding_gift" };
    53 = @{ title = "දික්කසාදය (Divorce)"; fs = "Removes 2,000 Spouse Expense"; cl = "Deducts Legal Fees (-5,000)"; ign = "Auto-executes"; fund = "Mandatory Loan if cash < 5,000"; dep = "Requires Marriage (Card 37)"; action = "divorce" };

    # Stocks
    54 = @{ title = "බිට්කොයින් (BTC Crypto)"; fs = "Adds/Updates Asset 'BTC'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    55 = @{ title = "බිට්කොයින් (BTC Crypto)"; fs = "Adds/Updates Asset 'BTC'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    56 = @{ title = "බිට්කොයින් (BTC Crypto)"; fs = "Adds/Updates Asset 'BTC'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    57 = @{ title = "බිට්කොයින් (BTC Crypto)"; fs = "Adds/Updates Asset 'BTC'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    58 = @{ title = "බිට්කොයින් (BTC Crypto)"; fs = "Adds/Updates Asset 'BTC'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };

    59 = @{ title = "ටෙක්නෝ ක්‍රිප්ටෝ (Techno Crypto)"; fs = "Adds/Updates Asset 'Techno'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Subject to crash by Card 22"; action = "trade_stock" };
    60 = @{ title = "ටෙක්නෝ ක්‍රිප්ටෝ (Techno Crypto)"; fs = "Adds/Updates Asset 'Techno'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Subject to crash by Card 22"; action = "trade_stock" };
    61 = @{ title = "ටෙක්නෝ ක්‍රිප්ටෝ (Techno Crypto)"; fs = "Adds/Updates Asset 'Techno'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Subject to crash by Card 22"; action = "trade_stock" };
    62 = @{ title = "ටෙක්නෝ ක්‍රිප්ටෝ (Techno Crypto)"; fs = "Adds/Updates Asset 'Techno'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "Subject to crash by Card 22"; action = "trade_stock" };

    63 = @{ title = "සිකුරු සබන් සමාගම (Sikuru Saban)"; fs = "Adds/Updates Asset 'Sikuru Saban'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    64 = @{ title = "සිකුරු සබන් සමාගම (Sikuru Saban)"; fs = "Adds/Updates Asset 'Sikuru Saban'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    65 = @{ title = "සිකුරු සබන් සමාගම (Sikuru Saban)"; fs = "Adds/Updates Asset 'Sikuru Saban'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    66 = @{ title = "සිකුරු සබන් සමාගම (Sikuru Saban)"; fs = "Adds/Updates Asset 'Sikuru Saban'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    67 = @{ title = "සිකුරු සබන් සමාගම (Sikuru Saban)"; fs = "Adds/Updates Asset 'Sikuru Saban'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };

    68 = @{ title = "කිරිකෝකා දන්තාලේප (Kirikoka Toothpaste)"; fs = "Adds/Updates Asset 'Kirikoka'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    69 = @{ title = "කිරිකෝකා දන්තාලේප (Kirikoka Toothpaste)"; fs = "Adds/Updates Asset 'Kirikoka'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    70 = @{ title = "කිරිකෝකා දන්තාලේප (Kirikoka Toothpaste)"; fs = "Adds/Updates Asset 'Kirikoka'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    71 = @{ title = "කිරිකෝකා දන්තාලේප (Kirikoka Toothpaste)"; fs = "Adds/Updates Asset 'Kirikoka'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    72 = @{ title = "කිරිකෝකා දන්තාලේප (Kirikoka Toothpaste)"; fs = "Adds/Updates Asset 'Kirikoka'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
    73 = @{ title = "කිරිකෝකා දන්තාලේප (Kirikoka Toothpaste)"; fs = "Adds/Updates Asset 'Kirikoka'"; cl = "Deducts (Qty * Price) on buy / Adds on sell"; ign = "Can be ignored (Pass)"; fund = "Optional Loan available"; dep = "None"; action = "trade_stock" };
}

$count = 0
foreach ($prop in $db.PSObject.Properties) {
    $c = $prop.Value
    $id = [int]$c.id
    $type = $c.type
    
    $folder = $categoryFolders[$type]
    if (-not $folder) {
        if ($type -eq "Stock") { $folder = $categoryFolders["Stock"] }
    }
    
    $filePath = Join-Path $folder "card_$id.tres"
    
    $m = $meta[$id]
    $cardTitle = if ($m -and $m.title) { $m.title } else { "Card $id" }
    $fsEffect = if ($m -and $m.fs) { $m.fs } else { "None" }
    $clEffect = if ($m -and $m.cl) { $m.cl } else { "None" }
    $ignRule = if ($m -and $m.ign) { $m.ign } else { "Can be ignored" }
    $fundRule = if ($m -and $m.fund) { $m.fund } else { "Optional Loan available" }
    $depRule = if ($m -and $m.dep) { $m.dep } else { "None" }
    $actKey = if ($m -and $m.action) { $m.action } else { "default" }
    
    $cost = if ($c.cost) { [int]$c.cost } else { 0 }
    $dp = if ($c.down_payment) { [int]$c.down_payment } else { 0 }
    $cf = if ($c.cashflow) { [int]$c.cashflow } else { 0 }
    $pen = if ($c.penalty) { [int]$c.penalty } else { 0 }
    $price = if ($c.price) { [int]$c.price } else { 0 }
    
    $desc = if ($c.back_desc) { $c.back_desc } else { "" }
    # Escape quotes and newlines for Godot format
    $escapedDesc = $desc.Replace('"', '\"').Replace("`r`n", "\n").Replace("`n", "\n")
    $escapedTitle = $cardTitle.Replace('"', '\"')
    $escapedFs = $fsEffect.Replace('"', '\"')
    $escapedCl = $clEffect.Replace('"', '\"')
    $escapedIgn = $ignRule.Replace('"', '\"')
    $escapedFund = $fundRule.Replace('"', '\"')
    $escapedDep = $depRule.Replace('"', '\"')
    
    $buttonsArr = @()
    if ($c.buttons) {
        foreach ($b in $c.buttons) {
            $buttonsArr += "`"$b`""
        }
    }
    $buttonsStr = "[" + ($buttonsArr -join ", ") + "]"
    
    $tresContent = @"
[gd_resource type="Resource" script_class="CardResource" load_steps=2 format=3]

[ext_resource type="Script" path="res://Scripts/Resources/card_resource.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
id = $id
title = "$escapedTitle"
card_type = "$type"
description = "$escapedDesc"
cost = $cost
down_payment = $dp
cashflow = $cf
penalty = $pen
price_per_share = $price
buttons = $buttonsStr
financial_statement_effect = "$escapedFs"
cash_ledger_effect = "$escapedCl"
ignore_skip_rule = "$escapedIgn"
insufficient_funds_rule = "$escapedFund"
interdependencies = "$escapedDep"
action_key = "$actKey"
"@

    # Write as UTF8 without BOM
    [System.IO.File]::WriteAllText($filePath, $tresContent, [System.Text.Encoding]::UTF8)
    $count++
}

"Successfully generated $count .tres resource files!"
