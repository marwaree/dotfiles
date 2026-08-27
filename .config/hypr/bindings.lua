o.bind("SUPER + N", "Terminal", 'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"')
o.bind("SUPER + E", "File manager", "uwsm-app -- nautilus --new-window")

hl.unbind("SUPER + W")
o.bind("SUPER + W", "Browser", "omarchy-launch-browser")

o.bind("SUPER + Q", "Close focused window", hl.dsp.window.close())
o.bind("SUPER + SHIFT + Q", "Kill focused window", hl.dsp.window.kill())
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", "omarchy-launch-browser --private")
o.bind("SUPER + SHIFT + N", "Editor", "omarchy-launch-editor")
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("omarchy-menu toggle apps"))

o.bind("SUPER + D", "Maximize", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

hl.unbind("SUPER + L")
o.bind("SUPER + L", "Lock screen", "omarchy-system-lock")

hl.unbind("SUPER + S")
o.bind("SUPER + S", "Steam", "steam")

hl.unbind("SUPER + SPACE")
o.bind("SUPER + BACKSPACE", "Omarchy menu", "omarchy-menu")
