------------------------------------------------------------------------------
-- Monitors
------------------------------------------------------------------------------
-- TODO: run `hyprctl monitors` and replace these names.
local MON_MAIN = "DP-1"
local MON_SECOND = "HDMI-A-1"

------------------------------------------------------------------------------
-- General / looks
------------------------------------------------------------------------------
hl.config({
	general = {
		layout = "dwindle",
		border_size = 2,
		gaps_in = 3,
		gaps_out = 13,
		["col.active_border"] = "#567594",
		["col.inactive_border"] = "#a1a1a1",
	},
	dwindle = {
		preserve_split = true, -- required for the togglesplit bind
	},
	decoration = {
		inactive_opacity = 0.97,
	},
	input = {
		follow_mouse = 0,
	},
	cursor = {
		warp_on_change_workspace = 1,
	},
})

------------------------------------------------------------------------------
-- Autostart
------------------------------------------------------------------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("vicinae server")
end)

------------------------------------------------------------------------------
-- Workspaces
------------------------------------------------------------------------------
for _, ws in ipairs({ "name:0", "1", "2", "3", "4", "5" }) do
	hl.workspace_rule({ workspace = ws, monitor = MON_MAIN, default = ws == "1" })
end
for _, ws in ipairs({ "6", "7", "8", "9" }) do
	hl.workspace_rule({ workspace = ws, monitor = MON_SECOND, default = ws == "6" })
end

------------------------------------------------------------------------------
-- Window rules
------------------------------------------------------------------------------
-- Verify classes with `hyprctl clients` and adjust.

-- Terminal
hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)$" }, workspace = "name:0" })

-- Dev
hl.window_rule({ match = { class = "^(Code|code|code-oss)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^([Ss]team)$" }, workspace = "2", float = true })

-- Browsers / Anki
hl.window_rule({ match = { class = "^(firefox|brave-browser|google-chrome|chromium|zen)$" }, workspace = "3" })
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

------------------------------------------------------------------------------
-- Keybinds: focus / move (y=left, e=right, a=up, h=down)
------------------------------------------------------------------------------
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

------------------------------------------------------------------------------
-- Keybinds: workspaces (key 0 -> workspace 0)
------------------------------------------------------------------------------
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
hl.bind(FOCUS .. " + P", hl.dsp.focus({ workspace = "previous" }))

------------------------------------------------------------------------------
-- Keybinds: window state
------------------------------------------------------------------------------
hl.bind(FOCUS .. " + S", function()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	hl.dispatch(hl.dsp.window.center())
end)
hl.bind(FOCUS .. " + T", hl.dsp.window.float({ action = "disable" }))
hl.bind(FOCUS .. " + Z", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(FOCUS .. " + X", hl.dsp.window.close())
hl.bind(FOCUS .. " + W", hl.dsp.window.close())
hl.bind(FOCUS .. " + Q", hl.dsp.exit())
hl.bind(MOVE .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(FOCUS .. " + D", hl.dsp.layout("togglesplit"))
hl.bind(FOCUS .. " + C", hl.dsp.window.cycle_next())

------------------------------------------------------------------------------
-- Keybinds: application shortcuts
------------------------------------------------------------------------------
hl.bind("SUPER + X", hl.dsp.window.close())
hl.bind("SUPER + Q", hl.dsp.exit())
hl.bind("SUPER + T", hl.dsp.exec_cmd("wezterm"))

------------------------------------------------------------------------------
-- Keybinds: utilities
------------------------------------------------------------------------------
hl.bind(FOCUS .. " + Return", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd("copyq toggle"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"))

------------------------------------------------------------------------------
-- Resize submap
------------------------------------------------------------------------------
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
