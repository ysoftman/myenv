-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Cargo.lock 은 cargo 가 자기 형식으로 다시 쓰므로 taplo 자동 포맷을 끈다.
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "Cargo.lock",
  callback = function()
    vim.b.autoformat = false
  end,
})
