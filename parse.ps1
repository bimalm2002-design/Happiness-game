
$json = Get-Content "H:\Game development\Happiness\UI elements\Quick JSON\02.json" -Raw | ConvertFrom-Json
$colors = @{
    "rgb(74, 130, 251)" = "blue"
    "rgb(89, 212, 52)" = "green"
    "rgb(207, 106, 232)" = "purple"
    "rgb(251, 50, 50)" = "red"
    "rgb(132, 132, 132)" = "gray"
    "rgb(252, 222, 26)" = "yellow"
}
function Find-Rects($node) {
    if ($node.type -eq "RECTANGLE" -and $node.styles -and $node.styles.bg) {
        $colorName = $colors[$node.styles.bg]
        if (-not $colorName) { $colorName = $node.styles.bg }
        Write-Output "N:$($node.name) W:$($node.size.w) H:$($node.size.h) C:$colorName"
    }
    if ($node.children) {
        foreach ($child in $node.children) {
            Find-Rects $child
        }
    }
}
Find-Rects $json.structure

