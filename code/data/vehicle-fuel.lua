local vehicles = {
	locomotive = "locomotive",
	car = "car",
	tank = "car",
}

local function modify_vehicle(prototype)
	local b = prototype.burner
	if b.fuel_categories then
		table.insert(b.fuel_categories, "battery")
	else
		b.fuel_categories = {b.fuel_category, "battery"}
		b.fuel_category = nil
	end

	if not b.burnt_inventory_size or b.burnt_inventory_size < 1 then
		b.burnt_inventory_size = 1
	end
end

for name, vehicle in pairs(vehicles) do
	local prototype = data.raw[vehicle][name]
	if prototype and prototype.burner then
		modify_vehicle(prototype)
	end
end

for _, prototype in pairs(data.raw.locomotive) do
    if prototype.burner and (
        -- Angel's Mass Transit
        string.match(prototype.name, "^smelting%-locomotive")
        or string.match(prototype.name, "^petro%-locomotive")
        or string.match(prototype.name, "^crawler%-locomotive"))
    then
		modify_vehicle(prototype)
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------

