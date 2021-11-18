function add_unlock_to_tech(tech, recipe)
    local tech = data.raw.technology[tech]
    if not tech then
        error("Cannot add "..recipce.." to non-existent tech "..tech)
        return
	end

    tech.effects = tech.effects or {}
    table.insert(tech.effects, { 
        type = "unlock-recipe", 
        recipe = recipe 
    })
end
