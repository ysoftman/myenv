return {
  "NvChad/nvim-colorizer.lua",
  event = "BufReadPost", -- Load colorizer when a buffer is read
  opts = {
    filetypes = { "*", "css", "javascript" }, -- Enable for all filetypes
    user_default_options = {
      RGB = true, -- Enable #RGB hex codes
      RRGGBB = true, -- Enable #RRGGBB hex codes
      names = true, -- Enable color names like "Blue" or "Red"
      RRGGBBAA = true, -- Enable #RRGGBBAA hex codes
      AARRGGBB = false, -- Disable 0xAARRGGBB hex codes
      rgb_fn = true, -- Enable CSS rgb() and rgba() functions
      hsl_fn = false, -- Disable CSS hsl() and hsla() functions
      css = true, -- Enable all CSS features (names, RGB, RRGGBB)
      css_fn = true, -- Enable all CSS *functions* (rgb_fn, hsl_fn)
      mode = "background", -- Highlight colors in the background
    },
  },
}
