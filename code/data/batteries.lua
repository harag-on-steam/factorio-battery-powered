data:extend({
    { type = "recipe-category", name = "charging", },
    { type = "fuel-category",   name = "battery",  },
})

local group = "intermediate-products"

local subgroup = "intermediate-product"
local subgroup_charged = mods["space-exploration"] and "processed-fuel" or "intermediate-product"

local base_battery = data.raw.item["battery"]
base_battery.order = "h[battery]-a-a"
base_battery.subgroup = subgroup

local create_battery = function (p)
    local name, name_charged

    if (p.prefix) then
        name = "bp-"..p.prefix.."-battery"
        name_charged = "bp-charged-"..p.prefix.."-battery"
    else 
        name = "battery"
        name_charged = "bp-charged-battery"
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
            { type = "item", name = name_charged, amount = 1, probability = p.probability or 1 },
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

    if name == "battery" then
        data:extend({charged_battery, charge_battery})
        add_unlock_to_tech(p.tech, name_charged)
    else
        data:extend({battery, produce_battery, charged_battery, charge_battery})
        add_unlock_to_tech(p.tech, name)
        add_unlock_to_tech(p.tech, name_charged)
    end
end

create_battery({
    prefix = false,
    tech = "electric-energy-accumulators",
    ingredients = {}, -- ignored, "battery" already exists
    probability = 0.98,
    recipe_tint = {0xB2,0x53,0x36},
    order = "a",
    -- a little better than coal :-)
    stack = 50,
    fuel = 5,
    acceleration = 1.10,
    top_speed = 1.05,
})

create_battery({
    prefix = "advanced",
    tech = "electric-energy-accumulators",
    ingredients = {
        {type = "item",  name = "steel-plate",   amount =  1},
        {type = "item",  name = "copper-plate",  amount =  2},
        {type = "item",  name = "plastic-bar",   amount =  2},
        {type = "fluid", name = "sulfuric-acid", amount = 40},
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

if mods["space-exploration"] then

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
        probability = 0.995,
        recipe_tint = {0xec, 0x69, 0xab},
        order = "c",
        -- half the energy density of rocket fuel, same acceleration and speed
        stack = 20,
        fuel = 50,
        acceleration = 1.80,
        top_speed = 1.15,
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
        probability = 0.998,
        recipe_tint = {0x89, 0x71, 0xc7},
        order = "d",
        -- 800MJ higher energy density than nuclear fuel, .3 less acceleration, same speed
        stack = 20,
        fuel = 100,
        acceleration = 2.20,
        top_speed = 1.15,
    })
    
end
