# Zed Config — Cyber Glass Blur & Pro Dev Setup

A modern, uniform **Glassmorphism (Gaussian Blur)** configuration for **Zed Editor** on Windows 11, paired with **Material Icon Theme**, **JetBrainsMono Nerd Font**, smooth cursor & typing animations, full LSP/DAP support (C/C++, C#, Rust, SQL), and an **Oh-My-Zsh-inspired PowerShell 7** terminal.

![Zed Cyber Glass Blur Preview](assets/preview.jpg)

---

## Highlights

- **Uniform Gaussian Blur (`Cyber Glass Dark (Blur)`)**
  - Consistent single-layer frosted glass (`background.appearance: "blurred"`) across the title bar, project panel, editor, tabs, and status bar.
  - High-contrast opaque/semi-opaque hover popups and diagnostic tooltips so text never bleeds through.
- **Smooth Animations & Typography**
  - `JetBrainsMono NF` with programming ligatures (`calt`, `ss01`) and subpixel rendering across both editor and terminal.
  - Smooth cursor glide (`cursor_animation`), blinking bar cursor, rounded selections, and instant LSP/inlay-hint responsiveness.
- **Developer Components**
  - **Material Icon Theme** (icons only, preserving the custom glass theme).
  - **Inline Diagnostics** (Error Lens style), **Inlay Hints**, **Inline Git Blame**, **Code Lens**, **Rainbow Brackets**, **Indent Guides**, **Minimap**, **Sticky Scroll**, and **Git Diff Stats**.
  - Clean **Title Bar** (branch status & user avatar) and **Status Bar** (active file, line/col, `UTF-8`, `LF`, language selector, pending keystrokes).
- **Oh-My-Zsh Style PowerShell 7 Terminal**
  - Clean 2-line prompt with Git branch/dirty status and command execution timer.
  - `PSReadLine 2.4.5` inline history autosuggestions (`→` to accept, `F2` to switch view).
  - Pre-wired CLI power tools: `zoxide`, `fzf` (`Ctrl+R`, `fe`), `eza` (`ll`, `la`, `lt`), `bat` (`catn`), `ripgrep` (`grep`), `lazygit` (`lg`), and `gh`.

---

## Repository Structure

```text
zed-config/
├── assets/
│   └── preview.jpg                        # UI preview screenshot
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1   # Oh-My-Zsh style PowerShell 7 profile
├── themes/
│   └── cyber-glass-blur.json              # Custom Cyber Glass Dark (Blur) theme
├── tools/
│   ├── cpp-build.cmd                      # Smart CMake + single-file C/C++ fallback
│   ├── cpp-run.cmd                        # MSVC single-file runner with UTF-8 output
│   ├── sql-run.cmd                        # SQL Server runner
│   └── sql-shell.cmd                      # Interactive sqlcmd shell
├── keymap.json                            # Custom workspace keybindings
├── settings.json                          # Main Zed settings & auto_install_extensions
└── tasks.json                             # Global C/C++ and SQL tasks
```

---

## Auto-Installed Extensions

All extensions below are declared under `auto_install_extensions` in `settings.json` and install automatically when Zed launches:

- `material-icon-theme`
- `astro`, `csharp`, `csv`, `git-firefly`, `html`, `log`, `powershell`, `sql`, `sqlserver`, `svelte`, `swift`, `toml`, `windows-batch`

---

## Quick Setup (Windows 11)

1. **Install Nerd Font & CLI tools:**
   ```powershell
   winget install Microsoft.PowerShell DEVCOM.JetBrainsMonoNerdFont ajeetdsouza.zoxide junegunn.fzf BurntSushi.ripgrep.MSVC sharkdp.bat eza-community.eza JesseDuffield.lazygit GitHub.cli
   ```
2. **Copy Zed configuration files** into `%APPDATA%\Zed\`:
   - `settings.json`, `keymap.json`, `tasks.json`, `themes/`, and `tools/`
3. **Copy the PowerShell 7 profile** into:
   - `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
4. **Launch Zed** — themes, animations, Material icons, and all 14 extensions will load automatically.
