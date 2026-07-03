#!/usr/bin/env bash
# Render and run the Linux package install script inside this CachyOS container,
# as a normal user, the way chezmoi would (paru/makepkg refuse to run as root).
#
# The container boots systemd (see Containerfile), so Flatpak system installs
# work for real. Usage, from the repo root:
#   podman build -t my-cachy .containers/CachyOS
#   podman run -d --name cachy-test --privileged --systemd=always -v $"($env.PWD):/repo:ro" my-cachy
#   podman exec cachy-test bash /repo/.containers/CachyOS/test-packages.sh
#
# Everything below is container-only plumbing. It never touches the dotfiles and
# is not needed on a real machine.
set -uo pipefail

# Pacman hooks can't sandbox the network in an unprivileged container.
sed -i '/^\[options\]/a DisableSandboxNetwork' /etc/pacman.conf
# Force HTTP/1.1 for makepkg's curl. HTTP/2 gives "SSL_read: unexpected eof" on
# large AUR source downloads over some container networks.
sed -i 's#/usr/bin/curl -q#/usr/bin/curl --http1.1 -q#g' /etc/makepkg.conf

pacman -Syu --noconfirm --needed base-devel sudo git >/dev/null

# paru/makepkg refuse root, so run as a normal user with passwordless sudo.
useradd -m t
echo 't ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/t && chmod 440 /etc/sudoers.d/t
su - t -c 'git config --global http.version HTTP/1.1'   # same HTTP/1.1 fix for git AUR clones

# paru from the repo if present, else bootstrap paru-bin from the AUR.
pacman -S --noconfirm paru >/dev/null 2>&1 || \
  su - t -c 'git clone --depth=1 https://aur.archlinux.org/paru-bin.git ~/p >/dev/null 2>&1 && cd ~/p && makepkg -si --noconfirm >/dev/null 2>&1'

# Minimal chezmoi data so the template renders without 1Password or prompts.
# Flip computerPurpose to "work" to test work-tagged packages.
mkdir -p /home/t/.config/chezmoi
cat >/home/t/.config/chezmoi/chezmoi.toml <<EOF
[data]
osid = "linux-cachyos"
computerPurpose = "personal"
email = "test@test"
username = "test"
steamUsername = "test"
EOF
chown -R t:t /home/t

# Flatpak system installs run for real (systemd + D-Bus + polkit rule from the
# Containerfile). Add the flathub remote the entries pull from, and force HTTP/1.1
# on it (same "SSL_read: unexpected eof" container-network issue as git/makepkg).
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true
ostree --repo=/var/lib/flatpak/repo config set 'remote "flathub".http2' false 2>/dev/null || true

# Render + run the install script as the user, exactly as chezmoi would.
su - t -c 'chezmoi execute-template --source /repo < /repo/.chezmoiscripts/linux/run_onchange_after_install-packages.nu.tmpl > /tmp/install-packages.nu'
su - t -c 'nu /tmp/install-packages.nu'
