
return function(Types,OverallEnums)
repeat task.wait()

	until OverallEnums.Platform
local Exclusive = {
	ButtonA = "Gamepad",
	ButtonB = "Gamepad",
	ButtonY = "Gamepad",
	ButtonX = "Gamepad",
DPadUp = "Gamepad",
DPadRight = "Gamepad",
DPadDown = "Gamepad",
DPadLeft = "Gamepad"
}



local function CreateEntry(Entries)

	local DefaultEntry = {
		Name = "",
		Value = 0,
			Platform = OverallEnums.Platform.Keyboard
	}
	if not Entries then return DefaultEntry end
	for i,v in Entries do
		DefaultEntry[i] = v
	end
	return DefaultEntry
end

local Enums = {

	

}
local Amount = 0
for i,v in Enum.KeyCode:GetEnumItems() do
	Amount += 1
	local Entry = CreateEntry({
		Name = v.Name,
		Value = Amount,
		Platform = OverallEnums.Platform[v.EnumType == "KeyCode" and "Keyboard" or v.EnumType]
	})
	if Exclusive[v.Name] then
			Entry.Platform = OverallEnums.Platform[Exclusive[v.Name]]
	end
	Enums[v.Name] = Entry
end

	for i,v in Enum.UserInputType:GetEnumItems() do
		Amount += 1
		local Entry = CreateEntry({
			Name = v.Name,
			Value =Amount,
			Platform = "Mouse"
		})
		if Exclusive[v.Name] then
			Entry.Platform = OverallEnums.Platform[Exclusive[v.Name]]
		end
		Enums[v.Name] = Entry
	end

local Funcs = {
	Construct = function(Name:string)
		return Enums[Name]
		
	end,
	
}
return {
	Enums = Enums,
	Funcs = Funcs
	
}
end