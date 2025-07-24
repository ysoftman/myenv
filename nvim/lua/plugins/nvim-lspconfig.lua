return {
  {
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
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
            -- compile_commands.json 설정이 없을때 다음을 사용
            -- .cpp 일때
            fallbackFlags = { "-std=c++23" }, -- optional fallback if compile_commands.json missing
            -- .c 일때
            -- fallbackFlags = { "-std=gnu11" }, -- optional fallback if compile_commands.json missing
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        -- helm_ls 는 mason-lspconfig 에서 관리되는 패키지다.
        -- helm_ls 에서 yamlls 를 통합하고 있다.
        helm_ls = {
          on_attach = function(client, bufnr)
            vim.bo[bufnr].tabstop = 2
            vim.bo[bufnr].shiftwidth = 2
            vim.bo[bufnr].expandtab = true
          end,
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
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            -- helm template 등에서는 yaml 검증과 안 맞는 경우가 있어 비활성화
            -- *.yaml.tpl 파일에서 validate 비활성화
            -- */temlates?/*.ya?ml 파일에서 validate 비활성화
            -- Lua에서 string.match, string.gmatch, string.gsub 등에서 사용하는 정규식은 우리가 흔히 말하는 일반 정규표현식(Perl-style regex)과 다릅니다.
            -- ex) 실제 . 문자 매칭lua:	%.	perl-style: \.
            -- :messages 로 print출력 확인
            -- print("[yamlls].............", "ysoftman helm_ls debugging", bufname)
            if bufname:match("%.yaml%.tpl$") or bufname:match(".*/templates?/.*%.ya?ml.*") then
              client.stop()
              vim.notify("[yamlls] " .. bufname .. "\n파일에 대해 비활성화합니다.", vim.log.levels.INFO)
              return
            end
          end,
        },
        zls = {
          cmd = {
            "zls", -- zig language server
          },
          filetypes = { "zig" },
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
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {
          enabled = false,
        },
        ts_ls = {
          enabled = false,
        },
        -- vtsls(Visualstudio TypeScript Language Server)
        vtsls = {
          -- explicitly add default filetypes, so that we can extend
          -- them in related extras
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                maxInlayHintLength = 30,
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
          on_attach = function(client, bufnr)
            -- inlay_hint, 버퍼 열때 기본은 힌트 보이지 않기, lsp 구동후에 동작해야해서 on_attach() 내에서 설정
            -- LSP가 붙은 상태에서만 동작하도록 체크
            if vim.lsp.inlay_hint ~= nil then
              -- <leader> > u > h 로 힌트 토글
              vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
              local filename = vim.api.nvim_buf_get_name(bufnr)
              -- 파일 이름만 추출 (경로에서 파일명만)
              local basename = vim.fn.fnamemodify(filename, ":t")
              vim.notify(
                "[vtsls] 현재 파일(" .. basename .. ")에 대해 inlay hint 비활성화합니다.",
                vim.log.levels.INFO
              )
              -- 확인시 :lua print(vim.lsp.inlay_hint.is_enabled())
            end
          end,
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      setup = {
        -- example to setup with typescript.nvim
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,

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
}
