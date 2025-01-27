return {
  {
    "neovim/nvim-lspconfig",
    ensure_installed = { "bashls" },
    opts = {
      servers = {
        pyright = {},
        marksman = {},
        clangd = {
          keys = {
            { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
              fname
            ) or require("lspconfig.util").find_git_ancestor(fname)
          end,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        yamlls = {
          settings = {
            yaml = {
              format = {
                enable = false,
              },
              validate = true,
            },
          },
          on_attach = function(client, bufnr)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            if filename:match("%.yaml%.tpl$") then
              client.server_capabilities.documentFormattingProvider = false
              vim.diagnostic.enable(false, { bufnr = bufnr }) -- *.yaml.tpl 파일에서 validate 비활성화
            end
          end,
        },
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
                QF1008 = false, -- remove embeded field suggestion
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
