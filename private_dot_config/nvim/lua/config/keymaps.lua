-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Option/Alt + wheel or PageUp/PageDown scrolls sideways (LazyVim sets nowrap)
map({ "n", "v", "i" }, "<M-ScrollWheelUp>", "<ScrollWheelLeft>")
map({ "n", "v", "i" }, "<M-ScrollWheelDown>", "<ScrollWheelRight>")
map({ "n", "v" }, "<M-PageUp>", "zH")
map({ "n", "v" }, "<M-PageDown>", "zL")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
vim.keymap.set("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
  end, { noremap = true, silent = true, desc = "LSP Code Action" })
