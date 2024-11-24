local DefaultEntry = {
	
}
local function OverrideDefault(Entries)
	local Default = table.clone(DefaultEntry)
	for i,v in Entries do
		Default[i] = v
	end
	return Default
end

return {
	M1 = OverrideDefault({
		Type = "M1"
	}),
	M2 = OverrideDefault({
		Type = "M2"
	}),

}