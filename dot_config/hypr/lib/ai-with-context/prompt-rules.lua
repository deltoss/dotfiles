local M = {}

local function optional_pattern_matches(pattern, value)
  if pattern == nil then
    return true
  end

  if type(pattern) ~= "string" or type(value) ~= "string" then
    return false
  end

  local ok, match = pcall(string.match, value, pattern)
  return ok and match ~= nil
end

local function rule_matches(rule, context)
  return optional_pattern_matches(rule.process, context.process)
    and optional_pattern_matches(rule.class, context.class)
    and optional_pattern_matches(rule.title, context.title)
end

function M.find_prompt(rules, context)
  for _, rule in ipairs(rules) do
    if type(rule) == "table" and type(rule.prompt) == "string" and rule_matches(rule, context) then
      return rule.prompt
    end
  end

  return ""
end

return M
