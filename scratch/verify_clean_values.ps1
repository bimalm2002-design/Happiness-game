$baseDir = "h:\Game development\Happiness\Project folder\Data\Cards"
$categories = @("Opportunity", "Flash", "Oops", "Stock")

$garbledCount = 0
$noneCount = 0
$totalVerified = 0

foreach ($cat in $categories) {
    $dir = Join-Path $baseDir $cat
    $files = Get-ChildItem -Path $dir -Filter "*.tres"
    foreach ($file in $files) {
        $content = Get-Content -Raw -Encoding UTF8 -Path $file.FullName
        if ($content -match "â€¢") {
            $garbledCount++
        }
        if ($content -match 'values = "None"') {
            $noneCount++
        }
        $totalVerified++
    }
}

"Verification Results:"
"Total Card Resource Files Verified: $totalVerified/73"
"Garbled Characters Found: $garbledCount"
"Cards with Hidden Values (None): $noneCount"
