return {
  {
    "neovim/nvim-lspconfig",
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    ensure_installed = { "bashls" },
    opts = {
      servers = {
        taplo = {
          enabled = true,
          settings = {
            evenBetterToml = {
              -- .air.toml 에서 diagnostics 에러가 발생해 비활성화
              schema = { enabled = false },
              formatter = {
                indentString = "  ",
              },
            },
          },
        },

        pyright = {},
        marksman = {},
        clangd = {
          -- Use of undeclared identifier 등의 에러 발생시 다음 명령으로 compile_commands.json 생성
          -- cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
          -- docker 빌드환경등으로 host 경로와 맞지 않는다면 다음 예시와 같이 compile_commands.json 내용중 경로를 수정하자.
          -- sed -i '' \
          -- -e "s#/myproject#$/Users/ysoftman/myproject#g" \
          -- -e "s#/myproject_lib#$/Users/ysoftman/myproject_lib#g" \
          -- compile_commands.json
          keys = {
            { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              ".clangd",
              ".clang-tidy",
              ".clang-format",
              "compile_commands.json",
              "compile_flags.txt",
              "configure.ac",
              "Makefile",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
          end,
          capabilities = {
            offsetEncoding = { "utf-8", "utf-16" },
          },
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
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
            fallbackFlags = { "-std=c++17" },
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
              -- 현재 버퍼 파일 타임을 helm 으로 설정
              -- vim.bo.filetype = "helm"
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
                unreachable = true,
                unusedvariable = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
                -- gopls 0.18 부터 modernize 기능 추가
                -- https://github.com/golang/tools/releases/tag/gopls%2Fv0.18.0
                -- https://github.com/golang/tools/blob/739a5af40476496b626dc23e996357a7dff4e3e8/gopls/internal/analysis/modernize/doc.go
                -- 최신 버전 설치
                -- :MasonInstall gopls
                modernize = true,
                QF1008 = false, -- remove embedded field suggestion
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
