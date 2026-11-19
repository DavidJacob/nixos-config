-- hypr/hosts/maple.lua: maple's own screen (Acer Swift 3, 1920x1080, 14")
-- At scale 1 it is 1920x1080 logical pixels; 1600x1440 centres it under the
-- two Dells (see the diagram in hyprland.lua).
return {
  laptop = {
    output = "eDP-1",
    mode = "preferred",
    position = "1600x1440",
    scale = "1",
  },
}
