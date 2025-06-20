local black = "#000000"
local white = "#cccccc"

-- https://github.com/kepano/flexoki
-- local red = "#AF3029"
-- local orange = "#BC5215"
-- local yellow = "#AD8301"
-- local green = "#66800B"
-- local cyan = "#24837B"
-- local blue = "#205EA6"
-- local purple = "#5E409D"
-- local magenta = "#A02F6F"

-- https://github.com/joshdick/onedark.vim
local blue = "#61AFEF"
local cyan = "#56B6C2"
local green = "#98C379"
local purple = "#C678DD"
local red = "#E06C75"
local yellow = "#E5C07B"

-- for debug
local function printTable(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(k .. " = {")
      printTable(v)
      print("}")
    else
      print(k .. " = " .. tostring(v))
    end
  end
end

local function get_file_permissions()
  local filepath = vim.fn.expand("%:p") -- Get the full path of the current file
  local permissions = vim.fn.getfperm(filepath) -- Get file permissions
  return permissions ~= "" and permissions or "No Permissions" -- Return permissions or a default message
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = function(_, opts)
    -- opts.options.refresh_interval = 100
    opts.options.section_separators = { left = "", right = "" }
    opts.options.component_separators = { left = "", right = "" }
    -- section 은 a,b,c,x,y,z 로 고정. https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#usage-and-customization
    -- section 내 component(lua table) 를 추가하는 방식을 사용하자.
    -- lualine_x 1번째로 추가
    table.insert(opts.sections.lualine_x, 1, {
      "filetype",
      color = function()
        return { bg = black, fg = yellow }
      end,
      separator = { left = "", right = "" },
    })
    -- 아이콘 참조: https://www.nerdfonts.com/cheat-sheet > 검색 > icon 복사
    table.insert(opts.sections.lualine_x, 1, {
      function()
        -- toggle diagnostic: leader > u > d
        return vim.diagnostic.is_enabled() and " " or " "
      end,
      color = function()
        return { bg = "#eba0ac", fg = black }
      end,
      separator = { left = "", right = "" },
    })
    -- vim.lsp.inlay_hint.is_enabled() 가 항상 true 가 되서 사용하지 않는다.
    -- table.insert(opts.sections.lualine_x, 1, {
    --   function()
    --     -- toggle inlay hint: leader > u > h
    --     -- Neovim 0.10 이상 버전에서 사용
    --     print("----------", vim.lsp.inlay_hint.is_enabled())
    --     return vim.lsp.inlay_hint.is_enabled() and "󰰁 " or "󰰂 "
    --   end,
    --   color = function()
    --     return { bg = blue, fg = black }
    --   end,
    --   separator = { left = "", right = "" },
    -- })
    table.insert(opts.sections.lualine_x, 1, {
      function()
        -- toggle autoformat: leader > u > f
        return vim.g.autoformat and "󰉶 " or "󰉶 "
      end,
      color = function()
        return { bg = "#e27333", fg = black }
      end,
      separator = { left = "", right = "" },
    })
    table.insert(opts.sections.lualine_x, 1, {
      function()
        -- toggle autoformat: leader > u > s
        return vim.wo.spell and " " or "󰓆 "
      end,
      color = function()
        return { bg = purple, fg = black }
      end,
      separator = { left = "", right = "" },
    })
    table.insert(opts.sections.lualine_x, 1, {
      "encoding",
      color = function()
        return { bg = green, fg = black }
      end,
      separator = { left = "", right = "" },
    })
    table.insert(opts.sections.lualine_x, 1, {
      get_file_permissions,
      color = function()
        return { bg = cyan, fg = black }
      end,
      separator = { left = "", right = "" },
    })
    -- printTable(opts.sections.lualine_x)
  end,
}
