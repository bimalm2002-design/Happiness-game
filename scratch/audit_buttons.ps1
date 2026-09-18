$dbPath = "h:\Game development\Happiness\Project folder\Data\cards_db.json"
$db = Get-Content -Raw -Encoding UTF8 $dbPath | ConvertFrom-Json

$noButtonCards = @()
$buttonCards = @()

for ($i = 1; $i -le 73; $i++) {
    $c = $db."$i"
    $btns = if ($c -and $c.buttons) { $c.buttons } else { @() }
    
    if ($btns.Count -eq 0) {
        $noButtonCards += [PSCustomObject]@{ ID = $i; Type = $c.type; Title = $c.back_title; Desc = $c.back_desc }
    } else {
        $buttonCards += [PSCustomObject]@{ ID = $i; Type = $c.type; Buttons = ($btns -join ", ") }
    }
}

"CARDS WITH NO BUTTONS ($($noButtonCards.Count) Cards):"
$noButtonCards | Format-Table -AutoSize

"CARDS WITH BUTTONS ($($buttonCards.Count) Cards):"
$buttonCards | Out-String
