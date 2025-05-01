require("code.globals")

local function sync_recipes_with_research()
	local recipes_by_tech = {
		["electric-energy-accumulators"] = {
			"bp-battery-charger",
			"bp-battery-discharger",
			"bp-charged-battery",
			"bp-advanced-battery",
			"bp-charged-advanced-battery",
		},
		["kr-lithium-sulfur-battery"] = {
			"bp-charged-kr-lithium-sulfur-battery",
		},
		["se-space-accumulator"] = {
			"bp-holmium-battery-charger",
			"bp-holmium-battery-discharger",
			"bp-holmium-battery",
			"bp-charged-holmium-battery",
		},
		["se-space-accumulator-2"] = {
			"bp-naquium-battery-charger",
			"bp-naquium-battery-discharger",
			"bp-naquium-battery",
			"bp-charged-naquium-battery",
		},
	}

	for tech_name, recipes in pairs(recipes_by_tech) do
		for _, force in pairs(game.forces) do
			local tech = force.technologies[tech_name]
			if tech and tech.researched then
				for _, recipe_name in pairs(recipes) do
					local recipe = force.recipes[recipe_name]
					if recipe then
						recipe.enabled = true
					end
				end
			end
		end
	end
end

if settings.startup["battery-powered-jetpack-fuel"].value then
	local fuels = {
		["bp-charged-battery"] = 1,
		["bp-charged-advanced-battery"] = (not battery_powered.is_k2) and 1 or nil,
		["bp-charged-kr-lithium-sulfur-battery"] = battery_powered.is_k2 and 1 or nil,
		["bp-charged-holmium-battery"] = (battery_powered.is_age or battery_powered.is_se) and 1.05 or nil,
		["bp-charged-naquium-battery"] = battery_powered.is_se and 1.10 or nil,
	}

	remote.add_interface("battery-powered", {
		jetpack_fuels = function() return fuels end,
	})
end

local function on_init()
	sync_recipes_with_research()
end

local function on_configuration_changed(change)
    sync_recipes_with_research()
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)

