local subgroup = mods["space-exploration"] and "solar" or "energy"

local base_accumulator_path = "__base__/graphics/entity/accumulator/"

local function charger_discharger_picture(prefix, is_discharger, repeat_count, tint)
    local filename = prefix .. ((is_discharger and "dis") or "") .. "charger"

    return
    {
      layers =
      {
        {
          filename = battery_powered.entity_path.."/lr-"..filename..".png",
          priority = "high",
          width = 66,
          height = 94,
          repeat_count = repeat_count,
          shift = util.by_pixel(0, -10),
          tint = tint,
          animation_speed = 0.5,
          hr_version =
          {
            filename = battery_powered.entity_path.."/hr-"..filename..".png",
            priority = "high",
            width = 130,
            height = 189,
            repeat_count = repeat_count,
            shift = util.by_pixel(0, -11),
            tint = tint,
            animation_speed = 0.5,
            scale = 0.5
          }
        },
        {
          filename = base_accumulator_path.."accumulator-shadow.png",
          priority = "high",
          width = 120,
          height = 54,
          repeat_count = repeat_count,
          shift = util.by_pixel(28, 6),
          draw_as_shadow = true,
          hr_version =
          {
            filename = base_accumulator_path.."hr-accumulator-shadow.png",
            priority = "high",
            width = 234,
            height = 106,
            repeat_count = repeat_count,
            shift = util.by_pixel(29, 6),
            draw_as_shadow = true,
            scale = 0.5
          }
        },
      }
    }
  end
  
local function charger_anim(prefix)
    return
    {
      layers =
      {
        charger_discharger_picture(prefix, false, 24),
        {
          filename = base_accumulator_path.."accumulator-charge.png",
          priority = "high",
          width = 90,
          height = 100,
          line_length = 6,
          frame_count = 24,
          draw_as_glow = true,
          shift = util.by_pixel(0, -22),
          hr_version =
          {
            filename = base_accumulator_path.."hr-accumulator-charge.png",
            priority = "high",
            width = 178,
            height = 206,
            line_length = 6,
            frame_count = 24,
            draw_as_glow = true,
            shift = util.by_pixel(0, -22),
            scale = 0.5
          }
        }
      }
    }
  end
  
 local function discharger_anim(prefix)
    return
    {
      layers =
      {
        charger_discharger_picture(prefix, true, 24),
        {
          filename = base_accumulator_path.."accumulator-discharge.png",
          priority = "high",
          width = 88,
          height = 104,
          line_length = 6,
          frame_count = 24,
          draw_as_glow = true,
          shift = util.by_pixel(-2, -22),
          hr_version =
          {
            filename = base_accumulator_path.."hr-accumulator-discharge.png",
            priority = "high",
            width = 170,
            height = 210,
            line_length = 6,
            frame_count = 24,
            draw_as_glow = true,
            shift = util.by_pixel(-1, -23),
            scale = 0.5
          }
        }
      }
    }
  end

local charger_discharger = function(p)
    local base = table.deepcopy(data.raw.accumulator[p.based_on])

    local prefix = ""
    if (p.prefix) then
        prefix = p.prefix.."-"
    end

    local charger_name = "bp-"..prefix.."battery-charger"

    local charger = {
        name = charger_name,
        type = "furnace", -- "assembling-machine",
        icon = base.icon,
        icon_size = base.icon_size,
        icon_mipmaps = base.icon_mipmaps,
        placeable_by = { item = charger_name, count = 1 },
        minable = { 
            mining_time = base.minable.mining_time,
            result = charger_name 
        },
        flags = {"placeable-neutral", "player-creation"},
        max_health = 150,
        corpse = base.corpse,
        dying_explosion = base.dying_explosion,
        collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
        selection_box = {{-1, -1}, {1, 1}},
        damaged_trigger_effect = table.deepcopy(base.damaged_trigger_effect),
        crafting_speed = p.crafting_speed,
        source_inventory_size = 1,
        result_inventory_size = 1,
        show_recipe_icon = false,
        crafting_categories = { "charging" },
        order = "z-battery-charger-"..p.order,
        energy_usage = p.energy_usage,
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            drain = "0kW",
        },

        drawing_box = {{-1, -1.5}, {1, 1}},
        match_animation_speed_to_activity = false,
        idle_animation = charger_discharger_picture(prefix, false, 24),
        animation = charger_anim(prefix),
        water_reflection = table.deepcopy(base.water_reflection),

        vehicle_impact_sound = base.vehicle_impact_sound,
        open_sound = base.open_sound,
        close_sound = base.close_sound,

        working_sound = {
            sound = { filename = battery_powered.sound_path.."/machine.ogg", volume = 0.95 },
            fade_in_ticks = 10,
            fade_out_ticks = 30,
        },
        se_allow_in_space = true,
    }

    local charger_item = {
        type = "item",
        name = charger_name,
        order = charger.order,
        subgroup = subgroup,
        stack_size = 50,
        icon = base.icon,
        icons = base.icons,
        icon_size = base.icon_size,
        icon_mipmaps = base.icon_mipmaps,
        place_result = charger_name,
    }

    local charger_recipe = {
        type = "recipe",
        name = charger_name,
        order = charger.order,
        subgroup = subgroup,
        result = charger_name,
        result_count = 1,
        category = "crafting",
        enabled = false,
        ingredients = p.ingredients or p.ingredients_charger,
        energy_required = 8,
    }

    local discharger_name = "bp-"..prefix.."battery-discharger"

    local discharger = {
        name = discharger_name,
        type = "burner-generator",
        icon = base.icon,
        icon_size = base.icon_size,
        icon_mipmaps = base.icon_mipmaps,
        placeable_by = { item = discharger_name, count = 1 },
        minable = { mining_time = base.minable.mining_time, result = discharger_name },
        order = "z-battery-discharger-"..p.order,
        flags = {"placeable-neutral", "player-creation"},
        max_health = 150,
        corpse = base.corpse,
        dying_explosion = base.dying_explosion,
        collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
        selection_box = {{-1, -1}, {1, 1}},
        damaged_trigger_effect = table.deepcopy(base.damaged_trigger_effect),
        effectivity = 1,
        energy_source = {
            type = "electric",
            usage_priority = "tertiary",
            drain = "0kW",
        },
        max_power_output = p.energy_usage,
        burner = {
            emissions_per_minute = 0,
            fuel_category = "battery",
            fuel_inventory_size = 1,
            burnt_inventory_size = 1,
            type = "burner",
            light_flicker = {
                minimum_intensity = 0,
                maximum_intensity = 0,
            },
        },

        drawing_box = {{-1, -1.5}, {1, 1}},
        min_perceived_performance = 1,
        idle_animation = charger_discharger_picture(prefix, true, 24),
        animation = discharger_anim(prefix),
        water_reflection = table.deepcopy(base.water_reflection),

        vehicle_impact_sound = base.vehicle_impact_sound,
        open_sound = base.open_sound,
        close_sound = base.close_sound,

        working_sound = {
            sound = { filename = battery_powered.sound_path.."/machine.ogg", volume = 0.95 },
            fade_in_ticks = 10,
            fade_out_ticks = 30,
        },
        se_allow_in_space = true,
    }

    local discharger_item = {
        type = "item",
        name = discharger_name,
        order = discharger.order,
        subgroup = subgroup,
        stack_size = 50,
        icon = base.icon,
        icons = base.icons,
        icon_size = base.icon_size,
        icon_mipmaps = base.icon_mipmaps,
        place_result = discharger_name,
    }

    local discharger_recipe = {
        type = "recipe",
        name = discharger_name,
        order = discharger.order,
        subgroup = subgroup,
        result = discharger_name,
        result_count = 1,
        category = "crafting",
        enabled = false,
        ingredients = p.ingredients or p.ingredients_discharger,
        energy_required = 8,
    }
    data:extend({ 
        charger , charger_item, charger_recipe, 
        discharger, discharger_item, discharger_recipe,
    })

    add_unlock_to_tech(p.tech, charger_name)
    add_unlock_to_tech(p.tech, discharger_name)
end

charger_discharger({
    prefix = false,
    based_on = "accumulator",
    order = "a",
    ingredients = {
        {"copper-cable", 30},
        {"electronic-circuit", 2},
        {"iron-plate", 2},
    },        
    crafting_speed = 0.5,
    energy_usage = "500kW",
    tech = "electric-energy-accumulators",
})

if mods["space-exploration"] then
    charger_discharger({
        prefix = "holmium",
        based_on = "se-space-accumulator",
        order = "b",
        ingredients_charger = {
            {"se-heavy-girder", 6},
            {"se-holmium-cable", 40},
            {"processing-unit", 2},
            {"bp-battery-charger", 1},
        },
        ingredients_discharger = {
          {"se-heavy-girder", 6},
          {"se-holmium-cable", 40},
          {"processing-unit", 2},
          {"bp-battery-discharger", 1},
        },
        crafting_speed = 2.5,
        energy_usage = "2500kW",
        tech = "se-space-accumulator",
    })

    charger_discharger({
        prefix = "naquium",
        based_on = "se-space-accumulator-2",
        ingredients_charger = {
          {"se-superconductive-cable", 8},
          {"se-naquium-cube", 1},
          {"se-quantum-processor", 1},
          {"bp-holmium-battery-charger", 1},
        },
        ingredients_discharger = {
          {"se-superconductive-cable", 8},
          {"se-naquium-cube", 1},
          {"se-quantum-processor", 1},
          {"bp-holmium-battery-discharger", 1},
        },
        order = "c",
        crafting_speed = 10,
        energy_usage = "10MW",
        tech = "se-space-accumulator-2",
    })
end



------------------------------------------------------------------------------------------------------------------------------------------------------

