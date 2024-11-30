--[[
   Creator: Paras/P4rasail
   Date: 2023/10/10
   Description: InputHandler module for managing user inputs.
   Functions: AddInput, Verify, AddFunction
   Example: InputHandler:AddInput(inputObject, true)
   Generated by Copilot
]]

local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
local TypeInputHandler =  require(script:WaitForChild("TypeInputHandler"))

local InputHandler = {
	InputList = {},
	Funcs = {},
	Tickets = {},
	Configs = {},
	ActionsDone = {},
	CurrentInputs = {},
	InputAddons = {}
}




local InputFormats = {
	["Type"] = {

		"UserInputType",
		"Name"
	},
	["Key"] = {
		"KeyCode",
		"Name"
	}
}


local function SolveEntry(Input,Info,Index,Format)
	if not Input or not Info or not Index or not Format then return end
	local Entry = InputFormats[Index]
	local Val =  Input
	if typeof(InputFormats[Index]) == "table" then
		for i,v in InputFormats[Index] do
			Val = Val[v]
		end
	else
		Val = Val[Format]
	end
	Info[Index] = Val

end

local function GetInputInfo(Input:InputObject)
	local Info = {}
	for i,v in InputFormats do
		SolveEntry(Input,Info,i,v)
	end
	return Info
end
function InputHandler:SetupChar(CharConfig)
	InputHandler.CharConfig = CharConfig
end
function CompareInputs(Entry1,Entry2)
	if not Entry1 or not Entry2 then return end
	if not Entry1.Platform or not Entry2.Platform then return end
	if Entry1.Platform.Name == Entry2.Platform.Name then
		if Entry1.Name == Entry2.Name then
			return true
		end
	end
end
local function BranchValidify(Branch,InputInfo)
	------print(Branch,InputInfo)
	if Branch.TypeInputs then
		Branch = Branch.TypeInputs
	end

	local AllMet = false
	for i,v in Branch do
		if typeof(v) ~= "table" then return end
		if v.Data then
			------print(InputInfo)
			local Result = CompareInputs(v.Data,InputInfo)
			if Result then
				return true end

		else 
			AllMet = BranchValidify(v,InputInfo)
			if AllMet then return true end
		end

	end
end
local ValidifyInput = function(InputInfo,Entries)
	local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))

	_G.WaitUntil("IndexesLoaded")
	------print(ClientManager)
	------print(InputInfo)
	local IsMet =  BranchValidify(Entries,InputInfo)
	------print(IsMet)
	return IsMet
			--[[for a,k in ClientManager.Config do
				for i,v in k.TypeInputs do
					------print(v)
					------print(InputInfo)
					if CompareInputs(v.Data,InputInfo) then
						------print(v)
						------print(InputInfo)
						return true
					end
				end
			end--]]
end

Indexes:OnLoad(function()
	
	------print("THERE")
	local AtOnce = 0
	function InputHandler:Verify(InputData,CharConfig,Configs,ActionsDone)

		if not CharConfig then return end

		CharConfig.Inputs.CurrentInputs = InputData
		local Entries = {}
		if not InputData.ActionsDone then
			InputData.ActionsDone = {}
		end
		for i,v in pairs(InputData) do
			if not v.Enacted then
				v.Enacted = {}
			end
		end
		--InputHandler.Configs
		local NotHolding = {}
		for e,x in pairs(Configs) do
			

			------print("TESTING THE NUTS OF ",x.Action)
			------print(x)
			------print(InputData)
			local Clone = table.clone(InputData)
			------print(InputData,Clone)
			local InputData2 = TypeInputHandler:GetAllInputs(x.TypeInputs,Clone,x.Action)
			------print(x.Action,InputData,InputData2)--,Result)
			for i,v in InputData2 do
				if not v["Enacted"] then
					v.Enacted = {}
				end
			end
			if #InputData2 == 0 then continue end
			local Result,InputsUsed = TypeInputHandler:Check(InputData2,x.TypeInputs,x.Action,x.Holdable,{
				MultiKeyActivation = x.MultiKeyActivation
			}) 
			
			------print(InputData,x.Action,x,Result,InputsUsed)
			
			------print(Result)
			--print(InputsUsed)
			for i,v in InputsUsed do
				--print(x,v)
				if v.Release and x.Holdable then
					--if v.Holdable then
						local Args = x.Args or {}
						Args = table.clone(Args)
						Args.Holding = false
						CharConfig:DoAction(x.Action,Args)
						
					--end
				else


				if x.Value == v.Value then
					InputData[e] = v
					break
				end
				
				end
			end
			if Result and Result ~= 2  then
				------print("Added "..x.Action)
				if InputsUsed then
				for i,v in InputsUsed do
					table.insert(v.Enacted,x.Action)
				end
				
				end
			--	----print(InputData)
				local Valid = true
				local Conditionals = x.Conditionals or {}
				local function SetCheck(InputData)
					--table.insert(Input.Enacted,EntryID)
					for i,v in InputData do
						local Result2,InputsUsed = TypeInputHandler:Check({v},x.TypeInputs,x.Action)
						----print(v,x.Action,Result2)
						if Result2 and Result2 ~= 2 then
							
							--table.insert(v.Enacted,x.Action)
						end
					end
				end
				
				for i,v in pairs(Conditionals) do
					local Type = v.Type
					if not Type then continue end
					if typeof(Type) == "string" then
						Type = {Type}
					end
					local Target = v.Target
					if typeof(Target) == "string" then
						Target = {Target}
					end
					local Valid2 = true
					local Object = v.Object or "CharacterManager"
					if not Target then continue end
					local OleV = v
					for i,v in pairs(Target) do
						if not Valid2 then break end
						local Targ
						if v == "CurrentUser" then
							Targ = CharConfig.Controller
						end
						------print(Targ)
						if Object == "CharacterManager" then
							Targ = Indexes.Modules.Systems.CharacterManager:GetController(Targ)
							Targ = Targ and Targ.Data 	
						end
						------print(Targ)
						if not Targ then Valid2 = false break end
						Valid2 = _G.Check(Type,Targ)
						------print(OleV)
Valid2 = OleV.Not and not Valid2 or Valid2
					end
					if not Valid2 then
						Valid = false
						break
					end
				end
				------print(x.Action)
				------print(Valid)
				if Valid then
					for i,v in InputData do
						
						if BranchValidify(x,v) then
							
							if not table.find(v.Enacted,x.Action) then
								table.insert(v.Enacted,x.Action)
							end
						end
						
					end
					table.insert(Entries,x)
				end
			elseif Result ~= 2 and x.Holdable then
				table.insert(NotHolding,x)
			end
			
		end
		for i,v in NotHolding do
			local Found = table.find(InputData.ActionsDone,v.Action)
			if Found then
				------print(x)
				table.remove(InputData.ActionsDone,Found)
				local Args = v.Args or {}
				table.clone(Args)
				Args.Holding = false
				CharConfig:DoAction(v.Action,Args)
			end
		end
		------print(ClientManager.CurrentInputs)
		------print(Entries)
		
		if #Entries == 0 then
			table.clear(ActionsDone)
			return end
		for i,v in pairs(ActionsDone) do
			local Found
			local Holdable

			for e,x in Entries do
				if x.Action == i then
					Found = true
					Holdable = x.Holdable
					table.remove(Entries,e)
				end
			end
			if not Found then

				if Holdable then
					local Args = v.Args or {}
					Args = table.clone(Args)
					Args.Holding = false
					CharConfig:DoAction(i,Args)
					
				end
				ActionsDone[i] = nil
			end
		end
		local HighestPriority = {}
		table.sort(Entries,function(Entry1,Entry2)
			local Priority = Entry1.Priority or 0
			local Priority2 = Entry1.Priority or 0
			return Priority > Priority2
		end)
		------print(Entries)
		for i,v in pairs(Entries) do
			------print(v.Action)
			table.insert(InputData.ActionsDone,v.Action)
			ActionsDone[v.Action] = true
			local Args = v.Args or {}
			Args = table.clone(Args)
			Args.Holding = true
			CharConfig:DoAction(v.Action,Args)
			
		end
	end
	function InputHandler:AddInput(Input:InputObject,Add)
		local Result = InputHandler.InputList[Input]
		AtOnce = _G.Indexes.Modules.Util.Array:CountTable(InputHandler.InputList,{
			NonRecursive = true
		})
		local Info
		
		------print(Input.KeyCode.Name)
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			Info = _G.Enums.Key[Input.KeyCode.Name]
		end
		if string.find(Input.UserInputType.Name,"Mouse") then
			Info = _G.Enums.Key[Input.UserInputType.Name]
		end
		for i,v in pairs(InputHandler.Funcs) do
			task.spawn(function()
				v.Call(Input,Add)
			end)
		end
local Fired = false
		if Add then

			if Info then
				Info = table.clone(Info)
				local Valid = true
				for i,v in pairs(InputHandler.CurrentInputs) do
					if v == Info then
						Valid = false

						break
					end
				end
				if Valid then
					table.insert(InputHandler.CurrentInputs,Info)
				end
			end
			if not Result then

				local Clone = script.InputExample:Clone()
				Clone.Owner.Value = script
				InputHandler.InputList[Input] = {
					Script = Clone
				}

				Clone.Name = "INPUTCLONE"
				Clone.Enabled = true
				Clone.Parent = game.Players.LocalPlayer.PlayerScripts
			end

		else
			if Info then
				------print(InputHandler.CurrentInputs)
				for i,v in InputHandler.CurrentInputs do
					------print(v,Info)
					if v.Value == Info.Value then
						--if v.Holdable then
							v.Release = true
							local OleInput = InputHandler
							Fired = true
							--print(v)
							OleInput:Verify(InputHandler.CurrentInputs,InputHandler.CharConfig,OleInput.Configs,InputHandler.ActionsDone)
						--	end
						table.remove(InputHandler.CurrentInputs,i)
					end
				end
				------print(InputHandler.CurrentInputs)
			end
			if Result then
				Result.Script:Destroy()
			end
			InputHandler.InputList[Input] = nil
		end
		if not Fired then
		script.Press:Fire()
		
		end
	end
	function InputHandler.AddInputExtra(self,Input,Add)
		local OleInput  = InputHandler
local InputHandler = self
------print(self)
		local Info
		------print(Input.KeyCode.Name)
		Info = _G.Enums.Key[Input]
		if Add then

			if Info then
				Info = table.clone(Info)
				local Valid = true
				for i,v in InputHandler.CurrentInputs do
					if v == Info then
						Valid = false

						break
					end
				end
				if Valid then
					table.insert(InputHandler.CurrentInputs,Info)
				end
			end
			

		else
			if Info then
				------print(InputHandler.CurrentInputs)
				for i,v in InputHandler.CurrentInputs do
					------print(v,Info)
					if v.Value == Info.Value then
						if v.Holdable then
						v.Release = true
						OleInput:Verify(InputHandler.CurrentInputs,InputHandler.CharConfig,OleInput.Configs,InputHandler.ActionsDone)
						end
						table.remove(InputHandler.CurrentInputs,i)
						break
					end
				end
				------print(InputHandler.CurrentInputs)
			end
			
		end
		
		OleInput:Verify(InputHandler.CurrentInputs,InputHandler.CharConfig,OleInput.Configs,InputHandler.ActionsDone)

	end
	function InputHandler:AddFunction(Func)
		if typeof(Func) ~= "function" then return end
		local Fold = Instance.new("Folder")
		Fold.Name = "IndexModule"
		Fold.Parent = script

		local Obj = _G.Indexes.Modules.Util.Signal(Fold)

		Obj.Disconnect = function()
			Obj.Cleanup()

		end
		Obj.Call = function(input,holding)
			Func(input,holding)
		end
		InputHandler.Funcs[Fold] = Obj
		return Obj



	end
	if game:GetService("RunService"):IsClient() then
	local Found = script:FindFirstChild("INPUTSTART")

	if Found then
		Found.Parent = game.Players.LocalPlayer.PlayerScripts
	end
	end
end)


if not InputHandler.Running then
	InputHandler.Running = true
	Indexes:OnLoad(function()
		local function Added(v)
			if v:IsA("ModuleScript") then
				v = require(v)
				for e,x in v do
					table.insert(InputHandler.Configs,x)
				end
			end
		end
		for i,v in pairs(script:WaitForChild("InputMappings"):GetChildren()) do
			Added(v)
		end
		script.InputMappings.ChildAdded:Connect(Added)
		script:WaitForChild("Press").Event:Connect(function()
			InputHandler:Verify(InputHandler.CurrentInputs,InputHandler.CharConfig,InputHandler.Configs,InputHandler.ActionsDone)
		end)		
		repeat task.wait() 
		
		until Indexes.Modules.Configs.Inputs
		
		
		for i,v in pairs(Indexes.Modules.Configs.Inputs:GetChildren()) do
			local Clone = v:Clone()
			Clone.Parent = script.InputMappings
			
		end
	end)
end


return InputHandler