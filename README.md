# dotfiles (chezmoi)

This repository is the **chezmoi source state**: paths and names follow [chezmoi’s rules](https://www.chezmoi.io/user-guide/frequently-asked-questions/chezmoi-format/), so `chezmoi apply` writes the correct files under your home directory on Windows, Linux, and macOS.

## What is managed

| Destination | Purpose |
|-------------|---------|
| `~/.config/nvim` | LazyVim / Neovim |
| `~/.config/starship.toml` | Starship prompt |
| `~/.config/yazi` | Yazi file manager |
| `~/.config/neofetch` | Neofetch (skipped on Windows by default) |
| `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | PowerShell on **Windows** |
| `~/.config/powershell/Microsoft.PowerShell_profile.ps1` | PowerShell (`pwsh`) on **Linux/macOS** |

Neovim, Starship, and Yazi all use **`~/.config`** on every OS. On Windows, the profile sets `XDG_CONFIG_HOME` to `%USERPROFILE%\.config` so Neovim picks up the same layout as on Linux/macOS.

Shared shell logic lives in [`.chezmoitemplates/powershell_profile`](.chezmoitemplates/powershell_profile); both profile paths include it with `{{ template "powershell_profile" . }}`.

## New machine

Install [chezmoi](https://www.chezmoi.io/install/), then:

```bash
chezmoi init --apply https://github.com/lmartins18/dotfiles.git
```

Use SSH if you prefer: `chezmoi init --apply git@github.com:lmartins18/dotfiles.git`

Review before overwriting anything important:

```bash
chezmoi diff
chezmoi apply
```

## This repo as the source on an existing install

If you already use chezmoi and want this GitHub repo as `sourceDir`:

```bash
chezmoi cd
git remote add origin https://github.com/lmartins18/dotfiles.git   # if needed
git pull
chezmoi apply
```

Or clone and point `sourceDir` at the clone (see [docs](https://www.chezmoi.io/user-guide/setup/#use-a-non-git-repo)).

## Windows notes

- If **Neovim is started outside PowerShell** (e.g. from a shortcut), set a user environment variable `XDG_CONFIG_HOME` to `%USERPROFILE%\.config` so it always sees `~/.config/nvim`.
- After you confirm Neovim works from `~/.config/nvim`, you can remove an old copy under `%LOCALAPPDATA%\nvim` to avoid confusion.
- If `chezmoi cat` or `apply` complains about `Documents`, OneDrive may have moved your Documents folder; see [chezmoi “source directory outside working tree”](https://www.chezmoi.io/user-guide/frequently-asked-questions/performance/).

## Adding configs (e.g. more Yazi files)

From any machine:

```bash
chezmoi add --private ~/.config/yazi/keymap.toml
# or create files under private_dot_config/yazi/ in this repo
```

Use `private_dot_config/...` in the repo for anything under `~/.config`.

## Repo-only files

[`.chezmoiignore.tmpl`](.chezmoiignore.tmpl) keeps `README.md` out of your home directory. Special paths [`.chezmoitemplates/`](.chezmoitemplates/), [`.chezmoi.toml`](.chezmoi.toml), and [`.chezmoiignore.tmpl`](.chezmoiignore.tmpl) are for chezmoi only, not copied to `$HOME`.
