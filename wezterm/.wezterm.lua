-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

config.hide_tab_bar_if_only_one_tab = true

config.font_size = 18

-- https://wezterm.org/colorschemes/index.html
-- config.color_scheme = "AdventureTime"
config.color_scheme = "Argonaut"

-- https://wezterm.org/config/font-shaping.html
config.font = wezterm.font("FiraCode Nerd Font")
-- config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold" })
-- config.font = wezterm.font("FiraCode Nerd Font", { weight = "Bold", italic = true })

-- 커서 애니메이션 (Neovide 느낌)
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "EaseInOut"
config.cursor_blink_ease_out = "EaseInOut"
-- config.default_cursor_style = "BlinkingBar"

-- 키 매핑
config.keys = {
	-- Ctrl+Space  vi 모드 (복사 모드) 토글
	-- https://wezterm.org/copymode.html
	{ key = "Space", mods = "CTRL", action = wezterm.action.ActivateCopyMode },
}
-- 상태 표시: vi 모드 진입 시 오른쪽에 표시
wezterm.on("update-right-status", function(window, _)
	if window:active_key_table() == "copy_mode" then
		window:set_right_status("📜 VI MODE")
	else
		window:set_right_status("")
	end
end)

-- Finally, return the configuration to wezterm:
return config
