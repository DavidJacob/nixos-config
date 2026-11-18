-- ~/.config/hypr/hyprland.lua: shared by all three laptops (Hyprland 0.55+ Lua format)
-- Changes apply as soon as you save. Full reference: https://wiki.hypr.land/Configuring/Start/
--
-- Each laptop's own screen is set in hypr/hosts/<hostname>.lua; everything
-- else in this file is the same everywhere.

------------------
---- MONITORS ----
------------------
-- Desk layout (logical pixels): the two Dells side by side on top, the laptop
-- centred underneath. Moving the cursor off the top of the laptop screen
-- lands on the monitors.
--
--   +----------------+----------------+
--   |  left Dell     |  right Dell    |   each 2560x1440
--   |  0x0           |  2560x0        |
--   |  workspaces 2-3|  workspaces 4-5|
--   +--------+-------+-------+--------+
--            |     laptop     |           position and scale: hypr/hosts/<hostname>.lua
--            |   1920x1440    |
--            |  workspace 1   |
--            +----------------+
--
-- The Dells are matched by description (make, model, serial) rather than by
-- DP-x name, because those names can change between docks and reconnects.

local leftDell = "desc:Dell Inc. DELL P2720DC 81WTK9BQ09LS" -- cabled to the CalDigit
local rightDell = "desc:Dell Inc. DELL P2720DC 81WTK9CD05SS" -- daisy-chained from the left one

-- This laptop's own screen, from hypr/hosts/<hostname>.lua (e.g. hosts/maple.lua).
-- If there's no file for this machine, the screen still works with defaults.
local function loadHost()
  local file = io.open("/etc/hostname", "r")
  local name = file and file:read("*l")
  if file then
    file:close()
  end
  local found, result = pcall(require, "hosts." .. name)
  if found then
    return result
  end
  return dofile(os.getenv("HOME") .. "/.config/hypr/hosts/" .. name .. ".lua")
end

local ok, host = pcall(loadHost)
if not ok then
  host = { laptop = { output = "eDP-1", mode = "preferred", position = "auto", scale = "auto" } }
end

local laptop = host.laptop
hl.monitor(laptop)

hl.monitor({
  output = leftDell,
  mode = "2560x1440@59.95",
  position = "0x0",
  scale = "1",
})

hl.monitor({
  output = rightDell,
  mode = "2560x1440@59.95",
  position = "2560x0",
  scale = "1",
})

-- Any other screen (a projector, a friend's monitor): sensible defaults
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

-- Lid closed at the desk: turn the laptop screen off.
hl.bind("switch:on:Lid Switch", function()
  hl.monitor({ output = laptop.output, disabled = true })
end, { locked = true })

-- Lid opened: reload the config, which switches the laptop screen back on.
-- (Re-adding the monitor rule at runtime doesn't wake a disabled screen.)
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl reload"), { locked = true })

------------------------------
---- WORKSPACES ON SCREENS ----
------------------------------
--   laptop:      1
--   left Dell:   2 (Matrix), 3 (ghostty)
--   right Dell:  4 (Chrome), 5 (free)
--
-- Each screen starts on its first workspace. Undocked, the Dell rules find no
-- screen, so workspaces 2-5 open on the laptop when you use them.
hl.workspace_rule({ workspace = "1", monitor = laptop.output, default = true })
hl.workspace_rule({ workspace = "2", monitor = leftDell, default = true })
hl.workspace_rule({ workspace = "3", monitor = leftDell })
hl.workspace_rule({ workspace = "4", monitor = rightDell, default = true })
hl.workspace_rule({ workspace = "5", monitor = rightDell })

-- Programs with a home workspace. New windows open there, and the view switches
-- to it. Add "silent" (e.g. workspace = "3 silent") to open without switching.
-- Find a program's class with: hyprctl clients | grep class
hl.window_rule({
  name = "element-on-workspace-2",
  match = { class = "^([Ee]lement|element-desktop)$" },
  workspace = "2",
})

hl.window_rule({
  name = "ghostty-on-workspace-3",
  match = { class = "^com\\.mitchellh\\.ghostty$" },
  workspace = "3",
})

hl.window_rule({
  name = "chrome-on-workspace-4",
  match = { class = "^google-chrome$" },
  workspace = "4",
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "ghostty"
local menu = "noctalia msg panel-toggle launcher"
local ipc = "noctalia msg"
local mainMod = "SUPER"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia") -- bar, launcher, notifications, Wi-Fi/Bluetooth/sound widgets
  hl.exec_cmd("hypridle")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("udiskie --tray")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
    col = {
      active_border = "rgba(89b4faee)",
      inactive_border = "rgba(595959aa)",
    },
    layout = "dwindle",
  },

  decoration = {
    rounding = 6,
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  misc = {
    force_default_wallpaper = 0, -- plain background instead of the mascot wallpaper
    disable_hyprland_logo = true,
  },
})

---------------
---- INPUT ----
---------------
hl.config({
  input = {
    kb_layout = "us",
    kb_options = "caps:swapescape",
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
    },
  },
})

-- Three-finger swipe on the touchpad switches workspace
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------
-- Each description reads "Category: what it does". Binds with one appear in
-- the shortcut cheatsheet (Super+/), grouped by category; binds sharing a
-- description are merged into one row.

-- Help
hl.bind(
  mainMod .. " + slash",
  hl.dsp.exec_cmd("hypr-cheatsheet-toggle"),
  { description = "Help: Show or hide this cheatsheet" }
)

-- Apps and Noctalia
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal), { description = "Apps: Open terminal" })
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu), { description = "Noctalia: App launcher" })
hl.bind(
  mainMod .. " + S",
  hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"),
  { description = "Noctalia: Control centre (Wi-Fi, Bluetooth, sound)" }
)
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(ipc .. " panel-toggle session"), { description = "Noctalia: Power menu" })
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. " settings-toggle"), { description = "Noctalia: Settings" })

-- Windows
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Windows: Close window" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(), { description = "Windows: Toggle fullscreen" })
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Windows: Toggle floating" })

-- Layout: arranging windows on one screen
hl.bind(
  mainMod .. " + T",
  hl.dsp.layout("togglesplit"),
  { description = "Layout: Flip split (side by side / stacked)" }
)
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.layout("swapsplit"), { description = "Layout: Swap the two halves" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "Layout: Keep window's own size in its slot" })

-- Resize the focused window: Super + Ctrl + vim keys or arrows (hold to repeat)
local resizeSteps = {
  { keys = { "h", "left" }, x = -40, y = 0, what = "narrower" },
  { keys = { "l", "right" }, x = 40, y = 0, what = "wider" },
  { keys = { "k", "up" }, x = 0, y = -40, what = "shorter" },
  { keys = { "j", "down" }, x = 0, y = 40, what = "taller" },
}
for _, r in ipairs(resizeSteps) do
  for _, key in ipairs(r.keys) do
    hl.bind(
      mainMod .. " + CTRL + " .. key,
      hl.dsp.window.resize({ x = r.x, y = r.y, relative = true }),
      { repeating = true, description = "Layout: Make window " .. r.what }
    )
  end
end

-- Tabs: stack windows in one slot and flip between them
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Layout: Turn window into a tab group (or back)" })
hl.bind(mainMod .. " + Tab", hl.dsp.group.next(), { description = "Layout: Next tab" })
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev(), { description = "Layout: Previous tab" })

-- Move focus and windows: vim keys or arrows
local directions = {
  { keys = { "h", "left" }, dir = "left" },
  { keys = { "j", "down" }, dir = "down" },
  { keys = { "k", "up" }, dir = "up" },
  { keys = { "l", "right" }, dir = "right" },
}
for _, d in ipairs(directions) do
  for _, key in ipairs(d.keys) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = d.dir }), { description = "Windows: Focus " .. d.dir })
  end
end
for _, d in ipairs(directions) do
  for _, key in ipairs(d.keys) do
    hl.bind(
      mainMod .. " + SHIFT + " .. key,
      hl.dsp.window.move({ direction = d.dir }),
      { description = "Windows: Move window " .. d.dir .. " (also to the next screen)" }
    )
  end
end

-- Mouse: Super + left-drag moves, Super + right-drag resizes
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Windows: Move with the mouse" })
hl.bind(
  mainMod .. " + mouse:273",
  hl.dsp.window.resize(),
  { mouse = true, description = "Windows: Resize with the mouse" }
)

-- Tabs: move the focused window into the group next to it (or back out)
local intoGroup = {
  { keys = { "h", "left" }, dir = "left" },
  { keys = { "j", "down" }, dir = "down" },
  { keys = { "k", "up" }, dir = "up" },
  { keys = { "l", "right" }, dir = "right" },
}
for _, g in ipairs(intoGroup) do
  for _, key in ipairs(g.keys) do
    hl.bind(
      mainMod .. " + ALT + " .. key,
      hl.dsp.window.move({ into_group = g.dir }),
      { description = "Layout: Add window to the tab group " .. g.dir }
    )
  end
end
hl.bind(
  mainMod .. " + ALT + O",
  hl.dsp.window.move({ out_of_group = true }),
  { description = "Layout: Take window out of its tab group" }
)

-- Workspaces 1-10: Super + number switches, Super + Shift + number moves the window
for i = 1, 10 do
  local key = i % 10 -- workspace 10 is on key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Workspaces: Go to workspace" })
  hl.bind(
    mainMod .. " + SHIFT + " .. key,
    hl.dsp.window.move({ workspace = i }),
    { description = "Workspaces: Move window to workspace" }
  )
end

-- Screenshot of a selected area, copied to the clipboard
hl.bind(
  "Print",
  hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'),
  { description = "Screenshots: Select an area, copy to clipboard" }
)
hl.bind(
  mainMod .. " + SHIFT + S",
  hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'),
  { description = "Screenshots: Select an area, copy to clipboard" }
)

-- Laptop volume keys, with Noctalia's on-screen popups
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd(ipc .. " volume-up"),
  { locked = true, repeating = true, description = "Media: Volume up" }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd(ipc .. " volume-down"),
  { locked = true, repeating = true, description = "Media: Volume down" }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd(ipc .. " volume-mute"),
  { locked = true, description = "Media: Mute speakers" }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd(ipc .. " mic-mute"),
  { locked = true, description = "Media: Mute microphone" }
)

-- Brightness: laptop keys always control the laptop screen
hl.bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd(ipc .. " brightness-up eDP-1"),
  { locked = true, repeating = true, description = "Screens: Laptop brighter" }
)
hl.bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd(ipc .. " brightness-down eDP-1"),
  { locked = true, repeating = true, description = "Screens: Laptop dimmer" }
)

-- Super + brightness keys: the screen the cursor is on (a Dell at the desk)
hl.bind(
  mainMod .. " + XF86MonBrightnessUp",
  hl.dsp.exec_cmd(ipc .. " brightness-up"),
  { repeating = true, description = "Screens: Current screen brighter" }
)
hl.bind(
  mainMod .. " + XF86MonBrightnessDown",
  hl.dsp.exec_cmd(ipc .. " brightness-down"),
  { repeating = true, description = "Screens: Current screen dimmer" }
)

-- Super + Shift + brightness keys: every screen at once
hl.bind(
  mainMod .. " + SHIFT + XF86MonBrightnessUp",
  hl.dsp.exec_cmd(ipc .. " brightness-up '*'"),
  { repeating = true, description = "Screens: All screens brighter" }
)
hl.bind(
  mainMod .. " + SHIFT + XF86MonBrightnessDown",
  hl.dsp.exec_cmd(ipc .. " brightness-down '*'"),
  { repeating = true, description = "Screens: All screens dimmer" }
)

-- Session
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"), { description = "Session: Lock screen" })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit(), { description = "Session: Log out of Hyprland" })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
  -- The shortcut cheatsheet (Super+/): a floating window in the middle of the screen
  name = "cheatsheet",
  match = { class = "^nixos\\.cheatsheet$" },
  float = true,
  size = "760 monitor_h*0.85", -- fits the laptop screen as well as the Dells
  center = true,
})

hl.window_rule({
  -- Ignore apps that try to maximise themselves
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})
