return {
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- Ensure it loads first
  enabled = true,
  config = function()
    -- calling `setup` is optional for customization
    require("onedarkpro").setup({
      options = {
        cursorline = true,
        -- transparency = true, // 투명하게 하면 배경이 검은색이 된다.
      },
      -- :OneDarkProColors 로 설정된 컬러 확인
      colors = {
        cursorline = "#003f00", -- Replace with your desired color
      },
    })
  end,
}
