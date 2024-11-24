return function(Types,OverallEnums)
local DefaultEntry = {
	Size = Vector3.one
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

	Char = CreateEntry({
		Size = Vector3.one * 2
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