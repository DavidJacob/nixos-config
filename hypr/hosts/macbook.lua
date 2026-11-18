-- hypr/hosts/macbook.lua: the MacBook's own screen (13" Retina, 2560x1600)
-- At scale 2 it is 1280x800 logical pixels; 1920x1440 centres it under the
-- two Dells (see the diagram in hyprland.lua).
-- TODO: check the output name after install with `hyprctl monitors`.
return {
  laptop = {
    output = "eDP-1",
    mode = "preferred",
    position = "1920x1440",
    scale = "2",
  },
}
