return {
  -- https://github.com/saghen/blink.cmp
  "saghen/blink.cmp",
  optional = true,
  opts = function(_, opts)
    opts.keymap = opts.keymap or {}
    -- 자동 완성 항목 선택 이동시 디폴트 ctrl-p, ctrl-n 이 zellij 단축키와 겹쳐 tab, s-tab 을 추가
    opts.keymap["<Tab>"] = { "select_next", "fallback" }
    opts.keymap["<S-Tab>"] = { "select_prev", "fallback" }
  end,
}
