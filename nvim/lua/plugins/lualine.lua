-- https://github.com/kepano/flexoki
local red = "#AF3029"
local orange = "#BC5215"
local yellow = "#AD8301"
local green = "#66800B"
local cyan = "#24837B"
local blue = "#205EA6"
local purple = "#5E409D"
local magenta = "#A02F6F"

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
    opts.options.section_separators = { left = "", right = "" }
    opts.options.component_separators = { left = "", right = "" }
    -- section 은 a,b,c,x,y,z 6개만 된다. https://github.com/nvim-lualine/lualine.nvim?tab=readme-ov-file#usage-and-customization
    -- section 내 component(lua table) 를 추가하는 방식을 사용하자.
    -- lualine_x 1번째로 추가
    table.insert(opts.sections.lualine_x, 1, {
      function()
        return "🍀"
      end,
      color = function()
        return { bg = "", gui = "bold" }
      end,
      separator = { left = "", right = "" },
    })
    table.insert(opts.sections.lualine_x, 1, {
      function()
        return vim.wo.spell and "SPELL" or "NOSPELL"
      end,
      color = function()
        return { bg = purple }
      end,
      separator = { left = "", right = "" },
    })
    table.insert(opts.sections.lualine_x, 1, {
      "filetype",
      color = function()
        return { bg = cyan }
      end,
      separator = { left = "", right = "" },
    })
    table.insert(opts.sections.lualine_x, 1, {
      get_file_permissions,
      color = function()
        return { bg = blue }
      end,
      separator = { left = "", right = "" },
    })
    -- printTable(opts.sections.lualine_x)
  end,
}
