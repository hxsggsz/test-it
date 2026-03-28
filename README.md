## `test-it.nvim` 🚀

A lightweight, modern Neovim plugin written in Lua to run **Jest** tests directly from your editor. It provides a dedicated terminal buffer for real-time logs, preserving ANSI colors and handling auto-scroll out of the box.

---

### ## Features

* **Asynchronous Execution:** Runs tests in the background using Neovim's `jobstart` API—no UI freezes.
* **Dedicated Terminal Buffer:** Opens a bottom split with a terminal emulator to show Jest output.
* **ANSI Color Support:** Full support for Jest's colored output (pass/fail/diffs).
* **Auto-Scroll:** Automatically follows the test logs as they are generated.
* **Simple Keybindings:** Press `q` to quickly dismiss the test results window.

---

### ## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "hxsggsz/test-it.nvim",
  config = function()
    require("test-it").setup()
  end,
}
```

Or using `packer.nvim`:

```lua
use {
  'hxsggsz/test-it.nvim',
  config = function()
    require('test-it').setup()
  end
}
```

---

### ## Requirements

* **Neovim 0.9+**
* **Jest** installed in your project (accessible via `npx jest`)
* A terminal that supports ANSI colors (like Kitty, Alacritty, or WezTerm)

