local vehicles = {
	locomotive = {
		locomotive = true,
		-- se-space-trains
		["space-locomotive"] = true,
		["bob-locomotive-2"] = true,
		["bob-locomotive-3"] = true,
		["bob-armoured-locomotive"] = true,
		["bob-armoured-locomotive-2"] = true,
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

local supported_generators = {
	-- K2
	"small-portable-generator",
	"portable-generator",
	-- Portable Power Equipment 
	"portable-generator-equipment",
}

local slot_count = settings.startup["battery-powered-burnt-inventory-size"].value

local function has_value(table, value)
	for _, v in pairs(table) do
		if value == v then
			return true
		end
	end

	return false
end

local function modify_prototype(prototype)
	local b = prototype.burner
	if not b then return end

	if b.fuel_categories and not has_value(b.fuel_categories, "battery") then
		table.insert(b.fuel_categories, "battery")
	elseif b.fuel_category and b.fuel_category ~= "battery" then
		b.fuel_categories = { b.fuel_category, "battery"}
		b.fuel_category = nil
	else
        b.fuel_categories = { "chemical", "battery"} -- no fuel_category means default = "chemical"
    end

	if not b.burnt_inventory_size or b.burnt_inventory_size < slot_count then
		b.burnt_inventory_size = slot_count
	end
end

for _, vehicle in pairs({"locomotive", "car"}) do
	for _, prototype in pairs(data.raw[vehicle]) do
		if vehicles[vehicle][prototype.name] then
			modify_prototype(prototype)
		end

		for _, pattern in pairs(vehicle_matches[vehicle]) do
			if (string.match(prototype.name, pattern)) then
				modify_prototype(prototype)
			end
		end
	end
end

if settings.startup["battery-powered-equipment-fuel"].value then
    for _, name in pairs(supported_generators) do
        local entity = data.raw["generator-equipment"][name]
        if entity then
            modify_prototype(entity)
        end
    end
end