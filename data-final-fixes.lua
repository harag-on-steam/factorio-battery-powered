if deadlock and settings.startup["deadlock-enable-beltboxes"].value then
    deadlock.add_stack("battery", battery_powered.icon_path .. "bp-stacked-battery.png", "deadlock-stacking-2", 64, "item", 4)
end