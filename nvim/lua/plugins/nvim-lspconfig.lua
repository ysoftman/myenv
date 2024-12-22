return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
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
                compositeLiteralFields = false, --  필드명이 힌트로 보이면 들여쓰기 된것처럼 보여서 비활성화
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
              gofumpt = true,
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
              if semantic == nil then
                return
              end
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
            -- Create an autocommand group for organizing imports
            vim.api.nvim_create_augroup("GoImports", { clear = true })
            -- 저장시 auto import
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = "GoImports",
              pattern = "*.go",
              callback = function()
                vim.lsp.buf.code_action({
                  context = { diagnostics = vim.diagnostic.get(0), only = { "source.organizeImports" } },
                  apply = true,
                })
              end,
            })
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
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {},
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
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
}
