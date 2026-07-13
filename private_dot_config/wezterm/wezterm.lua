-- WezTerm config — cross-platform (Windows + macOS), managed by chezmoi.
-- One file, no templating: OS differences are branched at runtime in Lua via
-- wezterm.target_triple, so chezmoi syncs the exact same file to every machine.
--
-- Colors: custom "Horizon (nvim)" scheme built from the exact palette in
-- ~/.config/nvim/lua/config/highlights.lua (tokyonight + Horizon overrides).

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

--------------------------------------------------------------------------------
-- Platform detection
--------------------------------------------------------------------------------
local triple = wezterm.target_triple
local is_win = triple:find 'windows' ~= nil
local is_mac = triple:find 'darwin' ~= nil
local home = wezterm.home_dir

-- App-level shortcut modifier: Cmd (SUPER) on macOS, Ctrl on Windows. Gives
-- native muscle memory on each OS while keeping one shared binding table.
local MOD = is_mac and 'SUPER' or 'CTRL'

--------------------------------------------------------------------------------
-- Shell
--------------------------------------------------------------------------------
if is_win then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
end
-- On macOS WezTerm uses your login shell. To run pwsh there too:
--   brew install powershell   then uncomment:
-- if is_mac then config.default_prog = { 'pwsh', '-NoLogo' } end

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
-- Install the primary font on each machine:
--   Windows: already present.  macOS: brew install --cask font-fantasque-sans-mono-nerd-font
config.font = wezterm.font_with_fallback {
  { family = 'FantasqueSansM Nerd Font Mono', weight = 'Medium' },
  'FantasqueSansM Nerd Font',
  -- FantasqueSansM's patched set misses some Nerd Font v3 icons, so fall back to
  -- the full-coverage JetBrainsMono NFM (exact family per `wezterm ls-fonts`).
  -- 'Fira Code' was removed — it isn't installed, so it did nothing.
  'JetBrainsMono Nerd Font Mono',
  'Symbols Nerd Font Mono', -- WezTerm's bundled symbol backstop
}
config.font_size = is_mac and 14.0 or 12.0 -- macOS Retina renders smaller

-- Control chars (e.g. U+001B ESC) and stray unassigned Private-Use codepoints
-- can never map to a real glyph, so the missing-glyph warning is pure noise.
config.warn_about_missing_glyphs = false

--------------------------------------------------------------------------------
-- Window / tabs — roomier padding
--------------------------------------------------------------------------------
-- Translucency via plain opacity (proven to work on this build). NOTE: Windows
-- drops window transparency while the window is MAXIMIZED — keep it un-maximized
-- to see it. (win32_system_backdrop='Acrylic' was tried and removed: it rendered
-- opaque on this WezTerm build.) macOS additionally blurs what's behind.
config.window_background_opacity = 0.76
if is_mac then
  config.macos_window_background_blur = 20
end
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
-- Quake terminal support  (Windows only, via PowerToys + quake-toggle.ps1)
--------------------------------------------------------------------------------
-- The external toggle spawns a dedicated pwsh window tagged with the pane
-- user-var `quake=1`; here we force that window's OS title to a fixed marker so
-- quake-toggle.ps1 can find it (UI Automation) and minimize/restore it. Inert
-- on machines that never set the var (e.g. macOS).
wezterm.on('format-window-title', function(tab, pane, tabs, panes, cfg)
  local uv = pane.user_vars
  if uv and uv.quake == '1' then
    return 'WezTermQuake'
  end
  return (tab.tab_index + 1) .. ': ' .. tab.active_pane.title
end)

--------------------------------------------------------------------------------
-- Yazi + previews (works without touching system env vars)
--------------------------------------------------------------------------------
if is_win then
  local localappdata = os.getenv 'LOCALAPPDATA'
  config.set_environment_variables = {
    YAZI_FILE_ONE = localappdata .. '\\Programs\\Git\\usr\\bin\\file.exe',
    YAZI_CONFIG_HOME = home .. '\\.config\\yazi',
  }
else
  -- macOS/Linux: `file` is already on PATH, so YAZI_FILE_ONE isn't needed.
  config.set_environment_variables = {
    YAZI_CONFIG_HOME = home .. '/.config/yazi',
  }
end

--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------
-- MOD = Cmd on macOS, Ctrl on Windows. WezTerm defaults stay enabled; these
-- layer on top. Tab-cycling & the quake toggle stay on Ctrl on both OSes because
-- macOS reserves Cmd+Tab (app switcher) and Cmd+` (window cycle).
local yazi_cmd = is_win and 'yazi.exe' or 'yazi'

config.keys = {
  -- Copy-on-selection, else pass the key through (Ctrl+C interrupt / Cmd+C copy).
  {
    key = 'c',
    mods = MOD,
    action = wezterm.action_callback(function(win, pane)
      local sel = win:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        win:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
        win:perform_action(act.ClearSelection, pane)
      else
        -- Always emit a real SIGINT regardless of which MOD triggered this.
        win:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  },
  { key = 'v', mods = MOD, action = act.PasteFrom 'Clipboard' },
  { key = 'c', mods = MOD .. '|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = MOD .. '|SHIFT', action = act.PasteFrom 'Clipboard' },

  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },
  { key = 'f', mods = MOD .. '|SHIFT', action = act.Search 'CurrentSelectionOrEmptyString' },

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

  -- Explicit pane splits (predictable, unlike alt+shift+d's auto direction):
  --   Ctrl+Shift++  -> vertical split   (panes side by side, new pane on the right)
  --   Ctrl+Shift+-  -> horizontal split (stacked, new pane below)
  -- Both the shifted char ('+'/'_') and base key ('='/'-') are bound so it fires
  -- regardless of how WezTerm reports the keypress on your layout.
  { key = '+', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '=', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '_', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  { key = 't', mods = MOD .. '|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = MOD .. '|SHIFT', action = act.CloseCurrentPane { confirm = false } },
  { key = 'n', mods = MOD .. '|SHIFT', action = act.SpawnWindow },
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

  { key = 'p', mods = MOD .. '|SHIFT', action = act.ActivateCommandPalette },
  { key = '=', mods = MOD, action = act.IncreaseFontSize },
  { key = '-', mods = MOD, action = act.DecreaseFontSize },
  { key = '0', mods = MOD, action = act.ResetFontSize },
  { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
  { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },

  { key = 'y', mods = MOD .. '|SHIFT', action = act.SpawnCommandInNewTab { args = { yazi_cmd } } },
}

for i = 1, 8 do
  table.insert(config.keys, { key = tostring(i), mods = 'CTRL|ALT', action = act.ActivateTab(i - 1) })
end
table.insert(config.keys, { key = '9', mods = 'CTRL|ALT', action = act.ActivateTab(-1) })

return config
