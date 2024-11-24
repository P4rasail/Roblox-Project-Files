local TypeInputHandler = {}

local Conditionals = require(script:WaitForChild("Conditionals"))

function CheckAlign(InputData,TypeEntry)
	--print(InputData,TypeEntry)
	if typeof(TypeEntry.Platform) == "nil" then return nil,{} end
	local AmountTimesNeeded = TypeEntry.Amount or 1
	local AmountMet = 0
	local InputsUsed = {}
	for i,Input in InputData do
		
		if TypeEntry.Platform.Name == Input.Data.Platform.Name and TypeEntry.Name == Input.Data.Name then
			local Func = Conditionals[TypeEntry.Platform.Name]
			--if Func and Func(Input.Data,TypeEntry) then
			AmountMet += 1
			table.insert(InputsUsed,i)
			--table.remove(InputData,i)
			if AmountMet >= AmountTimesNeeded then
				return true,InputsUsed
			end
		--end
	end
	end
	--print("FALSE HAHA")
return false,{}
end


function TypeInputHandler:Check(InputData,TypeEntries)
	if TypeEntries.TypeInputs then
		TypeEntries = TypeEntries.TypeInputs
	end
	if not TypeEntries[1] then
		return CheckAlign(InputData,TypeEntries.Data)
	else
		local OliveBranch = true
		
		for i = 1, #TypeEntries do
			local v = TypeEntries[i]
			local TempBranch 
			if v[1] then
				TempBranch = TypeInputHandler:Check(InputData,v)
				
			else
				if v.ConditionalType == "Or" then
					if OliveBranch then return true end
				end
				TempBranch = CheckAlign(InputData,v.Data)
			end
			
			if not TempBranch then
				repeat
					i += 1
				until not TypeEntries[i] or TypeEntries[i].ConditionalType == "Or"
				if not TypeEntries[i] then
					return false
				end
			else
				
			end
		end
	end
	return true
end

function TypeInputHandler:Cleanup()
	table.clear(Conditionals)
end

return TypeInputHandler
