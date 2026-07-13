local apps = require("lib/apps")
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

local MON_MAIN = "DP-1"
local MON_SECOND = "DP-2"

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

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		layout = "dwindle",
		border_size = 3,
		gaps_in = 3,
		gaps_out = 17,
		["col.active_border"] = "#567594",
		["col.inactive_border"] = "#a1a1a1",
	},
	-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
	dwindle = {
		preserve_split = true, -- required for the togglesplit bind
	},
	decoration = {
		inactive_opacity = 0.97,
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 0.7,

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
})

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("vicinae server")
	hl.exec_cmd("1password --silent")
	hl.exec_cmd("copyq --start-server")
	hl.exec_cmd("dunst")
end)

--------------------
---- WORKSPACES ----
--------------------
for _, ws in ipairs({ "name:0", "1", "2", "3", "4", "5" }) do
	hl.workspace_rule({ workspace = ws, monitor = MON_MAIN, default = ws == "1" })
end
for _, ws in ipairs({ "6", "7", "8", "9" }) do
	hl.workspace_rule({ workspace = ws, monitor = MON_SECOND, default = ws == "6" })
end

-----------------------
---- WINDOWS RULES ----
-----------------------
-- Verify classes with `hyprctl clients` and adjust.

-- Terminal
hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)$" }, workspace = "name:0" })

-- Dev
hl.window_rule({ match = { class = "^(Code|code|code-oss)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^([Ss]team)$" }, workspace = "2", float = true })

-- Browsers / Anki
hl.window_rule({
	match = { class = "^(firefox|brave-browser|google-chrome|chromium|zen|app.zen_browser.zen)$" },
	workspace = "3",
})
hl.window_rule({ match = { class = "^([Aa]nki)$" }, workspace = "3" })
-- TODO: float Anki dialogs (title not ending in "Anki"); verify titles with `hyprctl clients`.

-- API clients / VMs
hl.window_rule({ match = { class = "^(Postman|postman|[Bb]runo)$" }, workspace = "4" })
hl.window_rule({ match = { class = "^(VirtualBoxVM)$" }, workspace = "4" })

-- Notes
hl.window_rule({ match = { class = "^(obsidian)$" }, workspace = "5" })

-- Tasks
hl.window_rule({ match = { class = "^([Tt]odoist)$" }, workspace = "6" })

-- Mail / VM manager
hl.window_rule({ match = { class = "^(Mailspring|mailspring)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(VirtualBox Manager)$" }, workspace = "7" })

-- Chat
hl.window_rule({ match = { class = "^(discord|Slack)$" }, workspace = "8" })

-- Utility floats
hl.window_rule({ match = { class = "^(com\\.github\\.hluk\\.copyq)$" }, float = true })
hl.window_rule({ match = { title = "^([Pp]icture.in.[Pp]icture)$" }, float = true, pin = true })

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
hl.bind(FOCUS .. " + Z", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(FOCUS .. " + X", hl.dsp.window.close())
hl.bind(FOCUS .. " + W", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(FOCUS .. " + Q", hl.dsp.exit())
hl.bind(MOVE .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(FOCUS .. " + D", hl.dsp.layout("togglesplit"))
hl.bind(FOCUS .. " + C", hl.dsp.window.cycle_next())

-- Scroll through existing workspaces with SUPER + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

------------------------------------
---- KEYBINDINGS: APPLICATIONS ----
------------------------------------

hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + X", hl.dsp.window.close())
hl.bind("SUPER + Q", hl.dsp.exit())
hl.bind("SUPER + T", apps.run_or_raise("org.wezfurlong.wezterm", "wezterm"))
hl.bind("SUPER + R", apps.run_or_raise("app.zen_browser.zen", "flatpak run app.zen_browser.zen"))
hl.bind("SUPER + Z", apps.run_or_raise("obsidian", "obsidian"))
hl.bind("SUPER + H", apps.run_or_raise("todoist", "~/.local/bin/Todoist.AppImage"))
hl.bind("SUPER + W", apps.run_or_raise("ONLYOFFICE", "flatpak run org.onlyoffice.desktopeditors"))
hl.bind("SUPER + M", apps.run_or_raise("Mailspring", "mailspring"))
hl.bind(FOCUS .. " + Period", apps.run_or_raise("1password", "1password"))

--------------------------------
---- KEYBINDINGS: UTILITIES ----
--------------------------------
hl.bind(FOCUS .. " + Return", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd("copyq toggle"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"))

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
