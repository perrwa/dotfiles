#!/usr/bin/env bash
# The ONLY script in this repo meant to be piped:
#   curl -fsSL https://raw.githubusercontent.com/perrwa/dotfiles/main/install.sh | bash
#
# It does the minimum needed to get a real checkout on disk with a real TTY,
# then hands off to bootstrap.sh directly (never piped) so sudo prompts and
# the gum picker have a terminal to read from.
set -e

REPO_URL="https://github.com/perrwa/dotfiles.git"
CLONE_DIR="$HOME/git/dotfiles"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: this repo only supports macOS." >&2
  exit 1
fi
if [[ "$(uname -m)" != "arm64" ]]; then
  echo "Error: this repo only supports Apple Silicon (arm64)." >&2
  exit 1
fi

if ! xcode-select -p &>/dev/null; then
  echo "-> Installing Xcode command line tools (needed for git)..."
  xcode-select --install
  echo "Waiting for install to finish (dismiss the dialog to cancel)..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi

if [[ -d "$CLONE_DIR/.git" ]]; then
  echo "-> $CLONE_DIR already exists, pulling latest"
  git -C "$CLONE_DIR" pull --ff-only
else
  echo "-> Cloning $REPO_URL to $CLONE_DIR"
  mkdir -p "$(dirname "$CLONE_DIR")"
  git clone "$REPO_URL" "$CLONE_DIR"
fi

chmod +x "$CLONE_DIR/bootstrap.sh"

# Re-point stdin at the real terminal before handing off. When this script
# is run as `curl | bash`, fd 0 is still the pipe at this point — exec alone
# does not fix that, and bootstrap.sh's sudo/gum prompts would read EOF from
# it exactly like the old bootstrap.sh did.
if [[ -r /dev/tty ]]; then
  exec "$CLONE_DIR/bootstrap.sh" "$@" < /dev/tty
else
  echo "Error: no controlling terminal available (/dev/tty unreadable)." >&2
  echo "cd $CLONE_DIR && ./bootstrap.sh" >&2
  exit 1
fi
