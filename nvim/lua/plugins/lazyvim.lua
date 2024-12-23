-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
--if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

-- 플러그인 완전 삭제시  ~/.local/share/nvim/lazy/ 플러그인 삭제

return {
  { import = "lazyvim.plugins.extras.ui.mini-starter" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lsp.none-ls" }, -- null-ls 를 대체(메시지에 null-ls 로 표시된다)
}
