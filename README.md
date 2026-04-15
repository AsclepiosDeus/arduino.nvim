# arduino.nvim

A lightweight, zero-configuration Neovim integration for the **arduino-cli**. This plugin provides seamless board detection, persistent configuration through TOML files, and streamlined commands for compiling and uploading sketches directly from your editor.

## Features

  - **Zero-Config Startup**: Automatically loads commands and detection logic via the `plugin/` directory.
  - **Persistent Configuration**: Saves board settings in a local `arduino.toml` file, enabling offline compilation without the board being connected.
  - **Dynamic Port Mapping**: Refreshes the USB port dynamically before each upload to handle device reassignments (e.g., from `/dev/ttyACM0` to `/dev/ttyACM1`).
  - **Minimalist Design**: Written in pure Lua with no external plugin dependencies.

## Prerequisites

  - **arduino-cli**: Must be installed and available in your system's `$PATH`.
      - *Arch Linux*: `paru -S arduino-cli`
  - **Permissions**: Your user must belong to the appropriate group for serial port access (e.g., `uucp` on Arch Linux or `dialout` on Debian/Ubuntu).

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'asclepiosdeus/arduino.nvim'
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ 'asclepiosdeus/arduino.nvim' }
```

*Note: No `setup()` function is required. The plugin initializes automatically.*

## Workflow

### Initial Setup

1.  Connect your Arduino board via USB.
2.  Open the main `.ino` file of your project.
3.  The plugin will automatically detect the board and generate an `arduino.toml` in the project directory.
4.  Run `:ArduinoCoreInstall` to download the necessary platform cores/drivers.

### Development Cycle

  - **Compilation**: Use `:ArduinoCompile`. This utilizes the FQBN stored in the TOML file. The board does not need to be connected.
  - **Uploading**: Connect the board and use `:ArduinoUpload`. The plugin scans for the active port immediately before uploading.

## Commands

| Command | Description |
| :--- | :--- |
| `ArduinoCompile` | Compiles the current sketch using the saved FQBN. |
| `ArduinoUpload` | Scans for the board and uploads the compiled binary. |
| `ArduinoCoreInstall` | Installs the core platform associated with the detected board. |

## Configuration File (`arduino.toml`)

The plugin generates this file in your project root to manage persistence. You can manually edit it to change targets without reconnecting hardware.

```toml
[board]
core = "arduino:avr"
fqnb = "arduino:avr:uno"
port = "/dev/ttyACM0"
```

## Internal Architecture

The plugin is split into two parts:

1.  **`lua/arduino_commands.lua`**: Contains the core logic and functions.
2.  **`plugin/arduino.lua`**: Handles the automatic creation of commands and autocommands on startup, ensuring a "plug-and-play" experience.

## Acknowledgments

- **Development Support**: This plugin's documentation, code structure, and README were refined using AI assistance (ChatGPT, Gemini, and Claude).
- **Inspiration**: Built for the Neovim community to simplify Arduino development on Linux.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
