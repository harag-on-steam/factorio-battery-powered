local vehicles = {
	locomotive = {
		locomotive = true,
		-- se-space-trains
		["space-locomotive"] = true,
	},
	car = {
		-- vanilla
		car = true,
		tank = true,
		-- AAI
		-- ["vehicle-miner"] = true,
		["vehicle-hauler"] = true,
		["vehicle-warden"] = true,
		["vehicle-chaingunner"] = true,
		["vehicle-flame-tumbler"] = true,
		["vehicle-flame-tank"] = true,
		-- K2
		["kr-advanced-tank"] = true,
	},
}

local vehicle_matches = {
	locomotive = {
		-- Angel's Mass Transit
		"^smelting%-locomotive",
        "^petro%-locomotive",
        "^crawler%-locomotive",
	},
	car = {
		-- AAI
		-- "^vehicle%-miner%-mk",
	}
}

local function modify_vehicle(prototype)
	local b = prototype.burner
	if not b then return end

	if b.fuel_categories then
		table.insert(b.fuel_categories, "battery")
	elseif b.fuel_category then
		b.fuel_categories = { b.fuel_category, "battery"}
		b.fuel_category = nil
	else
        b.fuel_categories = { "chemical", "battery"} -- no fuel_category means default = "chemical"
    end

	if not b.burnt_inventory_size or b.burnt_inventory_size < 1 then
		b.burnt_inventory_size = 1
	end
end

for _, vehicle in pairs({"locomotive", "car"}) do
	for _, prototype in pairs(data.raw[vehicle]) do
		if vehicles[vehicle][prototype.name] then
			modify_vehicle(prototype)
		end

		for _, pattern in pairs(vehicle_matches[vehicle]) do
			if (string.match(prototype.name, pattern)) then
				modify_vehicle(prototype)
			end
		end
	end
end
