data:extend({
    { type = "recipe-category", name = "charging", },
    { type = "fuel-category",   name = "battery",  },
})

local data_util = mods["space-exploration"] and require("__space-exploration__.data_util")
local is_decay = settings.startup["battery-powered-decay"].value

-- SE defines this globally so adding to it is enough to create a capsule
se_delivery_cannon_recipes = se_delivery_cannon_recipes or {}

local group = "intermediate-products"
local subgroup = (battery_powered.is_se and "electronic") or "intermediate-product"

local group_charged = (battery_powered.is_se and "resource") or "intermediate-products"
local subgroup_charged = (battery_powered.is_se and "fuel") or "intermediate-product"

local order = (battery_powered.is_se and "f") or "h[battery]-"
local order_charged = (battery_powered.is_se and "q") or "h[battery]-"

-- change existing items

local base_battery = data.raw.item["battery"]
base_battery.order = order.."a-a"
base_battery.subgroup = subgroup

if battery_powered.is_k2 then
    battery = data.raw.item["kr-lithium-sulfur-battery"]
    battery.group = group
    battery.subgroup = subgroup
    battery.order = order.."a-b"
end

-- function to define new items and recipes

local create_battery = function (p)
    local name, name_charged, weight

    if not p.use then
        name = "bp-"..p.prefix.."-battery"
        name_charged = "bp-charged-"..p.prefix.."-battery"
        weight = p.weight
    else
        name = p.use
        name_charged = "bp-charged-"..(p.prefix and (p.prefix .. "-") or "").."battery"
        local used_item = data.raw.item[p.use]
        weight = used_item.weight or p.weight
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
        order = order.."a-"..p.order,
        weight = weight,
    }

    local produce_battery = {
        type = "recipe",
        name = name,
        results = {
            { type = "item", name = name, amount = 1 }
        },
        order = "h[battery]-a-"..p.order,
        category = p.recipe_category or "crafting-with-fluid",
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
        group = group_charged,
        subgroup = subgroup_charged,
        order = order_charged.."b-"..p.order,
        burnt_result = name,
        fuel_value = p.fuel .. "MJ",
        fuel_category = "battery",
        fuel_emissions_multiplier = 0,
        fuel_acceleration_multiplier = p.acceleration,
        fuel_top_speed_multiplier = p.top_speed,
        weight = weight,
    }

    local charge_battery = {
        type = "recipe",
        name = name_charged,
        results = {
            { type = "item", name = name_charged, amount = 1, probability = (is_decay and p.probability) or 1 },
        },
        order = order.."b-"..p.order,
        category = "charging",
        enabled = false,
        always_show_made_in = true,
        show_amount_in_title = false,
        always_show_products = true,
        ingredients = {
            { type="item", name = name, amount = 1 }
        },
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
            -- order = "h[battery]-a-"..p.order,
            category = "hard-recycling",
            subgroup = battery_powered.is_se and "recycling" or subgroup,
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

-- define batteries

create_battery({
    use = "battery",
    prefix = false,
    tech = "electric-energy-accumulators",
    probability = 0.98,
    recipe_tint = {0xB2,0x53,0x36},
    order = "a",
    -- a little better than coal :-)
    stack = 50,
    fuel = (battery_powered.is_k2 and 15) or 5, -- compensate for the huge fuel stack size in K2
    acceleration = 1.10,
    top_speed = (battery_powered.is_k2 and 0.95) or 1.05,
    weight = 5 * kg,
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
        -- 2MJ less energy density than solid fuel, 20% more acceleration, 5% more speed
        stack = 50,
        fuel = 10,
        acceleration = 1.4,
        top_speed = 1.10,
        weight = 2.5 * kg,
    })
else
    create_battery({
        use = "kr-lithium-sulfur-battery",
        prefix = "kr-lithium-sulfur",
        tech = "kr-lithium-sulfur-battery",
        probability = 0.99,
        recipe_tint = {0xE6,0xBA,0x39},
        order = "b",
        -- compared to K2 advanced fuel: 50% density (200x15), +25% acceleration (1.25), -10% top speed (1.25)
        stack = 50,
        fuel = 30,
        acceleration = 1.50,
        top_speed = 1.15,
        weight = 2.5 * kg,
    })

    local charged = data.raw.item["bp-charged-kr-lithium-sulfur-battery"]
    -- straight out of  __Krastorio2__/compatibility-scripts/data-final-fixes/IndustrialRevolution.lua
    charged.icon = battery_powered.k2_path .. "compatibility/IndustrialRevolution/charged-lithium-sulfur-battery.png"
    charged.icon_size = 64
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

if battery_powered.is_age then
    create_battery({
        prefix = "holmium",
        tech = "electromagnetic-plant",
        ingredients = {
            {type = "item",  name = "supercapacitor", amount =   1},
            {type = "item",  name = "holmium-plate",  amount =   1},
            {type = "fluid", name = "electrolyte",    amount =  10},
        },
        probability = 0.995,
        recipe_tint = {0xec, 0x69, 0xab},
        recipe_category = "electromagnetics",
        order = "c",
        -- same energy density as rocket fuel, same acceleration and speed
        stack = 20,
        fuel = 50,
        -- K2: more acceleration but less top speed than advanced fuel
        acceleration = 1.80,
        top_speed = 1.15,
        weight = 2 * kg,
    })

elseif battery_powered.is_se then
    create_battery({
        prefix = "holmium",
        tech = "se-space-accumulator",
        ingredients = {
            {type = "item",  name = "se-heat-shielding", amount =   1},
            {type = "item",  name = "glass",             amount =   1},
            {type = "item",  name = "se-holmium-plate",  amount =   2},
            {type = "fluid", name = "se-vitalic-acid",   amount =  10},
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
        acceleration = 1.80,
        top_speed = 1.15,
        weight = 2 * kg,
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
        acceleration = 2.20,
        top_speed = 1.15,
        weight = 1.5 * kg,
    })

end
