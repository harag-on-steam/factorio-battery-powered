
---@type data.AnyModSettingPrototype[]
local settings = {
    {
        type = "double-setting",
        name = "battery-powered-discharger-performance",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10,
        order = "a1",
    },
    {
        type = "bool-setting",
        name = "battery-powered-dischargers",
        setting_type = "startup",
        default_value = true,
        order = "a2",
    },
    {
        type = "bool-setting",
        name = "battery-powered-decay",
        setting_type = "startup",
        default_value = true,
        order = "a3",
    },
    {
        type = "bool-setting",
        name = "battery-powered-delivery-cannon",
        setting_type = "startup",
        default_value = true,
        order = "a4",
        hidden = true,
    },
    {
        type = "bool-setting",
        name = "battery-powered-k2-fuel-rebalance",
        setting_type = "startup",
        default_value = true,
        order = "a5",
        hidden = true,
    },
    {
        type = "int-setting",
        name = "battery-powered-burnt-inventory-size",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 5,
        -- allowed_values = { 1, 2, 3, 4, 5 },
        order = "a6",
    },
    {
        type = "bool-setting",
        name = "battery-powered-jetpack-fuel",
        setting_type = "startup",
        default_value = true,
        order = "a7",
    },
    {
        type = "bool-setting",
        name = "battery-powered-equipment-fuel",
        setting_type = "startup",
        default_value = true,
        order = "a8",
        hidden = true,
    },
}

data.extend(settings)
