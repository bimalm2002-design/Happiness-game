$reportPath = "C:\Users\bimal\.gemini\antigravity-ide\brain\8aa6732e-7bd4-4729-9f9c-2320b2257771\card_simplified_report.md"
$reportText = Get-Content -Raw -Encoding UTF8 $reportPath
$dbPath = "h:\Game development\Happiness\Project folder\Data\cards_db.json"
$db = Get-Content -Raw -Encoding UTF8 $dbPath | ConvertFrom-Json

$categoryFolders = @{
    "Opportunity" = "h:\Game development\Happiness\Project folder\Data\Cards\Opportunity";
    "Flash" = "h:\Game development\Happiness\Project folder\Data\Cards\Flash";
    "Oops" = "h:\Game development\Happiness\Project folder\Data\Cards\Oops";
    "Stock" = "h:\Game development\Happiness\Project folder\Data\Cards\Stock"
}

$updatedCount = 0

for ($id = 1; $id -le 73; $id++) {
    # Match card section in reportText
    $pattern = "(?s)### Card $id \(([^\)]+)\).*?- \*\*Description:\*\* (.*?)\n- \*\*Values Section:\*\* (.*?)(?=\n### Card|\z)"
    
    $reportDesc = ""
    $reportValues = ""
    
    if ($reportText -match $pattern) {
        $reportDesc = $matches[2].Trim()
        $reportValues = $matches[3].Trim()
    }
    
    $c = $db."$id"
    $type = if ($c -and $c.type) { $c.type } else { "Opportunity" }
    
    $folder = $categoryFolders[$type]
    if (-not $folder -and $type -eq "Stock") { $folder = $categoryFolders["Stock"] }
    
    $filePath = Join-Path $folder "card_$id.tres"
    
    if (-not (Test-Path $filePath)) {
        "File not found: $filePath"
        continue
    }
    
    $existingContent = Get-Content -Raw -Encoding UTF8 $filePath
    
    # Format reportValues: replace pipe with newline if needed, remove garbled bullet points
    $cleanValues = $reportValues.Replace("•", "").Replace("â€¢", "").Trim()
    if ($cleanValues -eq "None") {
        $cleanValues = "None"
    }
    
    # Replace description line and add values property if not present or replace it
    # Escape quotes and newlines for Godot tres format
    $escapedDesc = $reportDesc.Replace('"', '\"').Replace("`r`n", "\n").Replace("`n", "\n")
    $escapedValues = $cleanValues.Replace('"', '\"').Replace("`r`n", "\n").Replace("`n", "\n")
    
    # Replace description field
    $newContent = [regex]::Replace($existingContent, 'description = ".*?"', "description = `"$escapedDesc`"")
    
    # Ensure values field exists
    if ($newContent -match 'values = ".*?"') {
        $newContent = [regex]::Replace($newContent, 'values = ".*?"', "values = `"$escapedValues`"")
    } else {
        $newContent += "`nvalues = `"$escapedValues`"`n"
    }
    
    [System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)
    
    # Also update db in memory or cards_db.json
    if ($c) {
        $c.back_desc = $reportDesc
        $c.values = $cleanValues
    }
    
    $updatedCount++
}

# Save updated cards_db.json
$jsonStr = $db | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($dbPath, $jsonStr, [System.Text.Encoding]::UTF8)

"Successfully updated $updatedCount .tres files and cards_db.json!"
