-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
--if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

local telescope_actions = require("telescope.actions")
local telescope_action_state = require("telescope.actions.state")
local function telescope_multiopen(pb)
  local picker = telescope_action_state.get_current_picker(pb)
  local multi = picker:get_multi_selection()
  telescope_actions.select_default(pb) -- the normal enter behaviour
  for _, j in pairs(multi) do
    if j.path ~= nil then -- is it a file -> open it as well:
      vim.cmd(string.format("%s %s", "edit", j.path))
    end
  end
end

return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        indicator = {
          -- icon = "▎", -- style =  "icon"일때
          icon = "✓",
          -- style = "underline",
          style = "icon",
        },
      },
    },
    keys = {
      { "<S-h>", false },
      { "<S-l>", false },
    },
  },

  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  { "folke/trouble.nvim", enabled = true },

  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },

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

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    },
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
    },
    -- change some options
    opts = {
      defaults = {
        preview = true,
        layout_strategy = "vertical",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        vimgrep_arguments = {
          "rg",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--fixed-strings", -- Treat all patterns as literals instead of as regular expressions. When this flag is used, special regular expression meta characters such as .(){}*+ should not need be escaped.
          -- "--hidden",
          "--smart-case", -- 소문자로만 입력시 대소문자 구분하지 않음, 아니면 대소문자 구분
          -- Add your custom rg options here
        },
        mappings = {
          i = {
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<cr>"] = telescope_multiopen,
          },
        },
      },
    },
  },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
    opts = {
      {
        ---Add a space b/w comment and the line
        padding = true,
        ---Whether the cursor should stay at its position
        sticky = true,
        ---Lines to be ignored while (un)comment
        ignore = nil,
        ---LHS of toggle mappings in NORMAL mode
        toggler = {
          ---Line-comment toggle keymap
          -- line = 'gcc',
          -- <leader>cc  는codelens 로 사용되고 있음
          ---Block-comment toggle keymap
          block = "gbc",
        },
        ---LHS of operator-pending mappings in NORMAL and VISUAL mode
        opleader = {
          ---Line-comment keymap
          line = "gc",
          ---Block-comment keymap
          block = "gb",
        },
        ---LHS of extra mappings
        extra = {
          ---Add comment on the line above
          above = "gcO",
          ---Add comment on the line below
          below = "gco",
          ---Add comment at the end of line
          eol = "gcA",
        },
        ---Enable keybindings
        ---NOTE: If given `false` then the plugin won't create any mappings
        mappings = {
          ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
          basic = true,
          ---Extra mapping; `gco`, `gcO`, `gcA`
          extra = true,
        },
        ---Function to call before (un)comment
        pre_hook = nil,
        ---Function to call after (un)comment
        post_hook = nil,
      },
    },
  },

  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    --- @class PluginLspOpts
    opts = {
      --- @type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = false, -- 변수 할당시 타입 표시 비활성화
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = false, -- 파라메터 이름가지 표시되면 가독성이 떨어져 비활성화
                rangeVariableTypes = false, -- range 변수 타입 표시되면 가독성이 떨어저 비활성화
              },
              analyses = {
                fieldalignment = false, -- 효율적인 메모리 공간을 위해 struct 멤버 순서를 제안한다.
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true, -- https://staticcheck.dev/docs/checks#QF1003
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
      },
      setup = {
        gopls = function(_, opts)
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          LazyVim.lsp.on_attach(function(client, _)
            if not client.server_capabilities.semanticTokensProvider then
              local semantic = client.config.capabilities.textDocument.semanticTokens
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end, "gopls")
          -- end workaround
        end,
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {},
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "goimports", "gofumpt" } },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "gomodifytags", "impl" } },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "delve" } },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "black",
        "prettier",
      },
      formatters_by_ft = {
        ["html"] = { "prettier" },
        ["lua"] = { "stylua" },
        ["py"] = { "black" },
      },
    },
  },
  {
    "echasnovski/mini.icons",
    opts = {
      file = {
        [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
      },
      filetype = {
        gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
      },
    },
  },

  { import = "lazyvim.plugins.extras.lang.typescript" },

  {
    "nvim-neo-tree/neo-tree.nvim",
    -- LazyVim에서 plugin의 config 함수는 플러그인이 로드될 때 자동으로 실행
    config = function()
      require("neo-tree").setup({
        window = {
          mappings = {
            -- c-f 겹쳐서 비활성화
            ["<c-f>"] = "none",
          },
        },
        filesystem = {
          window = {
            mappings = {
              -- c-f 겹쳐서 비활성화
              ["<c-f>"] = "none",
            },
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    -- opts 속성을 사용하면 LazyVim이 자동으로 config 함수를 생성
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "go",
        "gomod",
        "gosum",
        "gowork",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, "😄")
    end,
  },

  { import = "lazyvim.plugins.extras.ui.mini-starter" },

  { import = "lazyvim.plugins.extras.lang.json" },

  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
