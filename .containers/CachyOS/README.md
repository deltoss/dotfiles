# CachyOS test container

Throwaway CachyOS box for trying the Linux install scripts before they touch a real machine.
The container boots systemd, so Flatpak system installs run for real (they need D-Bus + polkit).

## Build

```nu
podman build -t my-cachy .containers/CachyOS
```

## Test the package install script

Boot the container with systemd, then run the harness. It renders
`.chezmoiscripts/linux/run_onchange_after_install-packages.nu.tmpl` and runs it as a
normal user, the way chezmoi would (paru/makepkg refuse root):

```nu
podman run -d --name cachy-test --privileged --systemd=always -v $"($env.PWD):/repo:ro" my-cachy
podman exec cachy-test bash /repo/.containers/CachyOS/test-packages.sh
```

Watch for your package's `Checking <name>...` line and confirm it installs clean. Notes:

- `--privileged --systemd=always` boots systemd as PID 1. Without them dbus hangs and the
  Flatpak installs cannot authorize.
- Flip `computerPurpose` in `test-packages.sh` to test `work`-tagged packages.
- Flatpak installs are real now, so the run downloads the GNOME/KDE/freedesktop runtimes
  (a few GB). Skip those entries if you only added a non-flatpak package and want speed.
- The named container persists, so re-running `podman exec ... test-packages.sh` skips
  already-installed packages. `podman rm -f cachy-test` when done.

## Interactive shell

```nu
podman run -it --rm my-cachy bash
```
