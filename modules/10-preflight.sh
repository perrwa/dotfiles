# shellcheck shell=bash
# desc: TTY/root/arch guards, sudo priming, Xcode CLT, Homebrew, Rosetta
module_run() {
  ensure_macos
  ensure_apple_silicon
  ensure_not_root
  # --non-interactive is the headless/automation path (relies on cached
  # sudo, skips the gum picker) and shouldn't require a controlling
  # terminal. The interactive path does, since sudo/gum prompts need one.
  [[ "${NON_INTERACTIVE:-false}" == true ]] || ensure_tty
  ensure_admin
  prime_sudo

  header "Xcode command line tools"
  if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode command line tools..."
    xcode-select --install
    info "Waiting for install to finish (dismiss the dialog to cancel)..."
    local waited=0
    until xcode-select -p &>/dev/null; do
      sleep 5
      waited=$((waited + 5))
      if [[ $waited -ge 600 ]]; then
        die "Timed out waiting for Xcode command line tools. Run 'xcode-select --install' manually and re-run this script."
      fi
    done
  else
    ok "Xcode tools already installed"
  fi

  header "Homebrew"
  ensure_brew

  header "Rosetta 2"
  if /usr/bin/pgrep oahd &>/dev/null; then
    ok "Rosetta already installed"
  else
    info "Installing Rosetta..."
    softwareupdate --install-rosetta --agree-to-license || true
  fi
}
