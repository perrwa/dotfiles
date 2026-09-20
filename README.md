# dotfiles

Modular, idempotent macOS setup: Homebrew packages, dotfiles (zsh/git/ssh), and system defaults. Apple Silicon only.

## Quick start

Fresh machine, no git yet:

```bash
curl -fsSL https://raw.githubusercontent.com/perrwa/dotfiles/main/install.sh | bash
```

Already cloned:

```bash
cd ~/git/dotfiles
./bootstrap.sh
```

or `make` (lists targets), `make all`, `make dotfiles`, etc.

## Requirements

Apple Silicon macOS, admin access.

## Modules

| Module | Does |
|---|---|
| `preflight` | TTY/root/arch guards, sudo, Xcode CLT, Homebrew, Rosetta |
| `packages` | Installs `Brewfile` (always), offers `Brewfile.optional` via picker |
| `zsh` | Symlinks `home/.zshenv`/`.zprofile`/`.zshrc`/`.zsh/*.zsh`, seeds `*.local` files |
| `git` | Symlinks `config/git/*` into `~/.config/git`, seeds `config.local` |
| `ssh` | Symlinks `ssh/config` into `~/.ssh`, seeds `config.local` |
| `macos` | Applies `defaults write` from `modules/defaults/*.sh`, restarts Dock/Finder/SystemUIServer only if changed |

`make dotfiles` runs `zsh`+`git`+`ssh` together; each also runs (or `--unlink`s) on its own.

Safe to re-run: linking no-ops when correct, `brew bundle` is idempotent, macOS defaults are diffed before writing.

## CLI

```
./bootstrap.sh [options]

  --only a,b         Run only these modules (preflight,packages,zsh,git,ssh,macos)
  --skip a,b         Run everything except these
  --list             List modules and exit
  --upgrade          Also run brew update && brew upgrade && brew cleanup
  --non-interactive  No prompts; Brewfile only, no picker
  --dry-run          Linking only: print every link/backup without performing it
  --keep-going       Continue past a failing module (default is fail-fast)
  --force-dock-reset Re-arm the first-run-only Dock wipe
  --unlink           Undo modules' symlinks, restoring backups (honors --only/--skip)
  --help
```

Bring a machine up to date later:

```bash
./bootstrap.sh --upgrade
```

Plain `brew upgrade`, no `--greedy` on casks (that force-reinstalls self-updating apps and can prompt for admin). Run `brew upgrade --cask --greedy` by hand if wanted.

## Adding packages

- Always-want, every machine → `brew "..."` / `cask "..."` in `Brewfile`.
- Optional/picker → `Brewfile.optional` (add `tap "..."` there too if needed).

Catch drift (installed by hand, untracked):

```bash
brew bundle dump --describe --force --file=Brewfile.new
diff Brewfile Brewfile.new
```

Move anything worth keeping into `Brewfile`/`Brewfile.optional`, delete `Brewfile.new`.

## Dotfiles managed here

- zsh links `~/.zshenv`, `~/.zprofile`, `~/.zshrc`. `.zshrc` sources `~/.zsh/*.zsh` in order (`10-fpath`, `20-completion`, `30-history`, `40-aliases`, `50-tools`), then `~/.zshrc.local`. Work-specific stuff (corporate CA, PATs) goes in the untracked `*.local` files, seeded from `*.local.example` on first run.
- git links `~/.config/git/config` + `ignore`. Identity/signing (`user.name`/`email`, `gpgsign`) is tracked; `signingkey`, `allowedSignersFile`, per-dir `includeIf` go in untracked `config.local`. An existing `~/.gitconfig` makes git ignore XDG config, so the module removes it (backs up to `~/.gitconfig.bak` first).
- ssh links `~/.ssh/config`, which tracks only the personal `github.com` host (repo is public). Work hosts go in untracked `config.local`.

## macOS settings

`modules/defaults/*.sh`, one file per domain. Dock's `persistent-apps` wipe is first-run-only (sentinel at `~/.local/state/dotfiles/dock-reset`), so re-running never clears a Dock you've since rearranged.

## Post-install

1. Restart your terminal.
2. Sign in to installed apps (1Password, Slack, etc).
3. Fill in `~/.ssh/config.local` with any work-specific host aliases.

## License

[MIT](LICENSE)
