local M = {}
local MATCH_FIELDS = { "process", "class", "title" }
local ALLOWED_FIELDS = { process = true, class = true, title = true, prompt = true }

local function validate_rule(rule, index)
  if type(rule) ~= "table" then
    return false, "rule " .. index .. " must be a table"
  end

  for field in pairs(rule) do
    if not ALLOWED_FIELDS[field] then
      return false, "rule " .. index .. " has unknown field '" .. tostring(field) .. "'"
    end
  end

  if type(rule.prompt) ~= "string" then
    return false, "rule " .. index .. " prompt must be a string"
  end

  local has_matcher = false
  for _, field in ipairs(MATCH_FIELDS) do
    local pattern = rule[field]
    if pattern ~= nil then
      has_matcher = true
      if type(pattern) ~= "string" then
        return false, "rule " .. index .. " " .. field .. " must be a string"
      end

      local valid_pattern, pattern_error = pcall(string.find, "", pattern)
      if not valid_pattern then
        return false, "rule " .. index .. " " .. field .. " has an invalid Lua pattern: " .. tostring(pattern_error)
      end
    end
  end

  if not has_matcher then
    return false, "rule " .. index .. " must include process, class, or title"
  end

  return true
end

local function optional_pattern_matches(pattern, value)
  return pattern == nil or string.find(value, pattern) ~= nil
end

local function rule_matches(rule, context)
  return optional_pattern_matches(rule.process, context.process)
    and optional_pattern_matches(rule.class, context.class)
    and optional_pattern_matches(rule.title, context.title)
end

function M.validate(rules)
  if type(rules) ~= "table" then
    return false, "rules must be a table"
  end

  for index, rule in ipairs(rules) do
    local valid, validation_error = validate_rule(rule, index)
    if not valid then
      return false, validation_error
    end
  end

  return true
end

function M.find_rule(rules, context)
  for _, rule in ipairs(rules) do
    if rule_matches(rule, context) then
      return rule
    end
  end

  return nil
end

return M
