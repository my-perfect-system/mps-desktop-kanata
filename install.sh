#!/usr/bin/env bash
# Install kanata + deploy the config to the current user's ~/.config/kanata.
# Idempotent. OS-specific packages live in install-debian.sh / install-fedora.sh
# and are installed best-effort before the config deploy.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SUDO=""
[[ ${EUID} -eq 0 ]] || SUDO="sudo"

#--- Distro detection -----------------------------------------------------------
detect_distro() {
    local id
    id="$(grep -sE '^ID=' /etc/os-release | head -1 | cut -d= -f2 | tr -d '\"')"
    case "${id}" in
        debian|ubuntu) echo "debian" ;;
        fedora|rhel)   echo "fedora" ;;
        *)
            if command -v apt-get >/dev/null 2>&1; then echo "debian"
            elif command -v dnf >/dev/null 2>&1; then echo "fedora"
            else echo "none"; fi ;;
    esac
}

#--- System: distro packages (best-effort) --------------------------------------
case "$(detect_distro)" in
    debian) "${SRC}/install-debian.sh" || echo "==> WARN: install-debian.sh failed; continuing" ;;
    fedora)  "${SRC}/install-fedora.sh" || echo "==> WARN: install-fedora.sh failed; continuing" ;;
    *)       echo "==> Unsupported distro — skipping system packages" ;;
esac

#--- System: uinput group + udev rule (mirrors the odem.desktop.kanata role) ----
${SUDO} getent group uinput >/dev/null 2>&1 || ${SUDO} groupadd uinput
if [[ $(id -u) -ne 0 ]]; then
    id -nG | grep -qw uinput || { ${SUDO} gpasswd -a "$USER" uinput || echo "==> WARN: could not add $USER to uinput"; }
    id -nG | grep -qw input || { ${SUDO} gpasswd -a "$USER" input || echo "==> WARN: could not add $USER to input"; }
fi
${SUDO} install -d -m 0755 /etc/udev/rules.d
printf 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"\n' \
    | ${SUDO} tee /etc/udev/rules.d/99-kanata-uinput.rules >/dev/null
${SUDO} install -d -m 0755 /etc/modules-load.d
printf 'uinput\n' | ${SUDO} tee /etc/modules-load.d/uinput.conf >/dev/null
${SUDO} udevadm control --reload-rules 2>/dev/null || true
${SUDO} modprobe uinput 2>/dev/null || echo "==> WARN: uinput not loaded (reboot to apply)"

#--- Per-user: kanata app install (rustup + cargo) — toggle mirrors the role ----
ENABLE_INSTALL="${MPS_KANATA_ENABLE_INSTALL:-1}"
if [[ "${ENABLE_INSTALL}" = 1 ]] && [[ ! -x "${HOME}/.cargo/bin/kanata" ]]; then
    if [[ ! -x "${HOME}/.cargo/bin/cargo" ]]; then
        curl -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    fi
    "${HOME}/.cargo/bin/cargo" install kanata --features cmd
fi

#--- Per-user: config deploy (overwrite; mirrors the role) ----------------------
install -d -m 0700 "${HOME}/.config/kanata"
cp -a "${SRC}/config/kanata/." "${HOME}/.config/kanata/"

echo "mps-desktop-kanata deployed to ${HOME}/.config/kanata."