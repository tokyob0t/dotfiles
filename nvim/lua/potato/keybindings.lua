local keymap = vim.keymap.set

local cmd = vim.cmd
local opt = { noremap = true, silent = true }

local telescope = require("telescope.builtin")
local unmap = "<Nop>"

--local ufo = require("ufo")

-- leader = <Spacebar>
vim.g.mapleader = " "
cmd.BufferClose = cmd.bdelete
cmd.BufferNext = cmd.bnext
cmd.BufferPrev = cmd.bprev

keymap({ "n", "v" }, "<C-Left>", "b", opt)
keymap({ "n", "v" }, "<C-Right>", "w", opt)
keymap({ "n", "v" }, "<S-Up>", "<Up>", opt)
keymap({ "n", "v", "i" }, "<S-Down>", "<Down>", opt)

-- Ctrl + Backspace = Kill Word
keymap("i", "<C-H>", "<C-W>", opt)

--keymap("n", "<leader>F", ufo.openAllFolds, opt)
--keymap("n", "<leader>f", ufo.closeAllFolds, opt)

-- Fold Code
keymap("v", "fo", ":'<,'> foldopen<CR>", opt)
keymap("v", "fc", ":'<,'> foldclose<CR>", opt)
keymap("v", "f<leader>", ":'<,'> fold<CR>", opt)

keymap("n", "<Esc>", ':let @/ = ""<CR>', opt)
keymap("n", "<leader>e", cmd.NvimTreeToggle, opt)

-- Other
keymap("n", "<leader>i", "o", opt)
keymap("n", "<leader>I", "O", opt)
keymap("n", "<leader>q", ":q<CR>", opt)

-- Buffers
keymap("n", "<leader><Tab>{", cmd.BufferPrev, opt)
keymap("n", "<leader><Tab>}", cmd.BufferNext, opt)
keymap("n", "<leader><Tab>d", cmd.BufferClose, opt)

keymap("n", "<leader><Tab>.", telescope.buffers, opt)
keymap("n", "<leader>.", telescope.find_files, opt)
keymap("n", "<leader>,", telescope.live_grep, opt)

--keymap("n", "<leader>,", telescope.grep_string, opt)

keymap({ "n", "v" }, ";", ":", opt)
keymap({ "n", "v" }, "h", unmap, opt)
keymap({ "n", "v" }, "j", unmap, opt)
keymap({ "n", "v" }, "k", unmap, opt)
keymap({ "n", "v" }, "l", unmap, opt)
