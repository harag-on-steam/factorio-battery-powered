battery_powered = {}

battery_powered.name = "battery-powered"
battery_powered.mod_path = "__battery-powered__/"

battery_powered.entity_path = battery_powered.mod_path .."graphics/entities/"
battery_powered.icon_path = battery_powered.mod_path .."graphics/icons/"

battery_powered.icon_size = 64
battery_powered.icon_mipmaps = 4

battery_powered.is_age = ((mods and mods["space-age"]) or (script and script.active_mods["space-age"])) and true
battery_powered.is_se = ((mods and mods["space-exploration"]) or (script and script.active_mods["space-exploration"])) and true
battery_powered.is_k2 = ((mods and mods["Krastorio2"]) or (script and script.active_mods["Krastorio2"])) and true
battery_powered.k2_path = "__Krastorio2Assets__/"
