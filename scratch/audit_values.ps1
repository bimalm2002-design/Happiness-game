$reportPath = "C:\Users\bimal\.gemini\antigravity-ide\brain\8aa6732e-7bd4-4729-9f9c-2320b2257771\card_simplified_report.md"
$dbPath = "h:\Game development\Happiness\Project folder\Data\cards_db.json"

$reportText = Get-Content -Raw $reportPath
$db = Get-Content -Raw $dbPath | ConvertFrom-Json

$auditResults = @()

for ($i = 1; $i -le 73; $i++) {
    $c = $db."$i"
    
    # Extract Values Section from reportText for Card i
    $pattern = "(?s)### Card $i \([^\)]+\).*?- \*\*Values Section:\*\* (.*?)(?=\n### Card|\z)"
    $valuesFromReport = "Unknown"
    if ($reportText -match $pattern) {
        $valuesFromReport = $matches[1].Trim()
    }
    
    $cType = if ($c -and $c.type) { $c.type } else { "Unknown" }
    $dbValues = if ($c -and $c.values) { $c.values } else { "N/A" }
    $dbCost = if ($c -and $c.cost) { $c.cost } else { 0 }
    $dbDp = if ($c -and $c.down_payment) { $c.down_payment } else { 0 }
    $dbCf = if ($c -and $c.cashflow) { $c.cashflow } else { 0 }
    
    # Determine value section line count from Report
    $lineCount = 0
    if ($valuesFromReport -eq "None") {
        $lineCount = 0
    } elseif ($valuesFromReport -match "\|") {
        $lineCount = ($valuesFromReport -split "\|").Count
    } else {
        $lineCount = 1
    }
    
    $auditResults += [PSCustomObject]@{
        ID = $i
        Type = $cType
        ExpectedValues = $valuesFromReport
        LineCount = $lineCount
        CurrentDBCost = $dbCost
        CurrentDBDp = $dbDp
        CurrentDBCf = $dbCf
    }
}

$auditResults | Out-String
