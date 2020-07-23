def configure(keymap):
    keymap_global = keymap.defineWindowKeymap()
    keymap_global["S-Semicolon"] = "Semicolon"
    keymap_global["Semicolon"] = "S-Semicolon"
    keymap_global["O-LCtrl"] = "Esc"
    keymap_global["O-LShift"] = "Back"