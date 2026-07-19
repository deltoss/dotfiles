local apps = require("lib/apps")
local wallpaper = require("lib/wallpaper")
local wp_dir = os.getenv("HOME") .. "/Synced/Images/Live Wallpapers"
local workspaces = require("lib.workspaces")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "1.33",
})

--------------------
---- WORKSPACES ----
--------------------

workspaces.setup()
--- WS 1-5, 10 → leftmost monitor, WS 6-9 → rightmost
hl.on("monitor.added", workspaces.setup)
hl.on("monitor.removed", workspaces.setup)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_SIZE", "32")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.env("STEAM_FORCE_DESKTOPUI_SCALING", "1.5")

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
  general = {
    layout = "scrolling",
    border_size = 3,
    gaps_in = 3,
    gaps_out = {
      top = 8,
      left = 12,
      right = 12,
      bottom = 8,
    },
    ["col.active_border"] = "#567594",
    ["col.inactive_border"] = "#a1a1a1",

    -- Snap windows/monitors together when dragging/resizing
    snap = {
      enabled = true,
      window_gap = 4,
      monitor_gap = 5,
      respect_gaps = true,
    },

    -- Lets window_rule { immediate = true } (see TEARING below) actually skip vsync for matched windows
    allow_tearing = true,
  },
  scrolling = {
    column_width = 0.98,
    wrap_focus = false,
    wrap_swapcol = false,
  },
  decoration = {
    inactive_opacity = 0.97,
    rounding = 10,
    rounding_power = 2,

    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 0.8,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = 0xee1a1a1a,
    },

    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },
  animations = {
    enabled = true,
  },
  cursor = {
    warp_on_change_workspace = 1,
  },
  misc = {
    focus_on_activate = true,
  },
})

-- Wallpaper layer transitions (mpvpaper / linux-wallpaperengine surfaces).
hl.curve("popBounce", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1.0 } } })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "popBounce", style = "popin 85%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "popBounce", style = "popin 85%" })

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm app -- waybar")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("uwsm app -- vicinae server")
  hl.exec_cmd("uwsm app -- 1password --silent")
  hl.exec_cmd("uwsm app -- copyq --start-server")
  hl.exec_cmd("uwsm app -- swaync")
  wallpaper.apply(wp_dir)
  hl.exec_cmd("uwsm app -- hypridle")
end)

-----------------------
--- WORKSPACE RULES ---
-----------------------

hl.workspace_rule({
  workspace = "special:term",
  on_created_empty = "uwsm app -- wezterm start --class wezterm-special",
})

-----------------------
---- WINDOWS RULES ----
-----------------------
-- Verify classes with `hyprctl clients` and adjust.

-- Cozy/idle games launched via SUPER+ALT+F (see KEYBINDINGS: APPLICATIONS).
-- Single source of truth for id+name, shared by the window rule below and the launch keybind.
local steamGames = {
  { id = 2113850, name = "Spirit City: Lofi Sessions" },
  { id = 2943180, name = "Virtual Cottage 2" },
  { id = 3511030, name = "Mini Cozy Room: Lo-Fi" },
  { id = 2826180, name = "Chill Pulse" },
}

hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)$" }, workspace = "name:0" })
hl.window_rule({ match = { class = "^(Code|code|code-oss)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^([Ss]team)$" }, workspace = "2", float = true })
hl.window_rule({
  match = { class = "^(firefox|brave-browser|google-chrome|chromium|zen|app.zen_browser.zen)$" },
  workspace = "3",
})
hl.window_rule({ match = { class = "^([Aa]nki)$" }, workspace = "3" })
-- TODO: float Anki dialogs (title not ending in "Anki"); verify titles with `hyprctl clients`.
hl.window_rule({ match = { class = "^(Postman|postman|[Bb]runo)$" }, workspace = "4" })
hl.window_rule({ match = { class = "^(VirtualBoxVM)$" }, workspace = "4" })
hl.window_rule({ match = { class = "^(obsidian)$" }, workspace = "5" })
hl.window_rule({ match = { class = "^([Tt]odoist)$" }, workspace = "6" })
hl.window_rule({ match = { class = "^(Mailspring|mailspring)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(VirtualBox Manager)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(discord|Slack)$" }, workspace = "8" })
for _, g in ipairs(steamGames) do -- Cozy games (see steamGames above) -> workspace 9
  hl.window_rule({
    match = { class = "^(steam_app_" .. g.id .. ")$" },
    workspace = "9",
    opacity = "1 override",
  })
end
hl.window_rule({
  match = { class = "com\\.github\\.hluk\\.copyq" },
  float = true,
  focus_on_activate = true,
  stay_focused = true,
})
hl.window_rule({
  match = { class = "wezterm-special" },
  float = true,
  center = true,
  size = {
    "(monitor_w*0.75)",
    "(monitor_h*0.75)",
  },
})

for _, c in ipairs({ "wiremix", "bluetui", "nmtui" }) do
  hl.window_rule({
    match = { class = c },
    float = true,
    center = true,
    size = {
      "(monitor_w*0.85)",
      "(monitor_h*0.85)",
    },
  })
end

hl.window_rule({
  match = { class = "io.github.seadve.Kooha" },
  float = true,
  pin = true,
  move = { "monitor_w*0.85-window_w", "monitor_h/2-window_h/2" },
})

hl.window_rule({
  match = { class = "hyprland-share-picker" },
  float = true,
  pin = true,
})

hl.window_rule({
  match = { class = "com.gabm.satty" },
  float = true,
})

-------------------------------------
---- SCREEN SHARE / PIP HANDLING ----
-------------------------------------
hl.window_rule({
  match = { title = ".*is sharing (a window|your screen).*" },
  float = true,
  pin = true,
})
hl.window_rule({
  match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
  float = true,
  pin = true,
  keep_aspect_ratio = true,
  size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
  move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
})

-----------------------------
---- TEARING (for games) ----
-----------------------------
-- `immediate = true` lets the matched window skip vsync and present frames as soon as
-- they're rendered instead of waiting for the next refresh, cutting input latency at the
-- cost of possible visible tearing. It only does anything if general.allow_tearing = true
-- (set above) AND the app itself requests an immediate/tearing present mode -- most
-- fullscreen games under Proton/gamescope/native Vulkan do this automatically, so this is
-- effectively "allow tearing for Steam games, keep vsync for everything else".
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })

------------------------------------------------------------------------------
-- Layer rules (Vicinae launcher, per docs.vicinae.com/quickstart/hyprland-lua)
------------------------------------------------------------------------------
hl.layer_rule({
  match = { namespace = "vicinae" },
  name = "vicinae-blur",
  blur = true,
  ignore_alpha = 0,
})
hl.layer_rule({
  match = { namespace = "vicinae" },
  name = "vicinae-no-animation",
  no_anim = true,
})

----------------------------------
---- KEYBINDINGS: NAVIGATIONS ----
----------------------------------
local FOCUS = "CTRL + ALT + SHIFT"
local MOVE = "ALT + SHIFT"

local dirKeys = { { "y", "left", "l" }, { "e", "right", "r" }, { "a", "up", "u" }, { "h", "down", "d" } }

for _, k in ipairs(dirKeys) do
  local key, arrow, dir = k[1], k[2], k[3]
  hl.bind(FOCUS .. " + " .. key, hl.dsp.focus({ direction = dir }))
  hl.bind(FOCUS .. " + " .. arrow, hl.dsp.focus({ direction = dir }))
  hl.bind(MOVE .. " + " .. key, hl.dsp.window.move({ direction = dir }))
  hl.bind(MOVE .. " + " .. arrow, hl.dsp.window.move({ direction = dir }))
end

---------------------------------
---- KEYBINDINGS: WORKSPACES ----
---------------------------------
local wsKeys = {
  ["1"] = 1,
  ["2"] = 2,
  ["3"] = 3,
  ["4"] = 4,
  ["5"] = 5,
  ["6"] = 6,
  ["7"] = 7,
  ["8"] = 8,
  ["9"] = 9,
  ["0"] = "name:0",
}
for key, ws in pairs(wsKeys) do
  hl.bind(FOCUS .. " + " .. key, hl.dsp.focus({ workspace = ws }))
  hl.bind(MOVE .. " + " .. key, hl.dsp.window.move({ workspace = ws, follow = true }))
end

hl.bind(FOCUS .. " + U", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(FOCUS .. " + Page_Up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(FOCUS .. " + O", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(FOCUS .. " + Page_Down", hl.dsp.focus({ workspace = "e-1" }))

------------------------------------
---- KEYBINDINGS: WINDOW STATES ----
------------------------------------
hl.bind(FOCUS .. " + P", hl.dsp.window.pseudo())
hl.bind(FOCUS .. " + S", function()
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  hl.dispatch(hl.dsp.window.center())
end)
hl.bind(FOCUS .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(FOCUS .. " + Z", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(FOCUS .. " + X", hl.dsp.window.close())
hl.bind(FOCUS .. " + W", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(FOCUS .. " + Q", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(MOVE .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(FOCUS .. " + C", hl.dsp.window.cycle_next())

-- Scroll through existing workspaces with SUPER + scroll
hl.bind("ALT + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })

------------------------------------
---- KEYBINDINGS: APPLICATIONS ----
------------------------------------

hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + X", hl.dsp.window.close())
hl.bind("SUPER + Q", hl.dsp.exit())
hl.bind("SUPER + T", apps.run_or_raise("org.wezfurlong.wezterm", "uwsm app -- wezterm"))
hl.bind("SUPER + R", apps.run_or_raise("app.zen_browser.zen", "uwsm app -- flatpak run app.zen_browser.zen"))
hl.bind("SUPER + Z", apps.run_or_raise("obsidian", "uwsm app -- obsidian"))
hl.bind("SUPER + H", apps.run_or_raise("todoist", "uwsm app -- ~/.local/bin/Todoist.AppImage"))
hl.bind("SUPER + W", function()
  wallpaper.shuffle(wp_dir)
end)
hl.bind("SUPER + ALT + W", apps.run_or_raise("ONLYOFFICE", "uwsm app -- flatpak run org.onlyoffice.desktopeditors"))
hl.bind("SUPER + M", apps.run_or_raise("Mailspring", "uwsm app -- mailspring"))
hl.bind(FOCUS .. " + Period", apps.run_or_raise("1password", "uwsm app -- 1password"))
hl.bind("SUPER + Slash", hl.dsp.workspace.toggle_special("term"))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("vicinae vicinae://launch/core/search-emojis"))

-- Window + Alt + F - [F]ocus Steam Game
-- Fires the rungameid URI at whatever Steam instance is already running
-- (launching Steam fresh if it isn't open at all).
hl.bind("SUPER + ALT + F", function()
  local game = steamGames[math.random(#steamGames)]
  hl.exec_cmd('uwsm app -- steam -silent -- "steam://rungameid/' .. game.id .. '"')
end)

--------------------------------
---- KEYBINDINGS: UTILITIES ----
--------------------------------
-- Windows-style lock: SUPER + L -> hyprlock immediately (no dependency on hypridle/loginctl)
hl.bind("SUPER + L", hl.dsp.exec_cmd("uwsm app -- hyprlock"), { locked = true, description = "Session: Lock" })

hl.bind(FOCUS .. " + Return", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd("copyq toggle"))
hl.bind("Print", hl.dsp.exec_cmd("uwsm app -- sh -c 'hyprshot -m region --raw | satty --filename -'"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("uwsm app -- flatpak run com.github.dynobo.normcap"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("uwsm app -- flatpak run io.github.seadve.Kooha"))

hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true }
)
---------------------
---- SCREEN ZOOM ----
---------------------
local function zoomfunction(value)
  local zoomvalue = hl.get_config("cursor:zoom_factor")
  if (zoomvalue + value) > 3.0 then
    hl.config({ cursor = { zoom_factor = 3.0 } })
  elseif (zoomvalue + value) < 1.0 then
    hl.config({ cursor = { zoom_factor = 1.0 } })
  else
    hl.config({ cursor = { zoom_factor = zoomvalue + value } })
  end
end
hl.bind(FOCUS .. " + Minus", function()
  zoomfunction(-0.3)
end, { repeating = true })
hl.bind(FOCUS .. " + Equal", function()
  zoomfunction(0.3)
end, { repeating = true })

-----------------------
---- RESIZE SUBMAP ----
-----------------------
hl.bind(FOCUS .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
  local step = 40
  local resizes = {
    { keys = { "Y", "left" }, x = -step, y = 0 },
    { keys = { "E", "right" }, x = step, y = 0 },
    { keys = { "A", "up" }, x = 0, y = step },
    { keys = { "H", "down" }, x = 0, y = -step },
  }
  for _, r in ipairs(resizes) do
    for _, key in ipairs(r.keys) do
      hl.bind(key, hl.dsp.window.resize({ x = r.x, y = r.y, relative = true }), { repeating = true })
    end
  end
  hl.bind("Escape", hl.dsp.submap("reset"))
  hl.bind("Return", hl.dsp.submap("reset"))
end)
