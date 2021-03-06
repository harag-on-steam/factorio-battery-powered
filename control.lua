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
			"bp-charged-lithium-sulfur-battery",
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

	for tech, recipes in pairs(recipes_by_tech) do
		for _, force in pairs(game.forces) do
			local tech = force.technologies[tech]
			if tech and tech.researched then
				for _, recipe in pairs(recipes) do
					local recipe = force.recipes[recipe]
					if recipe then 
						recipe.enabled = true
					end
				end
			end
		end
	end
end

local function on_init()
	sync_recipes_with_research()
end

local function on_configuration_changed(change)
    sync_recipes_with_research()
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
