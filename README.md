# Zed Config — Cyber Glass Blur & Pro Dev Setup (Windows 11)

Cấu hình **Zed Editor** phong cách **Glassmorphism (Gaussian Blur đồng nhất)** kết hợp **Material Icon Theme**, **JetBrainsMono Nerd Font**, **Smooth Cursor Animation**, cùng **Terminal PowerShell 7 (Oh-My-Zsh style)** tối ưu cho C/C++, C#, Rust và SQL.

## Thành phần trong repo

- `settings.json` — Cấu hình giao diện kính mờ (`background.appearance: "blurred"`), font `JetBrainsMono NF` + ligatures, `cursor_animation`, `inlay_hints`, `inline_blame`, `sticky_scroll`, `minimap`, `status_bar`, `title_bar`, `diagnostics.inline`, và danh sách `auto_install_extensions`.
- `themes/cyber-glass-blur.json` — Theme **Cyber Glass Dark (Blur)** với bảng màu Slate / Electric Cyan đồng nhất 1 lớp kính mờ toàn cửa sổ.
- `keymap.json` & `tasks.json` & `tools/` — Phím tắt & script build/run C/C++ (MSVC + UTF-8 + CMake fallback) và SQL Server.
- `powershell/Microsoft.PowerShell_profile.ps1` — Profile Terminal phong cách Oh-My-Zsh (Prompt 2 dòng hiện Git status, `PSReadLine` inline autosuggestions, `zoxide`, `fzf`, `eza`, `bat`, `ripgrep`, `lazygit`).

## Extensions đã cài & tự động đồng bộ (`auto_install_extensions`)

`material-icon-theme`, `astro`, `csharp`, `csv`, `git-firefly`, `html`, `log`, `powershell`, `sql`, `sqlserver`, `svelte`, `swift`, `toml`, `windows-batch`.

## Cài đặt nhanh trên máy mới (Windows)

1. Copy `settings.json`, `keymap.json`, `tasks.json`, `themes/` và `tools/` vào `%APPDATA%\Zed\`.
2. Copy `powershell/Microsoft.PowerShell_profile.ps1` vào `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`.
3. Cài font & CLI tools:
   ```powershell
   winget install Microsoft.PowerShell DEVCOM.JetBrainsMonoNerdFont ajeetdsouza.zoxide junegunn.fzf BurntSushi.ripgrep.MSVC sharkdp.bat eza-community.eza JesseDuffield.lazygit GitHub.cli
   ```
4. Mở Zed — toàn bộ theme, icon, animation và 14 extensions sẽ tự động được áp dụng.
