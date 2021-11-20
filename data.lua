require("code.globals")
require("code.functions")

require("code.data.batteries")
require("code.data.chargers")
require("code.data.vehicle-fuel")

if deadlock and settings.startup["deadlock-enable-beltboxes"].value then
    -- deadlock.add_stack("battery",...  needs data-final-fixes, other mods might have added a different stack icon

    if not battery_powered.is_k2 then
        deadlock.add_stack("bp-advanced-battery", battery_powered.icon_path .. "bp-stacked-advanced-battery.png", "deadlock-stacking-2", 64, "item", 4)
    end

    if battery_powered.is_se and mods["Deadlock-SE-bridge"] then
        deadlock.add_stack("bp-holmium-battery", battery_powered.icon_path .. "bp-stacked-holmium-battery.png", "deadlock-stacking-space-energy", 64, "item", 4)
        deadlock.add_stack("bp-naquium-battery", battery_powered.icon_path .. "bp-stacked-naquium-battery.png", "deadlock-stacking-space-deep", 64, "item", 4)
    end
end