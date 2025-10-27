return {
  "nvim-neo-tree/neo-tree.nvim",
  -- LazyVim은 플러그인이 로드될 때 이 opts 테이블을 자동으로 setup() 함수에 인수로 전달합니다.
  opts = {
    close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
    enable_git_status = true,
    enable_diagnostics = true,
    filesystem = {
      filtered_items = {
        visible = false, -- when true, they will just be displayed differently than normal items
        hide_dotfiles = true,
        hide_gitignored = true,
        hide_ignored = true, -- hide files that are ignored by other gitignore-like files
        -- other gitignore-like files, in descending order of precedence.
        ignore_files = {
          ".neotreeignore",
          ".ignore",
          -- ".rgignore"
        },
        hide_hidden = true, -- only works on Windows for hidden files/directories
        hide_by_name = {
          --"node_modules"
        },
        hide_by_pattern = { -- uses glob style patterns
          --"*.meta",
          --"*/src/*/tsconfig.json",
        },
        always_show = { -- remains visible even if other settings would normally hide it
          --".gitignored",
        },
        always_show_by_pattern = { -- uses glob style patterns
          --".env*",
        },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          --".DS_Store",
          --"thumbs.db"
        },
        never_show_by_pattern = { -- uses glob style patterns
          --".null-ls_*",
        },
      },
      follow_current_file = {
        enabled = true, -- This will find and focus the file in the active buffer every time
        --               -- the current file is changed while the tree is open.
        leave_dirs_open = true, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
      },
    },
    buffers = {
      follow_current_file = {
        enabled = true, -- This will find and focus the file in the active buffer every time
        --              -- the current file is changed while the tree is open.
        leave_dirs_open = true, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
      },
    },
    window = {
      mappings = {
        -- C-f 겹쳐서 비활성화(대소문자 구분)
        ["<C-f>"] = "",
        ["<C-b>"] = "",
      },
    },
  },
  -- LazyVim에서 plugin의 config 함수는 플러그인이 로드된 직후에 실행되는 Lua 함수입니다.
  -- config 함수에 opts 파레메터-> setup(opts)를 명시적으로 넘겨주지 않으면 플러그인 기본 설정으로 로드 됩니다.
  -- config = function()
  --   require("neo-tree").setup({
  --     window = {
  --       mappings = {
  --         -- C-f 겹쳐서 비활성화(대소문자 구분)
  --         ["<C-f>"] = "",
  --         ["<C-b>"] = "",
  --       },
  --     },
  --   })
  -- end,
}
