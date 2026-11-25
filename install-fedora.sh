#!/usr/bin/env bash
# Fedora/RHEL system packages for mps-desktop-kanata. Best-effort, sourced
# from install.sh; can also be run directly.
set -euo pipefail

SUDO=""
[[ ${EUID} -eq 0 ]] || SUDO="sudo"

# Toggles (defaults mirror the odem.desktop.kanata role)
ENABLE_PACKAGES="${MPS_KANATA_ENABLE_PACKAGES:-1}"

if [[ "${ENABLE_PACKAGES}" = 1 ]]; then
    ${SUDO} dnf install -y systemd curl
fi

echo "mps-desktop-kanata Fedora packages installed"