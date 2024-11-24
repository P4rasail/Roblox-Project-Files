local TypeInputHandler = {
	Pressed = {}
}

local Conditionals = require(script:WaitForChild("Conditionals"))

function CheckAlign(InputData,TypeEntry,EntryID)
	
	if typeof(TypeEntry.Data.Platform) == "nil" then return nil,{} end
	--print(TypeEntry)
	local AmountTimesNeeded = TypeEntry.Amount or 1
	local AmountMet = 0
	local InputsUsed = {}
	if not TypeInputHandler.Pressed[EntryID] then
		TypeInputHandler.Pressed[EntryID] = {}
	end
	local TabPressed = TypeInputHandler.Pressed[EntryID]
	for i,Input in InputData do
		if typeof(i) == "string" then continue end
		if table.find(Input.Enacted,EntryID) then
			print(Input.Enacted,EntryID)
			return 2
		end
		--print(InputData)
		if TypeEntry.Data.Value == Input.Value then
			local Func = Conditionals[TypeEntry.Data.Platform.Name]
			--if Func and Func(Input.Data,TypeEntry) then
			--print(TypeInputHandler)
			
			if TabPressed[TypeEntry.Data.Value] then
				local Tab = TabPressed[TypeEntry.Data.Value]
				AmountMet = Tab.Amount
			
			end
			--table.insert(Input.Enacted,EntryID)
			AmountMet += 1
			table.insert(InputsUsed,i)
			--table.remove(InputData,i)
			--print(AmountMet)
			--print(AmountTimesNeeded)

			
			if AmountMet >= AmountTimesNeeded then
				TabPressed[TypeEntry.Data.Value] = nil
				return true,InputsUsed
			else
				if not TabPressed[TypeEntry.Data.Value] then
					TabPressed[TypeEntry.Data.Value] = {
						Amount = 0
					}
				end
				local Tab = TabPressed[TypeEntry.Data.Value]

				if Tab.Task then
					task.cancel(Tab.Task)
				end
				Tab.Task = task.delay(TypeEntry.Time or 1e11,function()
					
					Tab.Amount = 0
					--print("TabNot")
				end)
				Tab.Amount = AmountMet
				
				
			end
		--end
	end
	end
	--print("FALSE HAHA")
return false,{}
end


function TypeInputHandler:Check(InputData,TypeEntries,ID)
	if TypeEntries.TypeInputs then
		TypeEntries = TypeEntries.TypeInputs
	end
	if not TypeEntries[1] then
		return CheckAlign(InputData,TypeEntries,ID)
	else
		local OliveBranch = false
		
		for i = 1, #TypeEntries do
			local v = TypeEntries[i]
			local TempBranch 
			if v[1] then
				TempBranch = TypeInputHandler:Check(InputData,v,ID)
				print(ID)
				print(InputData,v,#InputData)
				print(TempBranch)
				if TempBranch and TempBranch ~= 2 then
					--print("OliveBranch")
					OliveBranch = true
				elseif TempBranch == 2 then
					return 2 
				end
			else
				if v.ConditionalType == "Or" then
					if OliveBranch then return true end
				end
				TempBranch = CheckAlign(InputData,v,ID)
				--if TypeEntries[i + 1] and TypeEntries[i + 1].ConditionalBranch == "Or" then
				print(v,InputData,TempBranch,ID)
				if TempBranch and TempBranch ~= 2 then
					OliveBranch = true
				elseif TempBranch then
					return 2
				end
				--end
			end
			--print(TempBranch)
			
			if not TempBranch then
				repeat
					i += 1
				until not TypeEntries[i] or TypeEntries[i].ConditionalType == "Or"
				if not TypeEntries[i] then
					return false
				end
			else
				if not TypeEntries[i + 1] then
					return true
				end
			end
		end
	end
	return true
end

function TypeInputHandler:Cleanup()
	table.clear(Conditionals)
end

return TypeInputHandler
