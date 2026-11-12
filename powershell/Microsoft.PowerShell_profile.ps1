# PowerShell 7 profile

# UTF-8 encoding
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
    chcp 65001 > $null
}

$script:__LastCmdStart = $null

# PSReadLine setup
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine -MinimumVersion 2.1.0 -ErrorAction SilentlyContinue
    if (-not (Get-Module PSReadLine)) { Import-Module PSReadLine }

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -ShowToolTips

    # Inline history suggestions
    if (((Get-Module PSReadLine).Version -ge [version]'2.1.0') -and (-not [Console]::IsOutputRedirected)) {
        try {
            Set-PSReadLineOption -PredictionSource History
            Set-PSReadLineOption -PredictionViewStyle InlineView
            Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
        } catch {}
    }

    # Fuzzy history search with fzf (Ctrl+R)
    if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (-not [Console]::IsOutputRedirected)) {
        Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
            $histPath = (Get-PSReadLineOption).HistorySavePath
            if (Test-Path $histPath) {
                $lines = Get-Content $histPath -ErrorAction SilentlyContinue
                [array]::Reverse($lines)
                $selected = $lines | Select-Object -Unique | fzf --height 40% --layout=reverse --border --prompt="> "
                if ($selected) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
                }
            }
        }
    }

    $esc = [char]27
    $colors = @{
        Command   = "$esc[38;2;56;189;248m"
        Parameter = "$esc[38;2;148;163;184m"
        String    = "$esc[38;2;52;211;153m"
        Operator  = "$esc[38;2;125;211;252m"
        Variable  = "$esc[38;2;244;114;182m"
        Number    = "$esc[38;2;244;114;182m"
        Keyword   = "$esc[38;2;192;132;252m"
        Type      = "$esc[38;2;45;212;191m"
        Comment   = "$esc[38;2;100;116;139m"
        Error     = "$esc[38;2;248;113;113m"
        Default   = "$esc[38;2;226;232;240m"
    }
    if ((Get-Module PSReadLine).Version -ge [version]'2.1.0') {
        $colors['InlinePrediction'] = "$esc[38;2;100;116;139m"
    }
    Set-PSReadLineOption -Colors $colors

    Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
        $script:__LastCmdStart = Get-Date
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

# zoxide init
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Two-line prompt with git status and command duration
function prompt {
    $lastOk = $?
    $esc = [char]27
    $reset = "$esc[0m"

    $cCyan   = "$esc[38;2;56;189;248m"
    $cPurple = "$esc[38;2;192;132;252m"
    $cGreen  = "$esc[38;2;52;211;153m"
    $cYellow = "$esc[38;2;251;191;36m"
    $cRed    = "$esc[38;2;248;113;113m"
    $cMuted  = "$esc[38;2;100;116;139m"

    $durationText = ""
    if ($null -ne $script:__LastCmdStart) {
        $elapsed = (Get-Date) - $script:__LastCmdStart
        $script:__LastCmdStart = $null
        if ($elapsed.TotalMilliseconds -ge 500) {
            if ($elapsed.TotalSeconds -ge 60) {
                $durationText = " ${cMuted}took ${cYellow}$([math]::Floor($elapsed.TotalMinutes))m $([math]::Round($elapsed.Seconds))s${reset}"
            } else {
                $durationText = " ${cMuted}took ${cYellow}$([math]::Round($elapsed.TotalSeconds, 1))s${reset}"
            }
        }
    }

    $rawPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($rawPath.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase)) {
        $displayPath = "~" + $rawPath.Substring($HOME.Length)
    } else {
        $displayPath = $rawPath
    }
    $displayPath = $displayPath -replace '\\', '/'

    $gitText = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $branch) {
            $dirty = git status --porcelain --ignore-submodules -uno 2>$null
            if ($dirty) {
                $gitText = " ${cMuted}on ${cPurple}${branch}${cYellow} *${reset}"
            } else {
                $gitText = " ${cMuted}on ${cPurple}${branch}${cGreen} ok${reset}"
            }
        }
    }

    $arrowColor = if ($lastOk) { $cGreen } else { $cRed }

    Write-Host ""
    Write-Host "${cCyan}${displayPath}${reset}${gitText}${durationText}"
    return "${arrowColor}❯${reset} "
}

# Navigation and file helpers
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function open { param([string]$Path = ".") Invoke-Item $Path }
function mkcd { param([string]$Path) New-Item -ItemType Directory -Force -Path $Path | Out-Null; Set-Location $Path }
function touch { param([string]$Path) if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date } else { New-Item -ItemType File -Path $Path | Out-Null } }
function which { param([string]$Name) (Get-Command $Name -ErrorAction SilentlyContinue).Source }
function reload { . $PROFILE; Write-Host "Reloaded profile." -ForegroundColor Green }

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ll { param([string]$Path = ".") eza -la --icons --git --group-directories-first $Path }
    function la { param([string]$Path = ".") eza -a --icons --group-directories-first $Path }
    function lt { param([int]$Depth = 2, [string]$Path = ".") eza --tree --level=$Depth --icons --git-ignore $Path }
} else {
    function ll { Get-ChildItem -Force }
    function la { Get-ChildItem -Force -Name }
    function lt { Get-ChildItem -Depth 2 }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    function catn { param([Parameter(Mandatory)][string]$Path) bat --style=numbers,changes,header $Path }
} else {
    function catn {
        param([Parameter(Mandatory)][string]$Path)
        $i = 1
        Get-Content $Path | ForEach-Object {
            Write-Host ("{0,4} | " -f $i) -NoNewline -ForegroundColor DarkGray
            Write-Host $_
            $i++
        }
    }
}

$script:__IgnoreDirsRegex = '[\\/](\.git|node_modules|target|bin|obj|build|\.vs)[\\/]'

function ff {
    param([Parameter(Mandatory)][string]$Name)
    Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $script:__IgnoreDirsRegex -and $_.Name -like "*$Name*" } |
        ForEach-Object { $_.FullName.Replace((Get-Location).Path + "\", "") }
}

function fe {
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        $file = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch $script:__IgnoreDirsRegex } |
            ForEach-Object { $_.FullName.Replace((Get-Location).Path + "\", "") } |
            fzf --height 60% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :100 {}"
        if ($file) { zed $file }
    }
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { param([Parameter(Mandatory)][string]$Pattern, [string]$Path = ".") rg --smart-case $Pattern $Path }
} else {
    function grep {
        param([Parameter(Mandatory)][string]$Pattern, [string]$Path = ".")
        Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch $script:__IgnoreDirsRegex } |
            Select-String -Pattern $Pattern |
            ForEach-Object {
                $rel = $_.Path.Replace((Get-Location).Path + "\", "")
                Write-Host "${rel}:$($_.LineNumber): " -NoNewline -ForegroundColor Cyan
                Write-Host $_.Line.Trim()
            }
    }
}

function head { param([Parameter(Mandatory)][string]$Path, [int]$N = 20) Get-Content $Path -TotalCount $N }
function tail { param([Parameter(Mandatory)][string]$Path, [int]$N = 20) Get-Content $Path -Tail $N }

function sizeof {
    param([string]$Path = ".")
    $bytes = (Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    if ($null -eq $bytes) { $bytes = 0 }
    if ($bytes -ge 1GB) { "{0:N2} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { "{0:N2} KB" -f ($bytes / 1KB) }
    else { "$bytes B" }
}

# Process, port and system helpers
function ports {
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Sort-Object LocalPort -Unique |
        ForEach-Object {
            $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
            [PSCustomObject]@{
                Port    = $_.LocalPort
                PID     = $_.OwningProcess
                Process = $proc.ProcessName
            }
        } | Format-Table -AutoSize
}

function killport {
    param([Parameter(Mandatory)][int]$Port)
    $conns = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if (-not $conns) { Write-Host "No process listening on port $Port." -ForegroundColor Yellow; return }
    $conns | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object {
        $p = Get-Process -Id $_ -ErrorAction SilentlyContinue
        Stop-Process -Id $_ -Force
        Write-Host "Stopped $($p.ProcessName) (PID $_) on port $Port." -ForegroundColor Green
    }
}

function psg {
    param([Parameter(Mandatory)][string]$Name)
    Get-Process | Where-Object { $_.ProcessName -like "*$Name*" } |
        Select-Object Id, ProcessName, @{N="RAM(MB)";E={[math]::Round($_.WorkingSet64/1MB,1)}} |
        Format-Table -AutoSize
}

function myip {
    $local = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.InterfaceAlias -notmatch 'Loopback|vEthernet' -and $_.IPAddress -notmatch '^169\.' } |
        Select-Object -First 1).IPAddress
    $pub = try { (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 3) } catch { "N/A" }
    Write-Host "Local IP  : " -NoNewline -ForegroundColor Cyan; Write-Host $local
    Write-Host "Public IP : " -NoNewline -ForegroundColor Cyan; Write-Host $pub
}

function sysinfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
    $totalRam = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeRam  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $usedRam  = [math]::Round($totalRam - $freeRam, 1)
    Write-Host "CPU : " -NoNewline -ForegroundColor Cyan; Write-Host $cpu
    Write-Host "RAM : " -NoNewline -ForegroundColor Cyan; Write-Host "$usedRam GB / $totalRam GB"
    Write-Host "OS  : " -NoNewline -ForegroundColor Cyan; Write-Host $os.Caption
}

# Git shortcuts and C/C++ runner
function lg { lazygit }
function gs { git status -sb }
function ga { param([Parameter(ValueFromRemainingArguments=$true)]$Args) git add @Args }
function gc { param([Parameter(ValueFromRemainingArguments=$true)]$Args) git commit @Args }
function gp { param([Parameter(ValueFromRemainingArguments=$true)]$Args) git push @Args }
function gl { git log --oneline --graph --decorate -n 15 }
function gd { param([Parameter(ValueFromRemainingArguments=$true)]$Args) git diff @Args }
function gb { git branch --sort=-committerdate }
function gnew { param([Parameter(Mandatory)][string]$Branch) git checkout -b $Branch }
function gundo { git reset --soft HEAD~1; Write-Host "Undid last commit (changes kept)." -ForegroundColor Green }

function cpprun {
    param([Parameter(Mandatory)][string]$File)
    $full = (Resolve-Path $File).Path
    & "$env:APPDATA\Zed\tools\cpp-run.cmd" $full "$PWD\build\single"
}

# Command reference
function devhelp {
    Write-Host "`nDev Terminal Commands" -ForegroundColor Cyan
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Navigation and Files:" -ForegroundColor Magenta
    Write-Host "  z <dir>              Jump to a recent directory (zoxide)"
    Write-Host "  Ctrl+R               Fuzzy history search (fzf)"
    Write-Host "  fe                   Fuzzy find file with preview and open in Zed"
    Write-Host "  ll / la / lt         List files with icons / tree view (eza)"
    Write-Host "  catn <f> / grep <t>  View file (bat) / search text (rg)"
    Write-Host "  open / sizeof / ff   Open Explorer / folder size / find file"
    Write-Host "  cpprun <file.cpp>    Compile and run a C/C++ file (UTF-8)"
    Write-Host "`n System and Network:" -ForegroundColor Magenta
    Write-Host "  ports / killport <p> List open ports / kill process by port"
    Write-Host "  psg <name> / sysinfo Find process / show CPU & RAM"
    Write-Host "  myip / reload        Show local & public IP / reload profile"
    Write-Host "`n Git:" -ForegroundColor Magenta
    Write-Host "  lg                   Open LazyGit"
    Write-Host "  gs / gl / gd / gb    Status / graph log / diff / branches"
    Write-Host "  ga / gc / gp / gundo Add / commit / push / soft undo commit"
    Write-Host "------------------------------------------------------------`n" -ForegroundColor DarkGray
}
