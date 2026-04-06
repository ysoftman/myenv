return {
  -- LazyVim 기본 탑재, nvim 내장 gc operator의 commentstring 개선
  -- 자체 키맵 없이 nvim 0.10+ 내장 comment operator 사용:
  --   gcc        : 현재 줄 주석 토글
  --   gc{motion} : motion 범위 주석 토글 (gcip=문단, gc3j=3줄)
  --   gc         : (visual) 선택 영역 주석 토글
  --   gco        : 아래에 주석 줄 삽입
  --   gcO        : 위에 주석 줄 삽입
  "folke/ts-comments.nvim",
  event = "VeryLazy",
  opts = {},
}
