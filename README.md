## `test-it.nvim`

A lightweight, modern Neovim plugin written in Lua to run JavaScript and TypeScript tests directly from your editor. It automatically detects your test runner and provides a dedicated terminal buffer for real-time logs, preserving ANSI colors and handling auto-scroll out of the box.

---

### ## Features

* **Auto-Detection:** Automatically identifies if your project uses **Jest**, **Vitest**, or **Mocha** by scanning your `package.json`.
* **Context-Aware Testing:** Uses Treesitter to find the nearest `describe`, `it`, or `test` block and runs only that specific suite.
* **Asynchronous Execution:** Runs tests in the background using Neovim's `jobstart` API—no UI freezes.
* **ANSI Color Support:** Full support for colored output (pass/fail/diffs).

---

### ## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "hxsggsz/test-it.nvim",
  ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  config = function()
    require("test-it").setup({
        -- runner = "jest" -- Optional: override auto-detection ("jest", "vitest", or "mocha")
    })
  end,
}
```

---

### ## Default Keymaps

The following keymaps are set up automatically when you call `.setup()`:

| Keymap | Action |
| :--- | :--- |
| `<leader>ta` | Run all tests in the project |
| `<leader>tf` | Run tests for the current file only |
| `<leader>td` | Run the nearest `describe` block |
| `<leader>ti` | Run the nearest `it` block |
| `<leader>tt` | Run the nearest `test` block |
| `q` | Close the test results window (when inside the test buffer) |

---

### ## Requirements

* **Neovim 0.9+**
* **Treesitter** parsers for `javascript` or `typescript` (`:TSInstall javascript`)
* A test runner installed in your project (accessible via `npx`)

---

### ## Configuration

You can pass a preferred runner to the setup function if you want to bypass auto-detection:

```lua
require("test-it").setup({
    runner = "vitest"
})
```

Would you like me to help you add a "Status Line" integration so you can see if tests passed or failed directly in your Lualine?
