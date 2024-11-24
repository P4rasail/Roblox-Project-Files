local DefaultEntry = {
	Name = "",
	Extend = ""
}

local function CreateEntry(Entries)
	local DefaultEntry = table.clone(DefaultEntry)
	if not Entries then return DefaultEntry end
	for i,v in Entries do
		DefaultEntry[i] = v
	end
	return DefaultEntry
end

local Enums = {
	Vel = CreateEntry({
		Name = "Vel",
		Extend = "Vel"
	}),
	Gyro = CreateEntry({
		Name = "Gyro",
		Extend = "Gyro"
	}),
	Accel = CreateEntry({
		Name = "Accel",
		Extend = "Vel"
	}),

}
local Funcs = {
	Construct = function(Name:string)
		return Enums[Name]
	end,
}

return {
	Enums = Enums,
	Funcs = Funcs
	
}