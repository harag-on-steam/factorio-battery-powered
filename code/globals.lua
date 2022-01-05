battery_powered = {}

battery_powered.name = "battery-powered"
battery_powered.mod_path = "__battery-powered__/"

battery_powered.entity_path = battery_powered.mod_path .."graphics/entities/"
battery_powered.icon_path = battery_powered.mod_path .."graphics/icons/"

battery_powered.icon_size = 64
battery_powered.icon_mipmaps = 4

battery_powered.is_se = ((mods and mods["space-exploration"]) or (game and game.active_mods["space-exploration"])) and true
battery_powered.is_k2 = ((mods and mods["Krastorio2"]) or (game and game.active_mods["Krastorio2"])) and true

-- support both K2 1.1 and K2 1.2 (assets were split in a separate mod)
if mods and mods["Krastorio2"] then
    local versionParts = string.gmatch(mods["Krastorio2"], "%d+")
    local major = tonumber(versionParts())
    local minor = tonumber(versionParts())
    battery_powered.k2_path = (major == 1 and minor < 2 and "__Krastorio2__/graphics/") or "__Krastorio2Assets__/"
end