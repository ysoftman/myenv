-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = true

-- config.window_decorations = "NONE" -- 위쪽 제목표시 줄 없애기 윈도우 크기 조정이 안됨
-- config.window_decorations = "RESIZE" -- 위쪽 제목표시 줄 없애기 윈도우 크기 조정이 됨
config.window_decorations = "TITLE | RESIZE" -- 위쪽 제목표시 + 윈도우 크기 조정이 됨

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- config.window_background_opacity = 0.7
-- config.macos_window_background_blur = 80

config.font_size = 18

-- https://wezterm.org/colorschemes/index.html
-- config.color_scheme = "AdventureTime"
config.color_scheme = "Argonaut"

config.colors = {
	-- cursor_bg = "#ff5555", -- 커서 배경
	cursor_bg = "white", -- 커서 배경
	-- cursor_fg를 지정하지 않으면 기본적으로 글자색이 커서색과 섞여서 글씨가 안 보일 수 있다.
	cursor_fg = "#000000", -- 커서 위의 글자색 검정 등 대비색
	-- cursor_border = "#ff5555", -- 커서 테두리색
	cursor_border = "white", -- 커서 테두리색
}

-- 커서 애니메이션 (Neovide 느낌)
config.cursor_blink_rate = 500
-- 깜박임이 즉각적으로 켜졌다 꺼지게 설정
-- config.cursor_blink_ease_in = "Constant"
-- config.cursor_blink_ease_out = "Constant"
-- 점진적인 효과
-- config.cursor_blink_ease_in = "EaseIn"
-- config.cursor_blink_ease_out = "EaseOut"
config.cursor_blink_ease_in = "Linear"
config.cursor_blink_ease_out = "Linear"

config.default_cursor_style = "BlinkingBlock" -- BlinkingBlock,BlinkingBar,SteadyBar,SteadyUnderline,BlinkingUnderline

-- https://wezterm.org/config/font-shaping.html
config.font = wezterm.font("FiraCode Nerd Font")
-- config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold" })
-- config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold", italic = true })

-- 키 매핑(rttps://wezterm.org/config/default-keys.html)
-- wezterm show-keys : 현재 설정된 키 정보 확인하는 CLI
-- wezterm show-keys --lua --key-table search_mode : lua 모드에서 search_mode 테이블만 보기
-- ctrl+shift+p : command palette
-- ctrl+shift+u : emoji 입력
config.keys = {
	-- Ctrl+Space  vi 모드 (복사 모드) 토글
	-- https://wezterm.org/copymode.html
	{ key = "Space", mods = "CTRL", action = wezterm.action.ActivateCopyMode },
	-- Alt + LeftArrow (단어 단위 왼쪽 이동)
	{
		key = "LeftArrow",
		mods = "ALT",
		action = wezterm.action.SendKey({
			key = "b",
			mods = "ALT",
		}),
	},
	-- Alt + RightArrow (단어 단위 오른쪽 이동)
	{
		key = "RightArrow",
		mods = "ALT",
		action = wezterm.action.SendKey({
			key = "f",
			mods = "ALT",
		}),
	},
}

-- 상태 표시(탭제목있는 보이는 경우): vi 모드 진입 시 오른쪽에 표시
wezterm.on("update-right-status", function(window, _)
	if window:active_key_table() == "copy_mode" then
		window:set_right_status("📜 VI MODE")
	else
		window:set_right_status("")
	end
end)

-- Finally, return the configuration to wezterm:
return config
