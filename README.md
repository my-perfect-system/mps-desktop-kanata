# mps-desktop-kanata

kanata keyboard remapper configuration of the my-perfect-system (mps) desktop stack.

## Install

| Method | Description |
|---|---|
| Default | `bootstrap.sh` clones to the system-wide mps repo dir and runs `install.sh` |
| Ansible | can be used by installing via the `odem.desktop.kanata` role of [odem-desktop](https://github.com/my-perfect-system-ansible/odem-desktop) |
| Standalone | clone the repo, then run `./install.sh` inside it |

### Install (Default)

```bash
curl -fsSL https://raw.githubusercontent.com/my-perfect-system/mps-desktop-kanata/main/bootstrap.sh | bash
```

All methods install OS packages + the uinput/udev setup best-effort, install
kanata via rustup/cargo for the current user (`MPS_KANATA_ENABLE_INSTALL=0` to
skip), and deploy `config/kanata` to `~/.config/kanata`; one clone per host
(`${MPS_REPO_DIR:-/srv/repo/github/my-perfect-system/mps}`), shared by all users.

## Usage

```bash
systemctl --user status kanata      # per-user service (deployed by the odem role)
kanata -c ~/.config/kanata/kanata.kbd   # manual foreground run
```

The per-user systemd service (`kanata.service`) is deployed by the
`odem.desktop.kanata` role; with standalone installs, start kanata manually or
create your own user unit. Membership in the `input` + `uinput` groups and the
udev rule are set up by `install.sh`.

## Layout

| Path | Deploy target |
|---|---|
| `config/kanata/` | `~/.config/kanata/` |