local M = {}

local function list_videos(dir)
  local files = {}
  local p = io.popen('find "' .. dir .. '" -type f')
  if p then
    for line in p:lines() do
      if line:match("%.mp4$") or line:match("%.webm$") or line:match("%.mkv$") then
        table.insert(files, line)
      end
    end
    p:close()
  end
  return files
end

function M.random(dir)
  local files = list_videos(dir)
  if #files == 0 then
    return nil
  end
  math.randomseed(os.time())
  return files[math.random(#files)]
end

function M.apply(dir)
  local wp = M.random(dir)
  if wp then
    hl.exec_cmd("mpvpaper -o 'no-audio loop hwdec=auto panscan=1.0' '*' \"" .. wp .. '"')
  end
end

function M.shuffle(dir)
  local wp = M.random(dir)
  if wp then
    hl.exec_cmd(
      'sh -c \'pkill mpvpaper; sleep 0.3; exec mpvpaper -o "no-audio loop hwdec=auto panscan=1.0" "*" "' .. wp .. "\"'"
    )
  end
end

return M
