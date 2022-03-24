local subgroup = mods["space-exploration"] and "solar" or "energy"

local function charger_discharger_picture(prefix, is_discharger, repeat_count, tint)
    local typename = ((is_discharger and "dis") or "") .. "charger"
    local filename = prefix .. typename

    return
    {
      layers =
      {
        {
          filename = battery_powered.entity_path.."/hr-"..filename..".png",
          priority = "high",
          width = 128,
          height = 192,
          repeat_count = repeat_count,
          shift = util.by_pixel(0, -16),
          tint = tint,
          animation_speed = is_discharger and 0.25 or 0.5,
          scale = 0.5
        },
        {
          filename = battery_powered.entity_path.."/hr-"..typename.."-shadow.png",
          priority = "high",
          width = 256,
          height = 128,
          repeat_count = repeat_count,
          shift = util.by_pixel(32, 0),
          draw_as_shadow = true,
          scale = 0.5
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
          filename = battery_powered.entity_path.."/hr-charger-fizzle.png",
          priority = "high",
          width = 143,
          height = 192,
          line_length = 6,
          frame_count = 24,
          draw_as_glow = true,
          shift = util.by_pixel(0, -16),
          scale = 0.5
        },
        {
          filename = battery_powered.entity_path.."/hr-charger-worklight.png",
          priority = "high",
          width = 128,
          height = 192,
          line_length = 6,
          frame_count = 24,
          apply_runtime_tint = true,
          -- half speed compared to lightning
          frame_sequence = { 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 5, 5, 4, 4, 3, 3, 2, 2, 1, 1 },
          draw_as_glow = true,
          shift = util.by_pixel(0, -16),
          scale = 0.5,
          tint = { r = 0.6, g = 1.0, b = 0.95, a = 1 },
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
          filename = battery_powered.entity_path.."/hr-discharger-lightning.png",
          priority = "high",
          width = 128,
          height = 192,
          line_length = 6,
          frame_count = 24,
          draw_as_glow = true,
          -- blend_mode = "additive",
          shift = util.by_pixel(0, -16),
          scale = 0.5,
          -- electric light green-blue
          tint = { r = 0.60, g = 1.00, b = 0.95, a = 1 }
        },
        {
          filename = battery_powered.entity_path.."/hr-discharger-worklight.png",
          priority = "high",
          width = 128,
          height = 192,
          line_length = 6,
          frame_count = 24,
          apply_runtime_tint = true,
          frame_sequence = { 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6, 6, 5, 5, 4, 4, 3, 3, 2, 2, 1, 1 },
          draw_as_glow = true,
          shift = util.by_pixel(0, -16),
          scale = 0.5,
          tint = { r = 0.60, g = 1.00, b = 0.95, a = 1 },
        }

        -- yellow  tint = { r = 1.00, g = 0.81, b = 0.60, a = 0.5 }
        -- holmium tint = { r = 0.99, g = 0.60, b = 1.00, a = 0.5 }
        -- naquium tint = { r = 0.30, g = 0.34, b = 1.00, a = 1.0 }
        -- naquium brighter tint = { r = 0.65, g = 0.60, b = 1.0, a = 1 }
      }
    }
  end

local charger_discharger = function(p)
    local base = data.raw.accumulator[p.based_on]

    local prefix = ""
    if (p.prefix) then
        prefix = p.prefix.."-"
    end

    local charger_name = "bp-"..prefix.."battery-charger"

    local charger = {
        name = charger_name,
        type = "furnace", -- "assembling-machine",
        icon = battery_powered.icon_path .. charger_name .. ".png",
        icon_size = 64,
        -- icon_mipmaps = base.icon_mipmaps,
        placeable_by = { item = charger_name, count = 1 },
        minable = { 
            mining_time = base.minable.mining_time,
            result = charger_name 
        },
        flags = {"placeable-neutral", "player-creation"},
        fast_replaceable_group = "battery-charger",
        next_upgrade = p.next_prefix and ("bp-"..p.next_prefix.."-battery-charger"),
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
          sound = { filename = "__base__/sound/accumulator-working.ogg", volume = 0.4 },
          max_sounds_per_type = 3,
          audible_distance_modifier = 0.5,
          fade_in_ticks = 4,
          fade_out_ticks = 20
        },
        se_allow_in_space = true,
    }

    local charger_item = {
        type = "item",
        name = charger_name,
        order = charger.order,
        subgroup = subgroup,
        stack_size = 50,
        icon = charger.icon,
        icon_size = charger.icon_size,
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

    data:extend({ charger , charger_item, charger_recipe, })
    add_unlock_to_tech(p.tech, charger_name)

    if settings.startup["battery-powered-dischargers"].value then
      local discharger_name = "bp-"..prefix.."battery-discharger"

      local discharger = {
          name = discharger_name,
          type = "burner-generator",
          icon = battery_powered.icon_path .. discharger_name .. ".png",
          icon_size = 64,
          --icon_mipmaps = 1,
          placeable_by = { item = discharger_name, count = 1 },
          minable = { mining_time = base.minable.mining_time, result = discharger_name },
          order = "z-battery-discharger-"..p.order,
          flags = {"placeable-neutral", "player-creation"},
          fast_replaceable_group = "battery-generator",
          next_upgrade = p.next_prefix and ("bp-"..p.next_prefix.."-battery-discharger"),
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
            sound = { filename = "__base__/sound/accumulator-idle.ogg", volume = 0.55 },
            max_sounds_per_type = 3,
            audible_distance_modifier = 0.5,
            fade_in_ticks = 4,
            fade_out_ticks = 20
          },        
          se_allow_in_space = true,
      }

      local discharger_item = {
          type = "item",
          name = discharger_name,
          order = discharger.order,
          subgroup = subgroup,
          stack_size = 50,
          icon = discharger.icon,
          icon_size = discharger.icon_size,
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

      data:extend({ discharger, discharger_item, discharger_recipe, })
      add_unlock_to_tech(p.tech, discharger_name)
    end
end

charger_discharger({
    prefix = false,
    next_prefix = "holmium",
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
        next_prefix = "naquium",
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

