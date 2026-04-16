-- Project: arduino.nvim
-- License: MIT
-- Copyright © 2026 AsclepiosDeus

local arduino = require('arduino_commands')

-- Command to compile the Arduino sketch
vim.api.nvim_create_user_command('ArduinoCompile', function()
  -- Ensure FQBN is detected before compilation
  if not arduino.board_data.fqnb then arduino.board_data_detection() end
  if not arduino.board_data.fqnb or arduino.board_data.fqnb == "" then
    print('Error: No FQBN founds')
    return
  end

  -- Persist settings and run the arduino-cli compile command
  arduino.save_card_data()
  local path = vim.fn.expand('%:p:h')
  vim.cmd('!arduino-cli compile --fqbn ' .. arduino.board_data.fqnb .. ' ' .. path)
end, {})

-- Command to upload the compiled sketch to the board
vim.api.nvim_create_user_command('ArduinoUpload', function()
  -- Refresh port status to handle dynamic USB reassignment
  arduino.board_data_detection() 

  if not arduino.board_data.port or arduino.board_data.port == "" then
    print('Error: Board not found')
    return
  end

  -- Persist settings and run the arduino-cli upload command
  arduino.save_card_data()
  local path = vim.fn.expand('%:p:h')
  vim.cmd('!arduino-cli upload -p ' .. arduino.board_data.port .. ' --fqbn ' .. arduino.board_data.fqnb .. ' ' .. path)
end, {})

-- Command to install the necessary core platform for the detected board
vim.api.nvim_create_user_command('ArduinoCoreInstall', function()
  if arduino.board_data.fqnb == nil then   arduino.board_data_detection() end
  if arduino.board_data.fqnb == nil then
    print('Error :: No cards detecteds')
    return
  else arduino.save_card_data() end

  -- Run the arduino-cli core install command
  vim.cmd('!arduino-cli core install ' .. arduino.board_data.core)

end, {})
