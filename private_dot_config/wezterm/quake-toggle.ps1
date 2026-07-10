# Quake-style show/hide toggle for a dedicated WezTerm window.
#
# Bound to a global hotkey via PowerToys > Keyboard Manager > Run Program:
#   Program: pwsh.exe
#   Args:    -NoProfile -WindowStyle Hidden -File "%USERPROFILE%\.config\wezterm\quake-toggle.ps1"
#   Visibility: Hidden
#
# Uses ONLY Windows' built-in UI Automation accessibility API (a framework
# assembly that is loaded, not compiled) plus WScript.Shell for focus. No
# P/Invoke, no Roslyn compile, no custom binary — so it stays clear of
# SentinelOne (which blocks unsigned compiled .exe/.dll that manipulate windows).
#
# The quake window is identified by its OS title "WezTermQuake", forced in
# wezterm.lua's format-window-title when the pane carries user-var quake=1.
#   * minimized            -> restore + focus   (summon)
#   * visible & focused    -> minimize          (dismiss)
#   * visible & unfocused  -> focus             (raise to front)
#   * not running          -> spawn a tagged pwsh window via trusted wezterm

$ErrorActionPreference = 'SilentlyContinue'
$title = 'WezTermQuake'

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$AE  = [System.Windows.Automation.AutomationElement]
$WVS = [System.Windows.Automation.WindowVisualState]

function Focus-Quake {
  (New-Object -ComObject WScript.Shell).AppActivate($title) | Out-Null
}

# True if the currently focused control lives under the quake window.
function Test-QuakeActive {
  $f = $AE::FocusedElement
  if ($null -eq $f) { return $false }
  $walker = [System.Windows.Automation.TreeWalker]::ControlViewWalker
  $cur = $f
  while ($null -ne $cur) {
    if ($cur.Current.Name -eq $title) { return $true }
    $cur = $walker.GetParent($cur)
  }
  return $false
}

$cond = New-Object System.Windows.Automation.PropertyCondition($AE::NameProperty, $title)
$el = $AE::RootElement.FindFirst([System.Windows.Automation.TreeScope]::Children, $cond)

if ($null -eq $el) {
  # Not running: spawn a tagged pwsh window through trusted wezterm, then focus.
  $cmd = "[Console]::Write([char]27 + ']1337;SetUserVar=quake=MQ==' + [char]7)"
  Start-Process 'wezterm-gui.exe' -ArgumentList @('start', '--', 'pwsh', '-NoLogo', '-NoExit', '-Command', $cmd)
  Start-Sleep -Milliseconds 700
  Focus-Quake
  return
}

$wp = $el.GetCurrentPattern([System.Windows.Automation.WindowPattern]::Pattern)
if ($wp.Current.WindowVisualState -eq $WVS::Minimized) {
  $wp.SetWindowVisualState($WVS::Normal)
  Focus-Quake
} elseif (Test-QuakeActive) {
  $wp.SetWindowVisualState($WVS::Minimized)
} else {
  Focus-Quake
}
