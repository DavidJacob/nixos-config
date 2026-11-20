# Notes

Open items, and the reasons behind choices that aren't obvious from the code.
Rules for working in the repo are in `AGENTS.md`; this file is the history.

## Open items

### Hyprland

- **hypridle is started twice.** It runs as a systemd user service *and* from
  the autostart in `hypr/hyprland.lua` (`hl.exec_cmd("hypridle")`). Confirmed
  with `pgrep -a hypridle` (two processes) and hypridle's own log ("Another
  service is already providing the org.freedesktop.ScreenSaver interface").
  Fix: delete that autostart line; the service restarts hypridle if it dies.
- **Crashes with no trace.** On maple, Hyprland has died while idle (once at
  13:20 on 2026-11-18), leaving no crash report, no core dump and no kernel
  errors; it restarted in safe mode. Its own output isn't recorded when the
  login screen (greetd) starts it. Next step if it recurs: send Hyprland's
  output to the journal so the next crash leaves a reason.
- **No lint exception for generated files.** statix warns about repeated keys
  in `hosts/*/hardware-configuration.nix`. Optional fix: a `condition` for
  statix in `nvim/lua/plugins/lint.lua` that skips `hardware-configuration.nix`.

### MacBook (not installed yet)

- Set `my.disk.swapSize` to its RAM (8G or 16G) before installing.
- Speakers and headphone jack: the Cirrus Logic CS8409 needs the out-of-tree
  `snd_hda_macbookpro` driver, not packaged in nixpkgs.
- Touch Bar: untested.
- Check the screen output name and scale in `hypr/hosts/macbook.lua` after
  install.
- Create its own GPG key and put the ID in `home/hosts/macbook.nix`. Until
  then git picks a key by email.

### System updates

- A `sysupdate` script was designed but postponed: pull, `nix flake update`,
  build into a temp dir, show `nvd diff`, ask before switching, commit and push
  only `flake.lock`, warn about kernel changes. For now: the `update` alias.

### Work

- `disabledModules = [ "services/monitoring/orbit.nix" ]` is a workaround; see
  "Why" below. Remove it once famedly-nixos handles the clash.
- Optional: Famedly's Cachix binary cache (commented out in
  `hosts/work/default.nix`; needs a token in `/etc/nix/netrc`).

### Claude Code

- Frequent forced re-logins were seen. Likely causes: several Claude processes
  (terminal sessions plus CodeCompanion's `claude_code` adapter) renewing the
  login at the same time, or an old version. The nixpkgs build lags behind
  upstream; `update` brings newer versions.

## Why things are the way they are

- **Repo in `~/nixos-config`, not `/etc/nixos`:** David owns it, no root
  needed to edit, and no /etc tab completion noise. `nixos-rebuild --sudo`
  builds as the user and only switches as root, which avoids git's "not owned
  by current user".
- **disko everywhere:** maple was first installed by hand (partition labels
  `cryptroot`/`swap`) and reinstalled with disko on 2026-11-19, so all three
  machines now share one layout and `stateVersion` 26.11.
- **Writable links for `hypr/` and `nvim/`:** `mkOutOfStoreSymlink` makes
  `~/.config/hypr` and `~/.config/nvim` point into the repo, so edits apply
  without a rebuild and lazy.nvim can update `lazy-lock.json`. The chain is
  `~/.config/hypr → store → /home/david/nixos-config/hypr`.
- **Hyprland per-host file via `/etc/hostname`:** keeps one shared
  `hyprland.lua` and the whole `hypr/` folder as a single link. Tested to work
  in Lua 5.4 and LuaJIT; falls back to safe defaults.
- **Element is wrapped, not overridden:** `override` rebuilt Electron from
  source (1.4 GB). `symlinkJoin` + `wrapProgram` adds
  `--password-store=gnome-libsecret` to the pre-built package. Element is
  work-only.
- **k9s read-only by default (work):** configured with `programs.k9s` in
  `home/hosts/work.nix` (which also installs it, so it's not in
  `home.packages`). `readOnly = true` blocks changes to clusters; start
  `k9s --write` for a session that needs them. `~/.config/k9s/config.yaml` is
  a read-only Home Manager file, so settings changed inside k9s don't stick.
- **orbit module disabled on work:** nixos-unstable added its own
  `services.orbit`, which clashes with the one from fleet-nixos (pulled in by
  famedly-nixos): "services.orbit.enable is already declared".
- **Fleet secret via systemd-creds:** orbit reads it when it starts, so the
  machine installs and boots without it; the secret never touches the repo.
- **Work email outside the repo:** the repo is public; the address lives in
  `~/.config/git/work-identity`, included by git.
- **YubiKey through pcscd:** GnuPG's own USB driver takes the key exclusively,
  so ykman (which uses pcscd) and gpg fight over it. `disable-ccid` +
  `pcsc-shared` in `scdaemon.conf` make gpg go through pcscd.
- **nixos-hardware choices:** no profiles exist for the Acer SF314-59 or the
  ThinkPad T14 Gen 7; the MacBook uses the 14-1 profile (closest model). The
  generic `common-pc-ssd` profile was dropped because NixOS enables fstrim by
  default.
- **Firmware:** `hardware.enableRedistributableFirmware` comes from the
  generated hardware file (`not-detected.nix`), on every machine.
- **CalDigit audio has low priority:** WirePlumber rule in
  `modules/common.nix`, so the laptop's speakers and mic stay the default when
  docked.
- **Lid and sleep:** lid closed suspends; after 1 hour asleep it hibernates
  (swap on LVM inside LUKS, resume configured by disko). Idle: lock at 15 min,
  screens off at 15.5, suspend at 30 (`hypr/hypridle.conf`).
- **Mason plus Nix in Neovim:** Mason's builds of lua_ls and marksman need
  libraries NixOS doesn't have, so those come from Nix (`mason = false`);
  everything else stays with Mason, made to work by nix-ld and the toolchains
  in `programs.neovim.extraPackages`.
