local M = {}

local cache_file = (vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")) .. "/http-last.json"
local last_filter

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "HTTP jq" })
end

local function ensure_cache_file()
  if vim.fn.filereadable(cache_file) == 0 then
    notify("No cached HTTP response found at " .. cache_file, vim.log.levels.ERROR)
    return false
  end
  return true
end

local function ensure_jq()
  if vim.fn.executable("jq") ~= 1 then
    notify("jq is not installed or not on PATH", vim.log.levels.ERROR)
    return false
  end
  return true
end

local function open_scratch(title, lines)
  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = "json"
  vim.api.nvim_buf_set_name(buf, title)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function render_filter(filter)
  if not ensure_cache_file() or not ensure_jq() then
    return
  end

  local escaped_filter = vim.fn.shellescape(filter)
  local escaped_file = vim.fn.shellescape(cache_file)
  local command = "jq " .. escaped_filter .. " " .. escaped_file
  local output = vim.fn.systemlist(command)

  if vim.v.shell_error ~= 0 then
    notify(table.concat(output, "\n"), vim.log.levels.ERROR)
    return
  end

  if #output == 0 then
    output = { "" }
  end

  last_filter = filter
  open_scratch("jq://" .. filter, output)
end

function M.open_last()
  if not ensure_cache_file() then
    return
  end
  vim.cmd("edit " .. vim.fn.fnameescape(cache_file))
end

function M.prompt_filter()
  if not ensure_cache_file() or not ensure_jq() then
    return
  end

  vim.ui.input({ prompt = "jq filter: ", default = last_filter or "." }, function(input)
    if not input or input == "" then
      return
    end
    render_filter(input)
  end)
end

function M.repeat_filter()
  if not last_filter then
    notify("No previous jq filter to repeat", vim.log.levels.WARN)
    return
  end
  render_filter(last_filter)
end

function M.setup()
  vim.api.nvim_create_user_command("HttpLast", function()
    M.open_last()
  end, {})

  vim.api.nvim_create_user_command("JqFilter", function()
    M.prompt_filter()
  end, {})

  vim.api.nvim_create_user_command("JqRepeat", function()
    M.repeat_filter()
  end, {})
end

M.setup()

return M
