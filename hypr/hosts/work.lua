-- hypr/hosts/work.lua: the ThinkPad T14 Gen 7's own screen
-- A 1920x1200 panel at scale 1.25 it is 1536x960 logical pixels;
-- x = 2560 - 1536/2 = 1792 centres it under the two Dells.
return {
  laptop = {
    output = "eDP-1",
    mode = "preferred",
    position = "1792x1440",
    scale = "1.25",
  },
}
