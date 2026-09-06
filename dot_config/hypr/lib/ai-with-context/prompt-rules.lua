local M = {}

local function optional_equals(expected, actual)
  return expected == nil or expected == actual
end

local function optional_contains(expected, actual)
  return expected == nil or (type(expected) == "string" and actual:find(expected, 1, true) ~= nil)
end

local function rule_matches(rule, context)
  return optional_equals(rule.process, context.process)
    and optional_equals(rule.class, context.class)
    and optional_equals(rule.workspace, context.workspace)
    and optional_contains(rule.title_contains, context.title)
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
