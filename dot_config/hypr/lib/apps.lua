local M = {}

-- Run-or-raise-or-cycle:
--   no window   -> launch cmd
--   not focused -> focus most recently used window of that class
--   focused     -> cycle to next window in stable (address) order
-- NOTE: cycling must use a stable order, NOT focus_history_id.
-- MRU order mutates when you focus, so wins[2] always points back
-- at the window you just left -> ping-pong between 2 windows.
function M.run_or_raise(class, cmd)
	return function()
		local wins = hl.get_windows({ class = class })
		if #wins == 0 then
			hl.dispatch(hl.dsp.exec_cmd(cmd))
			return
		end

		local active = hl.get_active_window()

		if active == nil or active.class ~= class then
			-- Not on one -> jump to most recently used
			table.sort(wins, function(a, b)
				return a.focus_history_id < b.focus_history_id
			end)
			hl.dispatch(hl.dsp.focus({ window = wins[1] }))
			return
		end

		-- Already on one -> cycle in stable (address) order
		table.sort(wins, function(a, b)
			return a.address < b.address
		end)

		local idx = 1
		for i, w in ipairs(wins) do
			if w.address == active.address then
				idx = i
				break
			end
		end

		local target = wins[(idx % #wins) + 1] -- next, wrapping around
		hl.dispatch(hl.dsp.focus({ window = target }))
	end
end

return M
