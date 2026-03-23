-- 터미널 모드에서 윈도우 이동을 처리하는 함수 정의
local function term_nav(dir)
  return function()
    return [[<C-\><C-N><C-w>]] .. dir
  end
end

return {
  "snacks.nvim",
  opts = {
    bigfile = {
      enabled = true,
      -- 원하는 파일 크기 설정 (단위: Bytes)
      size = 500 * 1024 * 1024,

      -- 한 줄의 길이가 너무 길 때도 bigfile로 처리 (Minified JS 파일 등 방지)
      line_length = 1000,

      -- 큰 파일 감지 시 알림 여부
      notify = true,
    },
    quickfile = { enabled = true },
    terminal = {
      win = {
        -- 터미널 모드에서 <C-w>h/j/k/l 로 포커스 이동
        -- <C-w>H/J/K/L (대문자) 창 위치 이동
        -- <C-w>+/-/>/< 창 크기 조절
        keys = {
          nav_h = { "<C-w>h", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_j = { "<C-w>j", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_k = { "<C-w>k", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_l = { "<C-w>l", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        },
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
  },
}
