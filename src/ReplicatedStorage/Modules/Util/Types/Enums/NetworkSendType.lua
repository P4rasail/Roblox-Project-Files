local DefaultEntry = {
	Name = "",
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
	Function = CreateEntry({
		Name = "Function"
	}),
	Event = CreateEntry({
		Name = "Event"
	}),
	FastEvent = CreateEntry({
		Name = "FastEvent"
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