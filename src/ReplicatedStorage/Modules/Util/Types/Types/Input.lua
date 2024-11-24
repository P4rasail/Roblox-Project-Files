local DefaultEntry = {
	Name = "",
	Value = 0,
	Position = UDim2.new()
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

	Keyboard = CreateEntry({
		Name = "Keyboard",
		Value = 1
	}),
	Mouse = CreateEntry({
		Value = 2,
		Name = "Mouse"}),
	Gamepad = CreateEntry({
		Value = 3,
		Name = "Gamepad"}),
	Phone = CreateEntry({
		Value = 4,
		Name = "Phone"}),



}
local Funcs = {
	Construct = function(Name:string)
		return Variables[Name]
	end,
}
return {
	Variables = Variables,
	Funcs = Funcs

}