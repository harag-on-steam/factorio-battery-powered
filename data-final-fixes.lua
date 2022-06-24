if battery_powered.is_k2 and battery_powered.is_se then
    -- With SE active K2 changes fuel-categories in this data stage, redo our changes *again*
    require("code.data.vehicle-fuel")
end

if deadlock and settings.startup["deadlock-enable-beltboxes"].value then
    deadlock.add_stack("battery", battery_powered.icon_path .. "bp-stacked-battery.png", "deadlock-stacking-2", 64, "item", 4)
end