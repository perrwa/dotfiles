#!/usr/bin/env bash
# Shared logging, guards, sudo handling, and the link() primitive.
# Sourced by bootstrap.sh; assumes DOTFILES_DIR is already set.

# ---------------------------
# Logging
# ---------------------------
log()   { printf '%s\n' "$*"; }
info()  { printf '  -> %s\n' "$*"; }
ok()    { printf '  \xE2\x9C\x93 %s\n' "$*"; }
warn()  { printf '  ! %s\n' "$*" >&2; }
die()   { printf 'Error: %s\n' "$*" >&2; exit 1; }
header() { printf '\n=== %s ===\n' "$*"; }

# ---------------------------
# Preflight guards
# ---------------------------
ensure_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This repo only supports macOS."
}

ensure_apple_silicon() {
  [[ "$(uname -m)" == "arm64" ]] || die "This repo only supports Apple Silicon (arm64). Intel Macs are not supported."
}

ensure_not_root() {
  [[ "$EUID" -ne 0 ]] || die "Do not run this as root or via sudo. Homebrew refuses to install or run as root — run it as yourself; you'll be prompted for your password when needed."
}

ensure_tty() {
  if [[ ! -t 0 ]]; then
    die "stdin is not a terminal (are you piping this in?). Re-run from an interactive shell: git clone the repo and run ./bootstrap.sh directly."
  fi
}

ensure_admin() {
  if ! id -Gn | grep -qw admin; then
    warn "Your user is not in the 'admin' group — Homebrew and system defaults may fail."
  fi
}

# ---------------------------
# sudo priming + keepalive
# ---------------------------
SUDO_KEEPALIVE_PID=""

prime_sudo() {
  if [[ "${NON_INTERACTIVE:-false}" == true ]]; then
    if ! sudo -n true 2>/dev/null; then
      die "Non-interactive mode requires cached sudo credentials. Run 'sudo -v' first, or run without --non-interactive."
    fi
  else
    info "Homebrew, Rosetta, and Xcode tools need admin privileges."
    sudo -v || die "sudo authentication failed."
  fi

  # Keep the sudo timestamp alive for the life of this script. Guard on the
  # parent PID (not a bare `while true`) so the loop dies with the script
  # instead of being orphaned if it's killed uncleanly.
  ( while kill -0 "$$" 2>/dev/null; do
      sudo -n true 2>/dev/null
      sleep 60
    done ) &
  SUDO_KEEPALIVE_PID=$!
  trap stop_sudo_keepalive EXIT
}

stop_sudo_keepalive() {
  if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  fi
}

# ---------------------------
# link(): symlink a payload into place, backing up real files/dirs.
#
#   link <src-in-repo> <dst-in-home>
#
#   - already correct symlink        -> no-op, silent
#   - symlink pointing elsewhere     -> repoint, log it
#   - real file or dir at dst        -> move to <dst>.bak, log loudly, then link
#   - dangling symlink at dst        -> treated as existing and backed up,
#                                        same as a real file
# ---------------------------
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      return 0
    fi
    warn "$dst is a symlink to $(readlink "$dst"), repointing to $src"
    rm -f "$dst"
  elif [[ -e "$dst" ]]; then
    local bak="${dst}.bak"
    warn "$dst exists, backing up to $bak"
    rm -rf "$bak"
    mv "$dst" "$bak"
  fi

  ln -sfn "$src" "$dst"
  info "linked $dst -> $src"
}

# unlink_path(): restore a .bak file if present, otherwise just remove the link.
unlink_path() {
  local dst="$1"
  local bak="${dst}.bak"
  if [[ -L "$dst" ]]; then
    rm -f "$dst"
    if [[ -e "$bak" ]]; then
      mv "$bak" "$dst"
      ok "restored $dst from backup"
    else
      info "removed link $dst (no backup to restore)"
    fi
  fi
}

# ---------------------------
# Module runner
# ---------------------------
list_modules() {
  for m in "$DOTFILES_DIR"/modules/*.sh; do
    local name desc
    name=$(basename "$m" .sh)
    desc=$(grep -m1 '^# desc:' "$m" | sed 's/^# desc: //')
    printf '  %-12s %s\n' "${name#*-}" "$desc"
  done
}

run_module() {
  local file="$1"
  local name
  name=$(basename "$file" .sh)
  name="${name#*-}"

  if [[ -n "${ONLY:-}" ]] && ! printf '%s\n' "${ONLY//,/$'\n'}" | grep -qx "$name"; then
    return 0
  fi
  if [[ -n "${SKIP:-}" ]] && printf '%s\n' "${SKIP//,/$'\n'}" | grep -qx "$name"; then
    header "Skipping $name (--skip)"
    return 0
  fi

  header "$name"
  # shellcheck disable=SC1090
  source "$file"
  if declare -f module_run >/dev/null; then
    if module_run; then
      :
    else
      if [[ "${KEEP_GOING:-false}" == true ]]; then
        warn "module '$name' failed, continuing (--keep-going)"
      else
        die "module '$name' failed. Fix the error above, or re-run with --keep-going to skip past it."
      fi
    fi
    unset -f module_run
  else
    warn "module '$name' defines no module_run(), skipping"
  fi
}
