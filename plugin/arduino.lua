-- Project: arduino.nvim
-- License: MIT
-- Copyright © 2026 AsclepiosDeus

local arduino = require('arduino_commands')

-- Command to compile the Arduino sketch
vim.api.nvim_create_user_command('ArduinoCompile', function()
  -- Ensure FQBN is detected before compilation
  if not arduino.board_data.fqbn then arduino.board_data_detection() end
  if not arduino.board_data.fqbn or arduino.board_data.fqbn == "" then
    print('Error :: No FQNB detecteds')
    return
  end

  -- Persist settings and run the arduino-cli compile command
  arduino.save_card_data()
  local path = vim.fn.expand('%:p:h')
  vim.cmd('!arduino-cli compile --fqbn ' .. arduino.board_data.fqbn .. ' ' .. path)
end, {})

-- Command to upload the compiled sketch to the board
vim.api.nvim_create_user_command('ArduinoUpload', function()
  -- Refresh port status to handle dynamic USB reassignment
  arduino.read_card_port()

  if not arduino.board_data.port or arduino.board_data.port == "" then
    print('Error :: No cards detecteds')
    return
  end

  -- Persist settings and run the arduino-cli upload command
  arduino.save_card_data()
  local path = vim.fn.expand('%:p:h')
  vim.cmd('!arduino-cli upload -p ' .. arduino.board_data.port .. ' --fqbn ' .. arduino.board_data.fqbn .. ' ' .. path)
end, {})

-- Command to install the necessary core platform for the detected board
vim.api.nvim_create_user_command('ArduinoCoreInstall', function()
  if arduino.board_data.core == nil then   arduino.board_data_detection() end
  if arduino.board_data.core == nil then
    print('Error :: No cards detecteds')
    return
  else arduino.save_card_data() end

  -- Run the arduino-cli core install command
  vim.cmd('!arduino-cli core install ' .. arduino.board_data.core)

end, {})


vim.api.nvim_create_user_command('ArduinoCoreUninstall', function()
  if arduino.board_data.core == nil then   arduino.board_data_detection() end
  if arduino.board_data.core == nil then
    print('Error :: No cards detecteds')
    return
  else arduino.save_card_data() end

  -- Run the arduino-cli core install command
  vim.cmd('!arduino-cli core uninstall ' .. arduino.board_data.core)

end, {})


vim.api.nvim_create_user_command('ArduinoRemote', function()
  arduino.read_card_port()
  local path = vim.fn.expand('%:p')

  local lines = vim.fn.readfile(path)
  for _, line in ipairs(lines) do
     local baud = line:match('Serial%.begin%s*%(%s*(%d+)%s*%)')
  end
  if baud then
    baud = arduino.board_data.baudrate
  end
  vim.cmd('split | terminal arduino-cli monitor -p ' .. arduino.board_data.port .. ' --config baudrate=' .. arduino.board_data.baudrate)
end, {})
