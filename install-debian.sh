#!/usr/bin/env bash
# Debian/Ubuntu system packages for mps-desktop-kanata. Best-effort, sourced
# from install.sh; can also be run directly.
set -euo pipefail

SUDO=""
[[ ${EUID} -eq 0 ]] || SUDO="sudo"

# Toggles (defaults mirror the odem.desktop.kanata role)
ENABLE_PACKAGES="${MPS_KANATA_ENABLE_PACKAGES:-1}"

if [[ "${ENABLE_PACKAGES}" = 1 ]]; then
    ${SUDO} apt-get install -y udev curl
fi

echo "mps-desktop-kanata Debian packages installed"