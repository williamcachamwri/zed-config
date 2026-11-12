# Install zed-config on Windows 11
$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$zedDir = "$env:APPDATA\Zed"
$ps7Dir = "$HOME\Documents\PowerShell"
$ps5Dir = "$HOME\Documents\WindowsPowerShell"

New-Item -ItemType Directory -Force -Path "$zedDir\themes", "$zedDir\tools", "$zedDir\snippets", $ps7Dir, $ps5Dir | Out-Null

Copy-Item "$repoRoot\settings.json", "$repoRoot\keymap.json", "$repoRoot\tasks.json" $zedDir -Force
Copy-Item "$repoRoot\themes\*" "$zedDir\themes\" -Force
Copy-Item "$repoRoot\tools\*" "$zedDir\tools\" -Force
Copy-Item "$repoRoot\snippets\*" "$zedDir\snippets\" -Force

Copy-Item "$repoRoot\powershell\Microsoft.PowerShell_profile.ps1" "$ps7Dir\Microsoft.PowerShell_profile.ps1" -Force
Copy-Item "$repoRoot\powershell\Microsoft.PowerShell_profile.ps1" "$ps5Dir\Microsoft.PowerShell_profile.ps1" -Force

Write-Host "Installed Zed config and PowerShell profile." -ForegroundColor Green
