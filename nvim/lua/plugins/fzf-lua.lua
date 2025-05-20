return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons", { "junegunn/fzf", build = "./install --bin" } },
  config = function()
    -- calling `setup` is optional for customization
    local actions = require("fzf-lua.actions")
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
          ["enter"] = actions.file_edit_or_qf,
          ["ctrl-s"] = actions.file_split,
          ["ctrl-v"] = actions.file_vsplit,
          ["ctrl-t"] = actions.file_tabedit,
          ["alt-q"] = actions.file_sel_to_qf,
          ["alt-Q"] = actions.file_sel_to_ll,
          ["alt-i"] = { actions.toggle_ignore },
          -- ["alt-h"] = { actions.toggle_hidden }, -- zellij 키와 겹칩
          ["alt-d"] = { actions.toggle_hidden },
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
      files = {
        -- previewer      = "bat",          -- uncomment to override previewer
        -- (name from 'previewers' table)
        -- set to 'false' to disable
        prompt = "Files❯ ",
        multiprocess = true, -- run command in a separate process
        git_icons = true, -- show git icons?
        file_icons = true, -- show file icons (true|"devicons"|"mini")?
        color_icons = true, -- colorize file|git icons
        -- path_shorten   = 1,              -- 'true' or number, shorten path?
        -- Uncomment for custom vscode-like formatter where the filename is first:
        -- e.g. "fzf-lua/previewer/fzf.lua" => "fzf.lua previewer/fzf-lua"
        -- formatter      = "path.filename_first",
        -- executed command priority is 'cmd' (if exists)
        -- otherwise auto-detect prioritizes `fd`:`rg`:`find`
        -- default options are controlled by 'fd|rg|find|_opts'
        -- fzf 내부적으로 rg -> grep 순으로 명령을 찾아 실행한다.
        -- NOTE: 'find -printf' requires GNU find
        -- cmd            = "find . -type f -printf '%P\n'",
        find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
        rg_opts = [[--color=never --files --hidden --follow -g "!.git"]],
        fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
        -- by default, cwd appears in the header only if {opts} contain a cwd
        -- parameter to a different folder than the current working directory
        -- uncomment if you wish to force display of the cwd as part of the
        -- query prompt string (fzf.vim style), header line or both
        -- cwd_header = true,
        cwd_prompt = true,
        cwd_prompt_shorten_len = 32, -- shorten prompt beyond this length
        cwd_prompt_shorten_val = 1, -- shortened path parts length
        toggle_ignore_flag = "--no-ignore", -- flag toggled in `actions.toggle_ignore`
        toggle_hidden_flag = "--hidden", -- flag toggled in `actions.toggle_hidden`
        actions = {
          -- inherits from 'actions.files', here we can override
          -- or set bind to 'false' to disable a default action
          -- action to toggle `--no-ignore`, requires fd or rg installed
          ["ctrl-g"] = { actions.toggle_ignore },
          -- uncomment to override `actions.file_edit_or_qf`
          --   ["enter"]     = actions.file_edit,
          -- custom actions are available too
          --   ["ctrl-y"]    = function(selected) print(selected[1]) end,
        },
      },
      grep = {
        prompt = "Rg❯ ",
        input_prompt = "Grep For❯ ",
        multiprocess = true, -- run command in a separate process
        git_icons = true, -- show git icons?
        file_icons = true, -- show file icons (true|"devicons"|"mini")?
        color_icons = true, -- colorize file|git icons
        -- executed command priority is 'cmd' (if exists)
        -- otherwise auto-detect prioritizes `rg` over `grep`
        -- default options are controlled by 'rg|grep_opts'
        -- fzf 내부적으로 rg -> grep 순으로 명령을 찾아 실행한다.
        -- cmd            = "rg --vimgrep",
        grep_opts = "--binary-files=without-match --line-number --recursive --color=auto --perl-regexp -e",
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        -- Uncomment to use the rg config file `$RIPGREP_CONFIG_PATH`
        -- RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH
        --
        -- Set to 'true' to always parse globs in both 'grep' and 'live_grep'
        -- search strings will be split using the 'glob_separator' and translated
        -- to '--iglob=' arguments, requires 'rg'
        -- can still be used when 'false' by calling 'live_grep_glob' directly
        rg_glob = false, -- default to glob parsing?
        glob_flag = "--iglob", -- for case sensitive globs use '--glob'
        glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
        -- advanced usage: for custom argument parsing define
        -- 'rg_glob_fn' to return a pair:
        --   first returned argument is the new search query
        --   second returned argument are additional rg flags
        -- rg_glob_fn = function(query, opts)
        --   ...
        --   return new_query, flags
        -- end,
        --
        -- Enable with narrow term width, split results to multiple lines
        -- NOTE: multiline requires fzf >= v0.53 and is ignored otherwise
        -- multiline      = 1,      -- Display as: PATH:LINE:COL\nTEXT
        -- multiline      = 2,      -- Display as: PATH:LINE:COL\nTEXT\n
        actions = {
          -- actions inherit from 'actions.files' and merge
          -- this action toggles between 'grep' and 'live_grep'
          ["ctrl-g"] = { actions.grep_lgrep },
          -- uncomment to enable '.gitignore' toggle for grep
          ["ctrl-r"] = { actions.toggle_ignore },
        },
        no_header = false, -- hide grep|cwd header?
        no_header_i = false, -- hide interactive header?
      },
    })
  end,
}
