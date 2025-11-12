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
config.window_decorations = "RESIZE" -- 위쪽 제목표시 줄 없애기 윈도우 크기 조정이 됨
-- config.window_decorations = "TITLE | RESIZE" -- 위쪽 제목표시 + 윈도우 크기 조정이 됨

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- config.window_background_opacity = 0.7
-- config.macos_window_background_blur = 80

-- https://wezterm.org/colorschemes/index.html
-- config.color_scheme = "AdventureTime"
config.color_scheme = "Argonaut"

config.colors = {
	-- The default text color
	foreground = "silver",
	-- The default background color
	background = "black",

	-- cursor_bg = "#ff5555", -- 커서 배경
	cursor_bg = "white", -- 커서 배경
	-- cursor_fg를 지정하지 않으면 기본적으로 글자색이 커서색과 섞여서 글씨가 안 보일 수 있다.
	cursor_fg = "#000000", -- 커서 위의 글자색 검정 등 대비색
	-- Specifies the border color of the cursor when the cursor style is set to Block,
	-- or the color of the vertical or horizontal bar when the cursor style is set to
	-- Bar or Underline.
	cursor_border = "white", -- 커서 테두리색

	-- copy_mode(ViMode)나 마우스로 선택하는 경우
	-- the foreground color of selected text
	selection_fg = "black",
	-- the background color of selected text
	selection_bg = "Yellow",

	-- The color of the scrollbar "thumb"; the portion that represents the current viewport
	scrollbar_thumb = "#222222",

	-- The color of the split lines between panes
	split = "green",

	-- use `AnsiColor` to specify one of the ansi color palette values
	-- (index 0-15) using one of the names "Black", "Maroon", "Green",
	--  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
	-- "Yellow", "Blue", "Fuchsia", "Aqua" or "White". (대소문자 구분)
	--  cmd+f search 로 매칭되는 모든 부분에서 선택(up,down)한 부분
	copy_mode_active_highlight_bg = { AnsiColor = "Yellow" },
	copy_mode_active_highlight_fg = { AnsiColor = "Yellow" },

	--  cmd+f search 로 매칭되는 모든 부분들
	copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
	copy_mode_inactive_highlight_fg = { AnsiColor = "White" },

	-- ctrl+shift+space : 해시,컬러,url 등의 패턴에 앞에 알파벳이 표시되서 빠르게 선택(복사)할 수 있다.
	quick_select_label_bg = { Color = "peru" },
	quick_select_label_fg = { Color = "#ffffff" },
	quick_select_match_bg = { AnsiColor = "Navy" },
	quick_select_match_fg = { Color = "#ffffff" },
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

config.font_size = 18

-- https://wezterm.org/config/font-shaping.html
config.font = wezterm.font("FiraCode Nerd Font")
-- config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold", italic = true })

-- By default, wezterm enables ligature support in the font that you have selected.
-- ligature(!=, --- >= <=) 비활성화
config.harfbuzz_features = { "calt = 0", "clig = 0", "liga = 0" }

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

-- 키 매핑(https://wezterm.org/config/default-keys.html)
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
	-- default:ctrl+shift+alt+%
	{
		key = "%",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- default:ctrl+shift+alt+"
	{
		key = '"',
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	-- default:ctrl+shift+LeftArrow
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	-- default:ctrl+shift+DownArrow
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	-- default:ctrl+shift+RightArrow
	{
		key = "l",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	-- default:ctrl+shift+UpArrow
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},

	-- default:ctrl+shift+alt+방향키로 pane 크기 조절(rectangle 윈도우 매지저와 충돌되는 경우가 있을 수 있다.)
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
