# =============================================================================
# Modern Oh-My-Zsh Style PowerShell 7 Profile (Cyber Glass + Nerd Font Edition)
# Integrated: zoxide, fzf, ripgrep (rg), bat, eza, lazygit, gh, PSReadLine
# =============================================================================

# 1. UTF-8 Tiếng Việt chuẩn cho Terminal
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
    chcp 65001 > $null
}

# 2. Theo dõi thời gian chạy lệnh trước đó
$script:__LastCmdStart = $null

if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine -MinimumVersion 2.1.0 -ErrorAction SilentlyContinue
    if (-not (Get-Module PSReadLine)) { Import-Module PSReadLine }

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -ShowToolTips

    # zsh-autosuggestions (Inline Ghost Text từ lịch sử, bấm → để nhận, F2 đổi chế độ)
    if (((Get-Module PSReadLine).Version -ge [version]'2.1.0') -and (-not [Console]::IsOutputRedirected)) {
        try {
            Set-PSReadLineOption -PredictionSource History
            Set-PSReadLineOption -PredictionViewStyle InlineView
            Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
        } catch {}
    }

    # Ctrl+R mở fzf tìm kiếm lịch sử gõ lệnh siêu nhanh (giống zsh + fzf)
    if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (-not [Console]::IsOutputRedirected)) {
        Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
            $histPath = (Get-PSReadLineOption).HistorySavePath
            if (Test-Path $histPath) {
                $lines = Get-Content $histPath -ErrorAction SilentlyContinue
                [array]::Reverse($lines)
                $selected = $lines | Select-Object -Unique | fzf --height 40% --layout=reverse --border --prompt="❯ "
                if ($selected) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
                }
            }
        }
    }

    $esc = [char]27
    $colors = @{
        Command   = "$esc[38;2;56;189;248m"   # #38bdf8 Cyan
        Parameter = "$esc[38;2;148;163;184m"  # #94a3b8 Slate
        String    = "$esc[38;2;52;211;153m"   # #34d399 Emerald
        Operator  = "$esc[38;2;125;211;252m"  # #7dd3fc Light Cyan
        Variable  = "$esc[38;2;244;114;182m"  # #f472b6 Pink
        Number    = "$esc[38;2;244;114;182m"  # #f472b6 Pink
        Keyword   = "$esc[38;2;192;132;252m"  # #c084fc Purple
        Type      = "$esc[38;2;45;212;191m"   # #2dd4bf Teal
        Comment   = "$esc[38;2;100;116;139m"  # #64748b Muted
        Error     = "$esc[38;2;248;113;113m"  # #f87171 Red
        Default   = "$esc[38;2;226;232;240m"  # #e2e8f0 Text
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

# 3. Kích hoạt zoxide (gõ `z <tên_folder>` để nhảy tới mọi nơi)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# 4. Prompt phong cách Oh-My-Zsh / Pure (kèm Nerd Font icons)
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
                $gitText = " ${cMuted}on ${cPurple} ${branch}${cYellow} ✗${reset}"
            } else {
                $gitText = " ${cMuted}on ${cPurple} ${branch}${cGreen} ✓${reset}"
            }
        }
    }

    $arrowColor = if ($lastOk) { $cGreen } else { $cRed }

    Write-Host ""
    Write-Host "${cCyan} ${displayPath}${reset}${gitText}${durationText}"
    return "${arrowColor}❯${reset} "
}

# 5. Điều hướng & Lệnh hiện đại (eza, bat, rg, fzf)
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function open { param([string]$Path = ".") Invoke-Item $Path }
function mkcd { param([string]$Path) New-Item -ItemType Directory -Force -Path $Path | Out-Null; Set-Location $Path }
function touch { param([string]$Path) if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date } else { New-Item -ItemType File -Path $Path | Out-Null } }
function which { param([string]$Name) (Get-Command $Name -ErrorAction SilentlyContinue).Source }
function reload { . $PROFILE; Write-Host "✓ Đã nạp lại PowerShell Profile!" -ForegroundColor Green }

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
            Write-Host ("{0,4} │ " -f $i) -NoNewline -ForegroundColor DarkGray
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

# 6. Quản lý Port, Process & Hệ thống cho Dev
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
    if (-not $conns) { Write-Host "Không có tiến trình nào đang mở port $Port." -ForegroundColor Yellow; return }
    $conns | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object {
        $p = Get-Process -Id $_ -ErrorAction SilentlyContinue
        Stop-Process -Id $_ -Force
        Write-Host "✓ Đã tắt $($p.ProcessName) (PID $_) đang giữ port $Port" -ForegroundColor Green
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

# 7. Git Shortcuts, LazyGit & C/C++ Quick Run
function lg { lazygit }
function gs { git status -sb }
function ga { param([Parameter(ValueFromRemainingArguments=$true)]$Args) git add @Args }
function gc { param([Parameter(ValueFromRemainingArguments=$true)]$Args) git commit @Args }
function gp { param([Parameter(ValueFromRemainingArguments=$true)]$Args) git push @Args }
function gl { git log --oneline --graph --decorate -n 15 }
function gd { param([Parameter(ValueFromRemainingArguments=$true)]$Args) git diff @Args }
function gb { git branch --sort=-committerdate }
function gnew { param([Parameter(Mandatory)][string]$Branch) git checkout -b $Branch }
function gundo { git reset --soft HEAD~1; Write-Host "✓ Đã hoàn tác commit gần nhất (code vẫn được giữ)." -ForegroundColor Green }

function cpprun {
    param([Parameter(Mandatory)][string]$File)
    $full = (Resolve-Path $File).Path
    & "$env:APPDATA\Zed\tools\cpp-run.cmd" $full "$PWD\build\single"
}

# 8. Bảng tra cứu nhanh (gõ: devhelp)
function devhelp {
    Write-Host "`n⚡ ZSH-STYLE PRO DEV TERMINAL (PS7 + NERD FONT)" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host " Điều hướng & Tìm kiếm (zoxide + fzf + eza + bat + rg):" -ForegroundColor Magenta
    Write-Host "  z <folder>           Nhảy tới bất kỳ thư mục nào đã từng vào"
    Write-Host "  Ctrl+R               Tìm lịch sử lệnh mờ (fzf)"
    Write-Host "  fe                   Tìm file mờ (kèm preview) & mở thẳng trong Zed"
    Write-Host "  ll / la / lt         Liệt kê file kèm Icon + Git / Cây thư mục"
    Write-Host "  catn <f> / grep <t>  Đọc code có màu (bat) / Tìm chuỗi siêu tốc (rg)"
    Write-Host "  open / sizeof / ff   Mở Explorer / Tính dung lượng / Tìm file"
    Write-Host "  cpprun <file.cpp>    Biên dịch & chạy nhanh C/C++ (UTF-8)"
    Write-Host "`n Hệ thống & Mạng:" -ForegroundColor Magenta
    Write-Host "  ports / killport <p> Xem port đang mở / Tắt tiến trình chiếm port"
    Write-Host "  psg <name> / sysinfo Tìm process + RAM / Thông số CPU & RAM"
    Write-Host "  myip / reload        Xem IP Local+Public / Nạp lại Profile"
    Write-Host "`n Git & TUI:" -ForegroundColor Magenta
    Write-Host "  lg                   Mở LazyGit (giao diện Git trực quan)"
    Write-Host "  gs / gl / gd / gb    Status / Log cây / Diff / Danh sách branch"
    Write-Host "  ga / gc / gp / gundo Add / Commit / Push / Hoàn tác commit"
    Write-Host "────────────────────────────────────────────────────────────`n" -ForegroundColor DarkGray
}
