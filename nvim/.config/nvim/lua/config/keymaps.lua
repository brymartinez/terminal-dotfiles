-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

require("config.http")

vim.keymap.set("n", "<leader>hl", "<cmd>HttpLast<cr>", { desc = "HTTP Last Response" })
vim.keymap.set("n", "<leader>hf", "<cmd>JqFilter<cr>", { desc = "HTTP jq Filter" })
vim.keymap.set("n", "<leader>hr", "<cmd>JqRepeat<cr>", { desc = "HTTP jq Repeat" })

vim.keymap.set("n", "<leader>gq", "<cmd>lua Snacks.picker.git_diff()<cr>", { desc = "Find Git Hunks" })
