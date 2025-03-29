return {
  {
    "tpope/vim-abolish",
    event = "BufRead", -- Load plugin lazily on buffer read
    config = function()
      -- :h  abolish
      -- crc:       camelCase
      -- crp:       PascalCase
      -- crm:       MixedCase (aka PascalCase)
      -- cr_:       snake_case
      -- crs:       snake_case
      -- cru:       SNAKE_UPPERCASE
      -- crU:       SNAKE_UPPERCASE
      -- crk:       kebab-case (not usually reversible; see |abolish-coercion-reversible|)
      -- cr-:       dash-case (aka kebab-case)
      -- cr.:       dot.case (not usually reversible; see |abolish-coercion-reversible|)

      -- Optional: Add custom configurations or mappings here
      vim.cmd([[
        " Example usage of Abolish
        :Abolish foo bar baz
      ]])
    end,
  },
}
