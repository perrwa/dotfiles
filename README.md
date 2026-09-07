# dotfiles

Modular, idempotent macOS setup: Homebrew packages, dotfiles (zsh/git/ssh), and system defaults. Apple Silicon only.

## Quick start

Fresh machine, no git yet:

```bash
curl -fsSL https://raw.githubusercontent.com/perrwa/dotfiles/main/install.sh | bash
```

`install.sh` is the only script meant to be piped. It installs the Xcode command line tools (for `git`), clones this repo to `~/git/dotfiles`, then hands off to `bootstrap.sh` with a real terminal attached — the actual setup never runs piped, since sudo prompts and the package picker need a TTY to read from.

Already have the repo cloned:

```bash
cd ~/git/dotfiles
./bootstrap.sh
```

or `make` (prints available targets), `make all`, `make dotfiles`, etc.

## Why not just `curl | bash` the whole thing?

That's what this repo used to do, and it's why Homebrew's installer failed with a permissions error on a fresh machine. Piping into `bash` makes `bash` inherit the pipe as stdin, so when the installer prompts for your sudo password, it reads EOF instead and dies. `install.sh` exists specifically to get a real checkout on disk with a real TTY before anything sudo- or gum-driven runs.

## Requirements

- macOS on Apple Silicon (arm64). Intel is not supported.
- Admin access.

## What it does

| Module | Does |
|---|---|
| `preflight` | TTY/root/arch guards, sudo priming + keepalive, Xcode CLT, Homebrew, Rosetta |
| `packages` | Installs `Brewfile` (always) and offers `Brewfile.optional` via an interactive picker |
| `dotfiles` | Symlinks `home/` into `$HOME` and `config/` into `~/.config`, links `ssh/config`, seeds untracked `*.local` files |
| `macos` | Applies `defaults write` settings from `modules/defaults/*.sh`, only restarting Dock/Finder/SystemUIServer if something actually changed |

Everything is safe to re-run: linking is a no-op when already correct, package installs go through `brew bundle` (idempotent by design), and macOS defaults are compared before writing.

## CLI

```
./bootstrap.sh [options]

  --only a,b         Run only these modules (preflight,packages,dotfiles,macos)
  --skip a,b         Run everything except these
  --list             List modules and exit
  --upgrade          Also run brew update && brew upgrade && brew cleanup
  --non-interactive  No prompts; Brewfile only, no picker
  --dry-run          Linking only: print every link/backup without performing it
  --keep-going       Continue past a failing module (default is fail-fast)
  --force-dock-reset Re-arm the first-run-only Dock wipe
  --unlink           Undo the dotfiles module's symlinks, restoring backups
  --help
```

Bring a machine up to date later:

```bash
./bootstrap.sh --upgrade
```

This runs plain `brew upgrade`: no `--greedy` on casks, since that force-reinstalls self-updating apps like Docker/Slack/Zoom and can prompt for admin. Run `brew upgrade --cask --greedy` by hand if you want that.

## Adding packages

- Always want it, every machine → add a `brew "..."` / `cask "..."` line to `Brewfile`.
- Optional, offered in the picker → add it to `Brewfile.optional`. If it needs a tap, add the `tap "..."` line there too; taps are always carried into the install even if the picked list is empty.

To catch drift (something installed by hand that isn't tracked):

```bash
brew bundle dump --describe --force --file=Brewfile.new
diff Brewfile Brewfile.new
```

Move anything worth keeping into `Brewfile` or `Brewfile.optional`, then delete `Brewfile.new`.

## Dotfiles managed here

- zsh: `~/.zshenv`, `~/.zprofile`, `~/.zshrc` (sources `~/.zsh/*.zsh`, then `~/.zshrc.local` if present).
- git: `~/.config/git/config` and `~/.config/git/ignore`. Identity lives in `~/.config/git/config.local`, which is not tracked and gets seeded from `config/git/config.local.example` on first run. Note: `~/.gitconfig`, if it exists, makes git ignore the XDG config entirely; the dotfiles module removes it (backing it up to `~/.gitconfig.bak` first).
- ssh: `~/.ssh/config` tracks only the personal `github.com` host, since this repo is public. Work-specific hosts (internal aliases, non-public hostnames) belong in `~/.ssh/config.local`, which is untracked and seeded from a placeholder template. Fill in real values there, never in the repo.

## macOS settings

See `modules/defaults/*.sh`, one file per domain (Dock, Finder, screenshots, global, storage, input). The Dock's `persistent-apps` wipe is first-run-only (guarded by a sentinel at `~/.local/state/dotfiles/dock-reset`), so re-running the script never clears a Dock you've since arranged by hand.

## Post-install

1. Restart your terminal.
2. Sign in to installed apps (1Password, Slack, etc).
3. Fill in `~/.ssh/config.local` with any work-specific host aliases.

## License

[MIT](LICENSE)
