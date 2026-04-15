-- Project: arduino.nvim
-- License: MIT
-- Copyright © 2026 AsclepiosDeus

local M = {}

-- Store active board details: Fully Qualified Board Name (FQBN), Core platform, and Serial Port
local board_data = { fqnb = nil, core = nil, port = nil }

-- Initialize the autocommand group for Arduino-specific events
local arduino_group = vim.api.nvim_create_augroup('arduinoConfig', { clear = true })

-- Save the current board configuration to a local 'arduino.toml' file
local function save_card_data()
  local path = vim.fn.expand('%:p:h') .. '/arduino.toml'
  local lines = {
    '[board]',
    'core = "' .. (board_data.core or "") .. '"',
    'fqnb = "' .. (board_data.fqnb or "") .. '"',
    'port = "' .. (board_data.port or "") .. '"'
  }
  vim.fn.writefile(lines, path)
end

-- Read board configuration from the 'arduino.toml' file if it exists
local function read_card_data()
  local path = vim.fn.expand('%:p:h') .. '/arduino.toml'
  if vim.fn.filereadable(path) == 0 then return false end

  local lines = vim.fn.readfile(path)
  for _, line in ipairs(lines) do
    -- Use regex to capture key = "value" pairs from the TOML file
    local key, value = line:match('(%w+)%s*=%s*"(.-)"')
    if key and value then
      board_data[key] = value
    end
  end
  return true
end

-- Detect connected Arduino boards via arduino-cli and merge with saved config
local function board_data_detection()
  read_card_data() -- Attempt to load existing settings first

  -- Query the system for connected boards
  local output = vim.fn.system('arduino-cli board list')
  for line in output:gmatch('[^\n]+') do
    if line:match('arduino:') then
      -- Dynamic port detection: prioritizes the current physical connection
      board_data.port = line:match('^(%S+)')

      -- Fallback: Use USB data only if specific fields are missing in the TOML
      board_data.fqnb = board_data.fqnb or line:match('([%w_]+:[%w_]+:[%w_]+)')
      board_data.core = board_data.core or line:match('([%w_]+:[%w_]+)')
      break
    end
  end
end

-- Automatically trigger detection when opening or creating .ino files
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = '*.ino',
  group = arduino_group,
  callback = board_data_detection
})

return M
