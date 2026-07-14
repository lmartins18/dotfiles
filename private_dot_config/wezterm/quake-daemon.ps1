# Resident quake hotkey daemon (Windows).
#
# Registers Ctrl+` as a global hotkey ONCE and toggles the WezTerm quake window
# in-process, so every press is instant — the PowerShell + P/Invoke startup cost
# is paid once at login, not per keypress. Started hidden at login via a Startup
# shortcut (see setup). Uses only in-memory Add-Type (no compiled binary on
# disk) + RegisterHotKey (a benign hotkey API, not a low-level keyboard hook),
# so it stays clear of SentinelOne.
#
# The quake window is identified by its OS title "WezTermQuake", forced in
# wezterm.lua's format-window-title when the pane carries user-var quake=1.

$ErrorActionPreference = 'Stop'

Add-Type @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public static class QuakeDaemon {
  const uint MOD_CONTROL = 0x0002, MOD_NOREPEAT = 0x4000;
  const uint VK_OEM_3 = 0xC0;   // the ` / ~ key
  const int  WM_HOTKEY = 0x0312;
  const int  SW_HIDE = 0, SW_RESTORE = 9;
  const string TITLE = "WezTermQuake";

  [DllImport("user32.dll")] static extern bool RegisterHotKey(IntPtr h, int id, uint mods, uint vk);
  [DllImport("user32.dll")] static extern bool UnregisterHotKey(IntPtr h, int id);
  [DllImport("user32.dll")] static extern int  GetMessage(out MSG msg, IntPtr h, uint min, uint max);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr FindWindow(string c, string n);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr h);

  [StructLayout(LayoutKind.Sequential)]
  public struct MSG { public IntPtr hwnd; public uint message; public IntPtr w; public IntPtr l; public uint time; public int x; public int y; }

  public static void Run() {
    // NOREPEAT so holding the key doesn't machine-gun the toggle.
    if (!RegisterHotKey(IntPtr.Zero, 1, MOD_CONTROL | MOD_NOREPEAT, VK_OEM_3)) return;
    MSG msg;
    while (GetMessage(out msg, IntPtr.Zero, 0, 0) > 0) {
      if (msg.message == WM_HOTKEY) Toggle();
    }
    UnregisterHotKey(IntPtr.Zero, 1);
  }

  static void Toggle() {
    IntPtr h = FindWindow(null, TITLE);        // finds hidden windows too
    if (h == IntPtr.Zero) { Spawn(); return; } // not running -> create it
    if (IsWindowVisible(h) && !IsIconic(h) && GetForegroundWindow() == h) {
      ShowWindow(h, SW_HIDE);                  // focused -> dismiss
    } else {
      ShowWindow(h, SW_RESTORE);               // hidden/minimized/unfocused -> summon
      SetForegroundWindow(h);
    }
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
