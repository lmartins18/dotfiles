-- WezTerm config (managed by chezmoi)
-- Shell: pwsh 7. Colors: custom "Horizon (nvim)" scheme built from the exact
-- palette in ~/.config/nvim/lua/config/highlights.lua (tokyonight + Horizon
-- highlight overrides) — no stock WezTerm Horizon matched it.

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local home = os.getenv 'USERPROFILE'
local localappdata = os.getenv 'LOCALAPPDATA'

--------------------------------------------------------------------------------
-- Shell
--------------------------------------------------------------------------------
config.default_prog = { 'pwsh.exe', '-NoLogo' }

--------------------------------------------------------------------------------
-- Horizon color scheme (from your nvim palette)
--------------------------------------------------------------------------------
config.color_schemes = {
  ['Horizon (nvim)'] = {
    background = '#1C1E26', -- P.bg
    foreground = '#D5D8DA', -- P.lightText
    cursor_bg = '#FAB795',  -- P.rosebud (orange)
    cursor_fg = '#1C1E26',
    cursor_border = '#FAB795',
    selection_bg = '#343647', -- P.visual_bg
    selection_fg = '#D5D8DA',
    scrollbar_thumb = '#232530',
    split = '#1A1C23',
    -- black, red(cranberry), green, yellow(rosebud), blue, magenta, cyan, white
    ansi = { '#16161C', '#E95678', '#29D398', '#FAB795', '#26BBD9', '#EE64AC', '#59E1E3', '#D5D8DA' },
    brights = { '#6C6F93', '#EC6A88', '#3FDAA4', '#FBC3A7', '#3FC6DE', '#F075B7', '#6BE4E6', '#FADAD1' },
  },
}
config.color_scheme = 'Horizon (nvim)'

-- Tab-bar colors overlaid on the scheme (Horizon accents)
config.colors = {
  tab_bar = {
    background = '#16161C',
    active_tab = { bg_color = '#1C1E26', fg_color = '#FAB795', intensity = 'Bold' },
    inactive_tab = { bg_color = '#1A1C23', fg_color = '#6C6F93' },
    inactive_tab_hover = { bg_color = '#232530', fg_color = '#D5D8DA', italic = true },
    new_tab = { bg_color = '#1A1C23', fg_color = '#6C6F93' },
    new_tab_hover = { bg_color = '#232530', fg_color = '#E95678' },
  },
}

--------------------------------------------------------------------------------
-- Font
--------------------------------------------------------------------------------
config.font = wezterm.font_with_fallback {
  { family = 'FantasqueSansM Nerd Font Mono', weight = 'Medium' },
  'FantasqueSansM Nerd Font',
  'Symbols Nerd Font Mono',
}
config.font_size = 12.0

--------------------------------------------------------------------------------
-- Window / tabs — roomier padding
--------------------------------------------------------------------------------
config.window_background_opacity = 0.76
config.window_padding = { left = 14, right = 14, top = 10, bottom = 8 }
config.default_cursor_style = 'SteadyUnderline'
config.scrollback_lines = 9001
config.enable_scroll_bar = false
config.window_decorations = 'RESIZE'
config.animation_fps = 1
config.cursor_blink_rate = 0

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false -- keep the styled bar visible
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = true

-- Pad tab titles for breathing room: "  1: pwsh  "
wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end
  return '  ' .. (tab.tab_index + 1) .. ': ' .. title .. '  '
end)

--------------------------------------------------------------------------------
-- Yazi + previews (works without touching system env vars)
--------------------------------------------------------------------------------
config.set_environment_variables = {
  YAZI_FILE_ONE = localappdata .. '\\Programs\\Git\\usr\\bin\\file.exe',
  YAZI_CONFIG_HOME = home .. '\\.config\\yazi',
}

--------------------------------------------------------------------------------
-- Keybindings — translated from Windows Terminal
--------------------------------------------------------------------------------
-- WezTerm defaults stay enabled; these layer on top.
-- Reproduced WT binds: ctrl+c (copy/interrupt), ctrl+v (paste), ctrl+shift+f
-- (find), alt+shift+d (auto split + duplicate), shift+enter (esc+cr).
-- NOT translatable: ctrl+` quakeMode / ctrl+' globalSummon (no WezTerm equivalent).
config.keys = {
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      local sel = win:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        win:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
        win:perform_action(act.ClearSelection, pane)
      else
        win:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  },
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' },

  -- alt+shift+d: split along the longer axis (WT "auto" duplicate)
  {
    key = 'd',
    mods = 'ALT|SHIFT',
    action = wezterm.action_callback(function(win, pane)
      local dims = pane:get_dimensions()
      if dims.cols > (dims.viewport_rows * 2) then
        win:perform_action(act.SplitHorizontal { domain = 'CurrentPaneDomain' }, pane)
      else
        win:perform_action(act.SplitVertical { domain = 'CurrentPaneDomain' }, pane)
      end
    end),
  },

  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = false } },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.SpawnWindow },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },

  { key = 'LeftArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 3 } },
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 3 } },
  { key = 'UpArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Up', 3 } },
  { key = 'DownArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Down', 3 } },

  { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
  { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },

  { key = 'y', mods = 'CTRL|SHIFT', action = act.SpawnCommandInNewTab { args = { 'yazi.exe' } } },
}

for i = 1, 8 do
  table.insert(config.keys, { key = tostring(i), mods = 'CTRL|ALT', action = act.ActivateTab(i - 1) })
end
table.insert(config.keys, { key = '9', mods = 'CTRL|ALT', action = act.ActivateTab(-1) })

return config
