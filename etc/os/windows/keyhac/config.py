def configure(keymap):
    keymap_global = keymap.defineWindowKeymap()
    keymap_global["S-Semicolon"] = "Semicolon"
    keymap_global["Semicolon"] = "S-Semicolon"
