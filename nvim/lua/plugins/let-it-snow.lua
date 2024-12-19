-- https://github.com/marcussimonsen/let-it-snow.nvim
return {
  {
    "marcussimonsen/let-it-snow.nvim",
    cmd = "LetItSnow", -- Wait with loading until command is run
    opts = {
      {
        ---@type integer Delay between updates
        delay = 300,
        ---@type string Single character used to represent snowflakes
        snowflake_char = "\u{2744}",
        ---@type string[] Array of single character used to represent snow (in order of least to most)
        snowpile_chars = {
          [1] = "\u{2581}",
          [2] = "\u{2582}",
          [3] = "\u{2583}",
          [4] = "\u{2584}",
          [5] = "\u{2585}",
          [6] = "\u{2586}",
          [7] = "\u{2587}",
          [8] = "\u{2588}",
        },
        ---@type integer Max attempts at spawning a snowfile
        max_spawn_attempts = 500,
        ---@type boolean Whether to create highlight groups or not
        create_highlight_groups = true,
        ---@type string Name of namespace to use for extmarks (you probably don't need to change this)
        namespace = "let-it-snow",
        ---@type string Name of highlight group to use for snowflakes
        highlight_group_name_snowflake = "snowflake",
        ---@type string Name of highlight group to use for snowpiles
        highlight_group_name_snowpile = "snowpile",
      },
    },
  },
}
