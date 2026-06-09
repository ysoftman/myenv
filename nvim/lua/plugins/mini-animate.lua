return {
  "nvim-mini/mini.animate",
  -- 비활성화: paste 등 커서가 한 번에 멀리 점프하는 동작에서 cursor/scroll
  -- 애니메이션이 중간 프레임을 그리느라 버벅이고, 그 사이 입력이 밀려
  -- 오작동한다(붙여넣기 순서가 깨짐). 커서 효과는 smear-cursor 가 담당하므로
  -- mini.animate 는 끈다.
  enabled = false,
  opts = {
    -- cmdheight=0 일때 :res 10 등으로 높이를 줄이면 cmdheight 가 비정상적으로 변경되는 버그 방지
    resize = { enable = false },
  },
}
