data:extend({
    { type = "recipe-category", name = "charging", },
    { type = "fuel-category",   name = "battery",  },
})

local data_util = mods["space-exploration"] and require("__space-exploration__.data_util")
local is_decay = settings.startup["battery-powered-decay"].value
local is_k2_fuel_rebalance = battery_powered.is_k2 and settings.startup["kr-rebalance-fuels"].value and settings.startup["battery-powered-k2-fuel-rebalance"].value

-- SE defines this globally so adding to it is enough to create a capsule
se_delivery_cannon_recipes = se_delivery_cannon_recipes or {}

local group = "intermediate-products"

local subgroup = "intermediate-product"
local subgroup_charged = battery_powered.is_se and "processed-fuel" or "intermediate-product"

local base_battery = data.raw.item["battery"]
base_battery.order = "h[battery]-a-a"
base_battery.subgroup = subgroup

if battery_powered.is_k2 then
    battery = data.raw.item["lithium-sulfur-battery"]
    battery.group = group
    battery.subgroup = subgroup
    battery.order = "h[battery]-a-b"
end

local create_battery = function (p)
    local name, name_charged

    if not p.use then
        name = "bp-"..p.prefix.."-battery"
        name_charged = "bp-charged-"..p.prefix.."-battery"
    else 
        name = p.use
        name_charged = "bp-charged-"..(p.prefix and (p.prefix .. "-") or "").."battery"
    end

    local battery = {
        type = "item",
        name = name,
        icon = battery_powered.icon_path .. name .. ".png",
        icon_size = battery_powered.icon_size,
        icon_mipmaps = battery_powered.icon_mipmaps,
        stack_size = 100,
        group = group,
        subgroup = subgroup,
        order = "h[battery]-a-"..p.order,
    }

    local produce_battery = {
        type = "recipe",
        name = name,
        results = {
            { type = "item", name = name, amount = 1 }
        },
        order = "h[battery]-a-"..p.order,
        category = "crafting-with-fluid",
        enabled = false,
        show_amount_in_title = false,
        ingredients = p.ingredients,
        energy_required = 4,
    }

    local charged_battery = {
        type = "item",
        name = name_charged,
        icon = battery_powered.icon_path .. name_charged .. ".png",
        icon_size = battery_powered.icon_size,
        icon_mipmaps = battery_powered.icon_mipmaps,
        stack_size = p.stack,
        group = group,
        subgroup = subgroup_charged,
        order = "h[battery]-b-"..p.order,
        burnt_result = name,
        fuel_value = p.fuel .. "MJ",
        fuel_category = "battery",
        fuel_emissions_multiplier = 0,
        fuel_acceleration_multiplier = p.acceleration,
        fuel_top_speed_multiplier = p.top_speed,
    }

    local charge_battery = {
        type = "recipe",
        name = name_charged,
        results = {
            { type = "item", name = name_charged, amount = 1, probability = (is_decay and p.probability) or 1 },
        },
        order = "h[battery]-b-"..p.order,
        category = "charging",
        enabled = false,
        always_show_made_in = true,
        show_amount_in_title = false,
        always_show_products = true,
        ingredients = {{ name, 1 }},
        -- recipes assume 1MW charger
        energy_required = p.fuel,
        hide_from_stats = true,
        allow_decomposition = false,
        crafting_machine_tint = { primary = p.recipe_tint },
    }

    if p.use then
        data:extend({charged_battery, charge_battery})
        add_unlock_to_tech(p.tech, name_charged)
    else
        data:extend({battery, produce_battery, charged_battery, charge_battery})
        add_unlock_to_tech(p.tech, name)
        add_unlock_to_tech(p.tech, name_charged)
    end

    if battery_powered.is_se and p.scrap then

        local scrap_battery = {
            type = "recipe",
            name = string.gsub(name, "^bp", "bp-recycle"),
            localised_name = { "recipe-name.se-generic-recycling", { "item-name."..name} },
            icons = data_util.transition_icons(
                {
                    icon = battery.icon,
                    icon_size = battery.icon_size, scale = 0.5
                },
                {
                    icon = data.raw.item[data_util.mod_prefix .. "scrap"].icon,
                    icon_size = data.raw.item[data_util.mod_prefix .. "scrap"].icon_size, scale = 0.5
                }),
            -- icon = battery_powered.icon_path .. name .. ".png",
            -- icon_size = battery_powered.icon_size,
            -- icon_mipmaps = battery_powered.icon_mipmaps,
            results = p.scrap,
            order = "h[battery]-a-"..p.order,
            category = "hard-recycling",
            subgroup = subgroup,
            enabled = false,
            ingredients = {{type = "item", name = name, amount = 1}},
            energy_required = 4,
            allow_decomposition = false,
        }

        data:extend({scrap_battery})
        add_unlock_to_tech(p.tech, scrap_battery.name)
    end

    if battery_powered.is_se and settings.startup["battery-powered-delivery-cannon"].value then
        se_delivery_cannon_recipes[battery.name] = { name = battery.name }
    end
end

create_battery({
    use = "battery",
    prefix = false,
    tech = "electric-energy-accumulators",
    probability = 0.98,
    recipe_tint = {0xB2,0x53,0x36},
    order = "a",
    -- a little better than coal :-)
    stack = 50,
    fuel = 5,
    -- K2: slightly better than solid fuel
    acceleration = (is_k2_fuel_rebalance and 0.85) or 1.10,
    top_speed = (is_k2_fuel_rebalance and 0.75) or 1.05,
})

if not battery_powered.is_k2 then
    create_battery({
        prefix = "advanced",
        tech = "electric-energy-accumulators",
        ingredients = {
            {type = "item",  name = "steel-plate",   amount =  1},
            {type = "item",  name = "copper-plate",  amount =  2},
            {type = "item",  name = "plastic-bar",   amount =  2},
            {type = "fluid", name = "sulfuric-acid", amount = 40},
        },
        scrap = {
            {type = "item",  name = "se-scrap",      amount     = 1},
            {type = "item",  name = "copper-plate",  amount_min = 1, amount_max  = 2},
            {type = "item",  name = "plastic-bar",   amount_min = 1, amount_max  = 2},
        },
        probability = 0.99,
        recipe_tint = {0xE6,0xBA,0x39},
        order = "b",
        -- 2MJ less energy density than solid fuel, .2 more acceleration, .05 more speed
        stack = 50,
        fuel = 10,
        acceleration = 1.4,
        top_speed = 1.10,
    })
else
    create_battery({
        use = "lithium-sulfur-battery",
        prefix = "lithium-sulfur",
        tech = "kr-lithium-sulfur-battery",
        probability = 0.99,
        recipe_tint = {0xE6,0xBA,0x39},
        order = "b",
        -- 2MJ less energy density than solid fuel, .2 more acceleration, .05 more speed
        stack = 50,
        fuel = battery_powered.is_se and 10 or 40, -- K2 has 40MJ with IR2 charging, replicate that for K2 without SE
        -- K2: more acceleration but less top speed and range than normal fuel
        acceleration = (is_k2_fuel_rebalance and 1.10) or 1.4,
        top_speed = (is_k2_fuel_rebalance and 0.95) or 1.10,
    })

    local charged = data.raw.item["bp-charged-lithium-sulfur-battery"]
    -- straight out of  __Krastorio2__/compatibility-scripts/data-final-fixes/IndustrialRevolution.lua
    charged.icon = battery_powered.k2_path .. "compatibility/IndustrialRevolution/charged-lithium-sulfur-battery.png"
    charged.icon_size = 64
    charged.icon_mipmaps = 4
    charged.pictures = {
        layers = {
            {
                size = 64,
                filename = battery_powered.k2_path .. "compatibility/IndustrialRevolution/charged-lithium-sulfur-battery.png",
                scale = 0.25,
                mipmap_count = 4,
            }, 
            {
                draw_as_light = true,
                flags = { "light" },
                size = 64,
                filename = battery_powered.k2_path .. "icons/items/lithium-sulfur-battery-light.png",
                scale = 0.25,
                mipmap_count = 4,
            },
        },
    }
end

if battery_powered.is_se then

    create_battery({
        prefix = "holmium",
        tech = "se-space-accumulator",
        ingredients = {
            {type = "item",  name = "se-heat-shielding", amount =   1},
            {type = "item",  name = "glass",             amount =   1},
            {type = "item",  name = "se-holmium-plate",  amount =   2},
            {type = "item",  name = "se-vitalic-acid",   amount =   1},
            {type = "fluid", name = "se-ion-stream",     amount =  20},
        },
        scrap = {
            {type = "item",  name = "se-heat-shielding", amount     = 1, probability = 0.75},
            {type = "item",  name = "se-scrap",          amount     = 1},
            {type = "item",  name = "se-holmium-plate",  amount_min = 1, amount_max  = 2},
        },
        probability = 0.995,
        recipe_tint = {0xec, 0x69, 0xab},
        order = "c",
        -- same energy density as rocket fuel, same acceleration and speed
        stack = 20,
        fuel = 50,
        -- K2: more acceleration but less top speed than advanced fuel
        acceleration = (is_k2_fuel_rebalance and 1.40) or 1.80,
        top_speed = (is_k2_fuel_rebalance and 1.20) or 1.15,
    })

    create_battery({
        prefix = "naquium",
        tech = "se-space-accumulator-2",
        ingredients = {
            {type = "item",  name = "se-lattice-pressure-vessel", amount =  1},
            {type = "item",  name = "se-naquium-plate",           amount =  2},
            {type = "item",  name = "se-self-sealing-gel",        amount =  1},
            {type = "item",  name = "se-superconductive-cable",   amount =  1},
            {type = "fluid", name = "se-proton-stream",           amount =  20},
        },
        scrap = {
            {type = "item",  name = "se-lattice-pressure-vessel", amount     = 1, probability = 0.75},
            {type = "item",  name = "se-scrap",                   amount     = 1},
            {type = "item",  name = "se-naquium-plate",           amount_min = 1, amount_max  = 2},
        },
        probability = 0.998,
        recipe_tint = {0x89, 0x71, 0xc7},
        order = "d",
        -- 800MJ higher energy density than nuclear fuel, .3 less acceleration, same speed
        stack = 20,
        fuel = 100,
        -- K2: more acceleration than advanced fuel
        acceleration = (is_k2_fuel_rebalance and 1.80) or 2.20,
        top_speed = (is_k2_fuel_rebalance and 1.25) or 1.15,
    })
    
end
