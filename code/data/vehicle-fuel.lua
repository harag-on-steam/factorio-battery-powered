local vehicles = {
	locomotive = "locomotive",
	car = "car",
	tank = "car",
}

for name, vehicle in pairs(vehicles) do
	local prototype = data.raw[vehicle][name]
	if prototype and prototype.burner then
		prototype.burner.fuel_category = nil
		prototype.burner.fuel_categories = {"chemical","battery"}
		prototype.burner.burnt_inventory_size = 1
	end
end

for _, prototype in pairs(data.raw.locomotive) do
    if prototype.burner and (
        -- Angel's Mass Transit
        string.match(prototype.name, "^smelting%-locomotive")
        or string.match(prototype.name, "^petro%-locomotive")
        or string.match(prototype.name, "^crawler%-locomotive"))
    then
        prototype.burner.fuel_category = nil
		prototype.burner.fuel_categories = {"chemical","battery"}
		prototype.burner.burnt_inventory_size = 1
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------

