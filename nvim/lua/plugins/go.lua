return {
  "ray-x/go.nvim",
  dependencies = { -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("go").setup()
  end,
  event = { "CmdlineEnter" },
  ft = { "go", "gomod" },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries

  -- command	Description
  -- GoTestFunc	run test for current func
  -- GoTestFunc -s	select the test function you want to run
  -- GoTestFunc -tags=yourtag	run test for current func with -tags yourtag option
  -- GoTestFile	run test for current file
  -- GoTestFile -tags=yourtag	run test for current folder with -tags yourtag option
  -- GoTestPkg	run test for current package/folder
  -- GoTestPkg -tags=yourtag	run test for current folder with -tags yourtag option
  -- GoAddTest [-parallel]	Add test for current func
  -- GoAddExpTest [-parallel]	Add tests for exported funcs
  -- GoAddAllTest [-parallel]	Add tests for all funcs
}
