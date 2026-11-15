# Turns `hyprctl binds -j` into a grouped shortcut table.
# Binds are included when their description looks like "Category: what it does".
# Binds sharing a category, description and modifiers are merged into one row.

def modnames:
  . as $m
  | [["Super", 64], ["Ctrl", 4], ["Alt", 8], ["Shift", 1]]
  | map(select((($m / .[1]) | floor) % 2 == 1) | .[0]);

def pretty:
  {
    "Return": "Enter", "slash": "/", "comma": ",", "period": ".",
    "Escape": "Esc", "Print": "PrtSc", "space": "Space",
    "left": "←", "right": "→", "up": "↑", "down": "↓",
    "mouse:272": "Left-drag", "mouse:273": "Right-drag",
    "XF86AudioRaiseVolume": "Vol+", "XF86AudioLowerVolume": "Vol-",
    "XF86AudioMute": "Mute", "XF86AudioMicMute": "Mic-mute",
    "XF86MonBrightnessUp": "Bright+", "XF86MonBrightnessDown": "Bright-"
  }[.] // (if length == 1 then ascii_upcase else . end);

def keylist:
  if length > 2 and all(test("^[0-9]$")) then ["\(.[0])…\(.[-1])"] else . end;

[ .[]
  | select(.has_description and (.description | test("^[^:]+:")))
  | (.description | capture("^(?<cat>[^:]+):\\s*(?<desc>.*)$")) as $d
  | { cat: $d.cat, desc: $d.desc, mods: (.modmask | modnames | join(" + ")), key: (.key | pretty) }
]
| reduce .[] as $b ([];
    (map(.cat == $b.cat and .desc == $b.desc and .mods == $b.mods) | index(true)) as $i
    | if $i == null then . + [$b + { keys: [$b.key] }] else .[$i].keys += [$b.key] end)
| map(. + { combo: ((if .mods == "" then "" else .mods + " + " end) + (.keys | keylist | join(" / "))) })
| (map(.combo | length) | max) as $w
| (reduce (.[].cat) as $c ([]; if index([$c]) then . else . + [$c] end)) as $cats
| . as $rows
| $cats[] as $c
| "\n  \u001b[1;34m\($c)\u001b[0m",
  ($rows[] | select(.cat == $c)
    | "    \u001b[1m\(.combo)\u001b[0m\(" " * ($w - (.combo | length) + 3))\(.desc)")
