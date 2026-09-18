$reportPath = "C:\Users\bimal\.gemini\antigravity-ide\brain\8aa6732e-7bd4-4729-9f9c-2320b2257771\card_simplified_report.md"
$reportText = Get-Content -Raw $reportPath

$md = @"
# 📊 Audit Report: Card Values Section Analysis (Cards 1 - 73)

## 📌 Executive Summary & Root Cause Analysis

### The Identified Issue:
In the current Godot implementation, the card popup renderer (`card_popup.gd`) generates default entries for **Cost**, **Cashflow**, **Downpayment**, and **Penalty** whenever those fields exist on a card dictionary. As a result:
- Cards that should have **NO Values Section** (e.g. Card 22, Card 32, Card 34, Card 47) were displaying up to 4 zero/default lines.
- Cards that should have **ONLY 1 single value line** (e.g. Oops expenses like Card 33, 38, 41, 48 or Flash payouts like Card 20, 21, 23, 26) were displaying 4 lines.
- Cards that should have **2 value lines** (Investment & Cashflow) were displaying unwanted Downpayment/Penalty lines.

---

## 📂 Categorized Summary by Value Line Count

| Group Category | Line Count | Card IDs | Total Cards |
| :--- | :---: | :--- | :---: |
| **Group A: No Values Section ("None")** | **0 Lines** | 22, 32, 34, 47 | 4 Cards |
| **Group B: Single Value Item** | **1 Line** | 17, 19, 20, 21, 23, 24, 25, 26, 27, 29, 30, 31, 33, 35, 36, 38, 39, 41, 42, 43, 44, 45, 46, 48, 49, 50, 51, 53 | 28 Cards |
| **Group C: Two Value Items (Cost/Price & Cashflow/Range)** | **2 Lines** | 8, 9, 10, 11, 12, 13, 14, 16, 28, 37, 40, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73 | 31 Cards |
| **Group D: Three Value Items (Total, Cashflow, Downpayment)** | **3 Lines** | 1, 2, 3, 4, 5, 6, 7, 15, 18 | 9 Cards |
| **Group E: Multi-Stage Custom Text** | **Multi-Line** | 52 | 1 Card |

---

## 📜 Full 73-Card Audit Breakdown

"@

$tableRows = @()

for ($i = 1; $i -le 73; $i++) {
    $pattern = "(?s)### Card $i \(([^\)]+)\).*?- \*\*Description:\*\* (.*?)\n- \*\*Values Section:\*\* (.*?)(?=\n### Card|\z)"
    if ($reportText -match $pattern) {
        $type = $matches[1].Trim()
        $desc = $matches[2].Trim()
        $vals = $matches[3].Trim()
        
        $lineCount = 1
        if ($vals -eq "None") {
            $lineCount = 0
        } else {
            $lineCount = ($vals -split "\|").Count
        }
        
        $cleanVals = $vals.Replace("`n", " ").Replace("|", " <br> ")
        
        $tableRows += "| **$i** | $type | $lineCount | $cleanVals |"
    }
}

$md += @"

| Card # | Category | Expected Lines | Authoritative Values Section Content |
| :---: | :--- | :---: | :--- |
"@

$md += "`n" + ($tableRows -join "`n")

$md += @"

---

## 🔧 Proposed Action Plan to Fix Card UI Display

1. **Update `.tres` Resource Files:**
   Set the exact formatted `values` string on each of the 73 `.tres` files matching `card_simplified_report.md`.

2. **Update Popup Renderer (`card_popup.gd`):**
   Modify `_build_values_bbcode` so that:
   - If `values` is `"None"` or empty, the Values Section is completely hidden (0 lines).
   - If `values` is set on the resource, it directly renders that string without auto-appending unwanted Cost/Cashflow/Downpayment/Penalty zero-lines.
   - For Stock cards, render strictly the **price per coin/share** and **Trading range** (2 lines).

"@

$outputPath = "C:\Users\bimal\.gemini\antigravity-ide\brain\8aa6732e-7bd4-4729-9f9c-2320b2257771\card_values_audit_report.md"
[System.IO.File]::WriteAllText($outputPath, $md, [System.Text.Encoding]::UTF8)
"Audit Report generated successfully at: $outputPath"
