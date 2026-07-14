# Resident quake hotkey daemon (Windows).
#
# Registers Ctrl+` as a global hotkey ONCE and toggles the WezTerm quake window
# in-process, so every press is instant — the PowerShell + P/Invoke startup cost
# is paid once at login, not per keypress. Started hidden at login via a Startup
# shortcut (see setup). Uses only in-memory Add-Type (no compiled binary on
# disk) + RegisterHotKey (a benign hotkey API, not a low-level keyboard hook),
# so it stays clear of SentinelOne.
#
# The quake window is FIRST located by its OS title "WezTermQuake" (forced in
# wezterm.lua's format-window-title when a pane carries user-var quake=1), then
# its window handle is CACHED. All later toggles use the cached handle, so a
# press never depends on the title being present at that instant — the title is
# set asynchronously (wezterm -> pwsh -> OSC user-var -> format-window-title) and
# reverts whenever a non-quake pane is active, which previously caused repeated
# spawns instead of a summon. A spawn debounce guarantees that mashing the hotkey
# during the (possibly multi-second) cold start spawns at most one window.

$ErrorActionPreference = 'Stop'

Add-Type @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;

public static class QuakeDaemon {
  const uint MOD_CONTROL = 0x0002, MOD_NOREPEAT = 0x4000;
  const uint VK_OEM_3 = 0xC0;   // the ` / ~ key
  const int  WM_HOTKEY = 0x0312;
  const int  SW_HIDE = 0, SW_RESTORE = 9;
  const string TITLE = "WezTermQuake";
  const int  SPAWN_GRACE_MS = 6000;  // window a spawn is allowed to take to appear

  [DllImport("user32.dll")] static extern bool RegisterHotKey(IntPtr h, int id, uint mods, uint vk);
  [DllImport("user32.dll")] static extern bool UnregisterHotKey(IntPtr h, int id);
  [DllImport("user32.dll")] static extern int  GetMessage(out MSG msg, IntPtr h, uint min, uint max);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr FindWindow(string c, string n);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] static extern bool IsWindow(IntPtr h);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr h);

  [StructLayout(LayoutKind.Sequential)]
  public struct MSG { public IntPtr hwnd; public uint message; public IntPtr w; public IntPtr l; public uint time; public int x; public int y; }

  static IntPtr _cached = IntPtr.Zero;  // last known-good quake window handle
  static int    _spawnTick = 0;         // Environment.TickCount at last Spawn()

  public static void Run() {
    // NOREPEAT so holding the key doesn't machine-gun the toggle.
    if (!RegisterHotKey(IntPtr.Zero, 1, MOD_CONTROL | MOD_NOREPEAT, VK_OEM_3)) return;
    MSG msg;
    while (GetMessage(out msg, IntPtr.Zero, 0, 0) > 0) {
      if (msg.message == WM_HOTKEY) Toggle();
    }
    UnregisterHotKey(IntPtr.Zero, 1);
  }

  // Resolve the quake window: trust the cached handle while it's still a live
  // window, else look it up by title (adopting a window from a prior session).
  static IntPtr Locate() {
    if (_cached != IntPtr.Zero && IsWindow(_cached)) return _cached;
    _cached = FindWindow(null, TITLE);   // finds hidden windows too
    return _cached;
  }

  // Poll for the titled window to appear, up to timeoutMs. Returns Zero on timeout.
  static IntPtr WaitForWindow(int timeoutMs) {
    int start = Environment.TickCount;
    while (Environment.TickCount - start < timeoutMs) {
      IntPtr h = FindWindow(null, TITLE);
      if (h != IntPtr.Zero) return h;
      Thread.Sleep(80);
    }
    return IntPtr.Zero;
  }

  static void ShowHideOrSummon(IntPtr h) {
    if (IsWindowVisible(h) && !IsIconic(h) && GetForegroundWindow() == h) {
      ShowWindow(h, SW_HIDE);                  // focused -> dismiss
    } else {
      ShowWindow(h, SW_RESTORE);               // hidden/minimized/unfocused -> summon
      SetForegroundWindow(h);
    }
  }

  static void Toggle() {
    IntPtr h = Locate();
    if (h != IntPtr.Zero) { ShowHideOrSummon(h); return; }

    // Not found. If a spawn is still settling, wait for THAT window instead of
    // spawning another one — this is what stops the "new window every press"
    // storm during a slow cold start.
    int since = Environment.TickCount - _spawnTick;
    if (_spawnTick != 0 && since >= 0 && since < SPAWN_GRACE_MS) {
      h = WaitForWindow(SPAWN_GRACE_MS - since);
      if (h != IntPtr.Zero) { _cached = h; ShowHideOrSummon(h); }
      return;
    }

    // Genuinely absent -> spawn exactly one, then capture and cache its handle
    // so no future toggle has to rely on the (async, revertible) title again.
    Spawn();
    _spawnTick = Environment.TickCount;
    h = WaitForWindow(SPAWN_GRACE_MS);
    if (h != IntPtr.Zero) { _cached = h; SetForegroundWindow(h); }
  }

  static void Spawn() {
    // OSC 1337 SetUserVar=quake=base64("1") so wezterm.lua titles it "WezTermQuake".
    string cmd = "[Console]::Write([char]27 + ']1337;SetUserVar=quake=MQ==' + [char]7)";
    var psi = new ProcessStartInfo("wezterm-gui.exe") { UseShellExecute = false };
    foreach (var a in new[] { "start", "--", "pwsh", "-NoLogo", "-NoExit", "-Command", cmd })
      psi.ArgumentList.Add(a);
    Process.Start(psi);
  }
}
"@

[QuakeDaemon]::Run()
