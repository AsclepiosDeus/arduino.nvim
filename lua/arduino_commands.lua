-- Project: arduino.nvim
-- License: MIT
-- Copyright © 2026 AsclepiosDeus

local M = {}

-- Store active board details: Fully Qualified Board Name (FQBN), Core platform, and Serial Port
M.board_data = { fqbn = nil, core = nil, port = nil, baudrate = nil }

-- Initialize the autocommand group for Arduino-specific events
local arduino_group = vim.api.nvim_create_augroup('arduinoConfig', { clear = true })

-- Save the current board configuration to a local 'arduino.toml' file
function M.save_card_data()
  local path = vim.fn.expand('%:p:h') .. '/arduino.toml'
  local lines = {
    '[board]',
    'core = "' .. (M.board_data.core or "") .. '"',
    'fqbn = "' .. (M.board_data.fqbn or "") .. '"'
  }
  vim.fn.writefile(lines, path)
end

-- Read board configuration from the 'arduino.toml' file if it exists
function M.read_card_data()
  local path = vim.fn.expand('%:p:h') .. '/arduino.toml'
  if vim.fn.filereadable(path) == 0 then return false end

  local lines = vim.fn.readfile(path)
  for _, line in ipairs(lines) do
    -- Use regex to capture key = "value" pairs from the TOML file
    local key, value = line:match('(%w+)%s*=%s*"(.-)"')
    if key and value then
      M.board_data[key] = value
    end
  end
  return true
end


function M.read_card_port()
  local output = vim.fn.system('arduino-cli board list')
  for line in output:gmatch('[^\n]+') do
    if line:match('[%w_]+:[%w_]+:') then
      -- Dynamic port detection: prioritizes the current physical connection
      M.board_data.port = line:match('^(%S+)')
      break
    end
  end
end


-- Detect connected Arduino boards via arduino-cli and merge with saved config
function M.board_data_detection()

  if M.read_card_data() == false then

    -- Query the system for connected boards
    local output = vim.fn.system('arduino-cli board list')
    for line in output:gmatch('[^\n]+') do
      if line:match('[%w_]+:[%w_]+:') then
        -- Fallback: Use USB data only if specific fields are missing in the TOML
        M.board_data.fqbn = M.board_data.fqbn or line:match('([%w_]+:[%w_]+:[%w_]+)')
        M.board_data.core = M.board_data.core or line:match('([%w_]+:[%w_]+)')
        break
      end
    end
  end
end

-- Automatically trigger detection when opening or creating .ino files
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = '*.ino',
  group = arduino_group,
  callback = M.board_data_detection
})

return M
