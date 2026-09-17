
$path = "C:\Users\bimal\.gemini\antigravity-ide\brain\343a8218-20fa-4092-bcec-e5cac3146552\.system_generated\logs\transcript_full.jsonl"
Get-Content $path -Tail 2000 | Where-Object { $_ -match "Set-Content -Path .*generate_new_board.gd.* -Value" } | Select-Object -Last 2 | Out-File last_matches.txt

