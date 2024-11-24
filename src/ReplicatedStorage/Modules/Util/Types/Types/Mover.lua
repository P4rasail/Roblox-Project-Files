return function(Types,OverallEnums)
local DefaultEntry = {
	Name = "",
	Priority = 0,
}
local function CreateEntry(Entries)
	local DefaultEntry = table.clone(DefaultEntry)
	if not Entries then return DefaultEntry end
	for i,v in Entries do
		DefaultEntry[i] = v
	end
	return DefaultEntry
end



local Variables = {

	Basic = CreateEntry({
		Priority = 1,
	}),
	Flight = CreateEntry({
		Priority = 5,
		Name = "Flight"
	}),
	Stun = CreateEntry({
		Priority = 10,
		Name = "Stun"
	}),
}




local Funcs = {
	Construct = function(Name)
		if typeof(Name) == "string" then
		return Variables[Name]
		else
			return CreateEntry(Name)
		end
	end,
}
return {
	Variables = Variables,
	Funcs = Funcs

}
end