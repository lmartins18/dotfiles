-- Resident quake hotkey daemon (macOS) — Hammerspoon counterpart of the
-- Windows daemon in ~/.config/wezterm/quake-daemon.ps1.
--
-- Registers Ctrl+' as a global hotkey and toggles a dedicated WezTerm quake
-- window, dropped down from the top of the PRIMARY display like Guake.
--
-- The window is tracked primarily by the PID of the wezterm-gui process we
-- spawn — available synchronously, so duplicate spawns are impossible even
-- while the window is still materializing. The OS title "WezTermQuake"
-- (forced by wezterm.lua's format-window-title when a pane carries user-var
-- quake=1) is only a fallback used to ADOPT a window from a previous
-- Hammerspoon session after a config reload. Each spawn is its own
-- wezterm-gui process, so hiding it (application:hide) never touches your
-- other WezTerm windows.
--
-- Requirements: Hammerspoon with Accessibility permission granted
-- (System Settings > Privacy & Security > Accessibility).

require 'hs.ipc' -- enables `hs -c "..."` CLI debugging

hs.autoLaunch(true) -- start at login, like the Windows Startup shortcut

-- Window control is dead in the water without Accessibility; prompt if missing.
if not hs.accessibilityState(true) then
  hs.notify.show('Hammerspoon', 'Quake terminal', 'Grant Accessibility permission, then Reload Config')
end

local TITLE = 'WezTermQuake'
local BUNDLE = 'com.github.wez.wezterm'
local WEZTERM = '/Applications/WezTerm.app/Contents/MacOS/wezterm-gui'
local PWSH = '/opt/homebrew/bin/pwsh'
local SPAWN_GRACE = 6 -- seconds a spawn is allowed to take to appear
local HEIGHT_FRAC = 0.5 -- fraction of the screen the quake window covers

local quakePid = nil -- pid of the wezterm-gui process we spawned
local spawnedAt = 0 -- epoch seconds of the last spawn
local waitTimer = nil

-- Full-width strip at the top of the primary display (below the menu bar).
local function quakeFrame()
  local sf = hs.screen.primaryScreen():frame()
  return hs.geometry.rect(sf.x, sf.y, sf.w, sf.h * HEIGHT_FRAC)
end

-- Resolve the quake window: by spawned PID first (synchronous, race-free),
-- else by title (adopting a window from before a Hammerspoon reload).
local function locate()
  if quakePid then
    local app = hs.application.applicationForPID(quakePid)
    if app then
      local win = app:mainWindow() or app:allWindows()[1]
      if win then return win end
    else
      quakePid = nil -- process died
    end
  end
  for _, app in ipairs(hs.application.applicationsForBundleID(BUNDLE) or {}) do
    for _, win in ipairs(app:allWindows()) do
      if win:title() == TITLE then
        quakePid = app:pid()
        return win
      end
    end
  end
  return nil
end

local function summon(win)
  win:application():unhide()
  win:setFrame(quakeFrame(), 0) -- snap to the primary display every time
  win:focus()
end

local function showHideOrSummon(win)
  local focused = hs.window.focusedWindow()
  if focused and focused:id() == win:id() then
    win:application():hide() -- focused -> dismiss
  else
    summon(win) -- hidden/minimized/unfocused/wrong screen -> summon
  end
end

local function spawn()
  -- OSC 1337 SetUserVar=quake=MQ== (base64 "1") so wezterm.lua titles the
  -- window "WezTermQuake". Same marker command as the Windows daemon.
  local task = hs.task.new(WEZTERM, function()
    quakePid = nil -- wezterm-gui exited; next press spawns fresh
  end, {
    'start',
    '--always-new-process',
    '--',
    PWSH,
    '-NoLogo',
    '-NoExit',
    '-Command',
    "[Console]::Write([char]27 + ']1337;SetUserVar=quake=MQ==' + [char]7)",
  })
  task:start()
  quakePid = task:pid()
  spawnedAt = hs.timer.secondsSinceEpoch()
end

-- Non-blocking poll for the spawned window to materialize, then summon it.
local function summonWhenReady(deadline)
  if waitTimer then waitTimer:stop() end
  waitTimer = hs.timer.doEvery(0.08, function()
    local win = locate()
    if win then
      waitTimer:stop()
      waitTimer = nil
      summon(win)
    elseif hs.timer.secondsSinceEpoch() > deadline then
      waitTimer:stop()
      waitTimer = nil
    end
  end)
end

hs.hotkey.bind({ 'ctrl' }, "'", function()
  local win = locate()
  if win then return showHideOrSummon(win) end

  -- No window. If a spawn is still settling (process alive but window not yet
  -- created, or within the grace period), wait for it instead of spawning
  -- another one.
  local now = hs.timer.secondsSinceEpoch()
  if quakePid or now - spawnedAt < SPAWN_GRACE then return summonWhenReady(now + SPAWN_GRACE) end

  spawn()
  summonWhenReady(spawnedAt + SPAWN_GRACE)
end)
