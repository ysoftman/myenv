return {
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons", { "junegunn/fzf", build = "./install --bin" } },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({
        winopts = {
          preview = {
            -- default     = 'bat',           -- override the default previewer?
            -- default uses the 'builtin' previewer
            border = "border", -- border|noborder, applies only to
            -- native fzf previewers (bat/cat/git/etc)
            wrap = "nowrap", -- wrap|nowrap
            hidden = "nohidden", -- hidden|nohidden
            vertical = "down:45%", -- up|down:size
            horizontal = "right:60%", -- right|left:size
            layout = "vertical", -- horizontal|vertical|flex
            flip_columns = 100, -- #cols to switch to horizontal on flex
            -- Only used with the builtin previewer:
            title = true, -- preview border title (file/buf)?
            title_pos = "center", -- left|center|right, title alignment
            scrollbar = "float", -- `false` or string:'float|border'
            -- float:  in-window floating border
            -- border: in-border chars (see below)
            scrolloff = "-2", -- float scrollbar offset from right
            -- applies only when scrollbar = 'float'
            scrollchars = { "█", "" }, -- scrollbar chars ({ <full>, <empty> }
            -- applies only when scrollbar = 'border'
            delay = 100, -- delay(ms) displaying the preview
            -- prevents lag on fast scrolling
            winopts = { -- builtin previewer window options
              number = true,
              relativenumber = false,
              cursorline = true,
              cursorlineopt = "both",
              cursorcolumn = false,
              signcolumn = "no",
              list = false,
              foldenable = false,
              foldmethod = "manual",
            },
          },
        },
        actions = {
          -- Below are the default actions, setting any value in these tables will override
          -- the defaults, to inherit from the defaults change [1] from `false` to `true`
          files = {
            true, -- do not inherit from defaults
            -- Pickers inheriting these actions:
            --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
            --   tags, btags, args, buffers, tabs, lines, blines
            -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
            -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
            -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
            -- ["enter"] = actions.file_edit_or_qf,
            ["enter"] = require("fzf-lua.actions").file_edit,
            ["ctrl-s"] = require("fzf-lua.actions").file_split,
            ["ctrl-v"] = require("fzf-lua.actions").file_vsplit,
            ["ctrl-t"] = require("fzf-lua.actions").file_tabedit,
            ["alt-q"] = require("fzf-lua.actions").file_sel_to_qf,
            ["alt-Q"] = require("fzf-lua.actions").file_sel_to_ll,
          },
        },
        fzf_opts = {
          -- options are sent as `<left>=<right>`
          -- set to `false` to remove a flag
          -- set to `true` for a no-value flag
          -- for raw args use `fzf_args` instead
          ["--ansi"] = true,
          ["--info"] = "inline-right", -- fzf < v0.42 = "inline"
          ["--height"] = "100%",
          ["--layout"] = "reverse",
          ["--border"] = "none",
          ["--highlight-line"] = true, -- fzf >= v0.53
        },
      })
    end,
  },
}
