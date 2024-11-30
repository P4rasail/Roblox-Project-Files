local TypeInputHandler = {
	Pressed = {}
}

local Conditionals = require(script:WaitForChild("Conditionals"))

function CheckAlign(InputData,TypeEntry,EntryID,Holdable,Config)
	Config = Config or {}
	
	if typeof(TypeEntry.Data.Platform) == "nil" then return nil,{} end
	--print(TypeEntry)

	local AmountTimesNeeded = TypeEntry.Amount or 1
	local AmountMet = 0
	local InputsUsed = {}
	if not TypeInputHandler.Pressed[EntryID] then
		TypeInputHandler.Pressed[EntryID] = {}
	end
	local TabPressed = TypeInputHandler.Pressed[EntryID]
local EnactedPressed = false
	for i,Input in pairs(InputData) do
		
		if table.find(Input.Enacted,EntryID) and not Config.MultiKeyActivation then
			EnactedPressed = true
			if Holdable then 
				--print(EntryID) 
				return true,InputsUsed 
			end
			continue --return 2,InputsUsed
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
			
			
			AmountMet += 1
			table.insert(InputsUsed,Input)
			--table.remove(InputData,i)
			--print(AmountMet)
			--print(AmountTimesNeeded)

			
			if AmountMet >= AmountTimesNeeded then
				--TabPressed[TypeEntry.Data.Value].Amount = 0
				table.insert(Input.Enacted,EntryID)
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
				if AmountTimesNeeded >= 1 then
					table.insert(Input.Enacted,EntryID)
					--return 2,InputsUsed
				end
				
			end
		--end
	end
	end
	if EnactedPressed and Holdable then
		return true,InputsUsed
	end
	--print("FALSE HAHA")
return false,{}
end

function TypeInputHandler:GetAllInputs(TypeEntries,InputData)
	local ValidData = {}
	for a,x in InputData do
		local Found = false
	for i,v in TypeEntries do
		if v[1] then
			local TempData = TypeInputHandler:GetAllInputs(v,InputData)
			for e,r in TempData do
				if not table.find(ValidData,r) then
					table.insert(ValidData,r)
				end
			end
		else
			--print(x,v)
			if v.Data and v.Data.Value == x.Value then
				if not table.find(ValidData,x) then
				table.insert(ValidData,x)
				break
				
				end
			end
		end
	end
	
	end
	return ValidData
end

function TypeInputHandler:Check(InputData,TypeEntries,ID,Holdable,Config)
	Holdable = Holdable or TypeEntries.Holdable
	local OldEntries = TypeEntries
	if TypeEntries.TypeInputs then
		TypeEntries = TypeEntries.TypeInputs
	end
	
	local TempBranch,TempUsed
	local InputsUsed = {}
	local function AddInputs()
		if TempUsed then
			for i,v in pairs(TempUsed) do
				if not table.find(InputsUsed,v) then
					table.insert(InputsUsed,v)
				end
			end
		end
	end
	Config = Config or {}
	if OldEntries.MultiKeyActivation then
		Config.MultiKeyActivation = true
	end
	if not TypeEntries[1] then
		--print(InputData,TypeEntries,ID,Holdable)
		return CheckAlign(InputData,TypeEntries,ID,Holdable,Config)
	else
		local OliveBranch = false
		
		for i = 1, #TypeEntries do
			local v = TypeEntries[i]
			local v = TypeEntries[i]
			
			if v[1] then
				TempBranch,TempUsed = TypeInputHandler:Check(InputData,v,ID,nil,Config)
				--print(InputData)
				--print(TempBranch)
				if TempBranch and TempBranch ~= 2 then
					--print("OliveBranch")
					AddInputs()
					OliveBranch = true
				elseif TempBranch == 2  then
					return 2 
				end
			else
				AddInputs()
				if v.ConditionalType == "Or" then
					if OliveBranch then return true,InputsUsed end
				end
				TempBranch,TempUsed = CheckAlign(InputData,v,ID,Holdable,Config)
				if ID == "Flight" then
				--print(InputData,v,TempBranch,#InputData)
				end
				--if TypeEntries[i + 1] and TypeEntries[i + 1].ConditionalBranch == "Or" then
				
				if TempBranch and TempBranch ~= 2 then
				
					OliveBranch = true
				end
				--end
			end
			--print(TempBranch)
			
			if not TempBranch then
				repeat
					i += 1
				until not TypeEntries[i] or TypeEntries[i].ConditionalType == "Or"
				if not TypeEntries[i] then
					return false,InputsUsed
				end
			elseif TempBranch ~= 2 then
				AddInputs()
				if not TypeEntries[i + 1] then
					return true,InputsUsed
				end
			end
		end
	end
	return true,InputsUsed
end

function TypeInputHandler:Cleanup()
	table.clear(Conditionals)
end

return TypeInputHandler