$baseDir = "h:\Game development\Happiness\Project folder\Data\Cards"
$categories = @("Opportunity", "Flash", "Oops", "Stock")

$foundIds = @{}
$errors = @()

foreach ($cat in $categories) {
    $dir = Join-Path $baseDir $cat
    if (-not (Test-Path $dir)) {
        $errors += "Missing category directory: $dir"
        continue
    }
    
    $files = Get-ChildItem -Path $dir -Filter "*.tres"
    foreach ($file in $files) {
        $content = Get-Content -Raw -Path $file.FullName
        
        # Check basic Godot 4 header
        if (-not ($content -match 'script_class="CardResource"')) {
            $errors += "$($file.Name): Missing CardResource script_class header"
        }
        
        # Check ID
        if ($content -match 'id = (\d+)') {
            $id = [int]$matches[1]
            if ($foundIds.ContainsKey($id)) {
                $errors += "Duplicate ID found: $id in $($file.Name) and $($foundIds[$id])"
            } else {
                $foundIds[$id] = $file.FullName
            }
        } else {
            $errors += "$($file.Name): Missing id field"
        }
        
        # Check required fields
        $fields = @("title =", "card_type =", "buttons =", "financial_statement_effect =", "cash_ledger_effect =", "action_key =")
        foreach ($f in $fields) {
            if (-not ($content -match [regex]::Escape($f))) {
                $errors += "$($file.Name): Missing field $f"
            }
        }
    }
}

"Verification Results:"
"Total unique Card IDs found: $($foundIds.Count)/73"

for ($i = 1; $i -le 73; $i++) {
    if (-not $foundIds.ContainsKey($i)) {
        $errors += "Missing card ID: $i"
    }
}

if ($errors.Count -eq 0) {
    "ALL 73 CARDS VERIFIED WITH ZERO ERRORS!"
} else {
    "ERRORS FOUND ($($errors.Count)):"
    $errors | ForEach-Object { " - $_" }
}
