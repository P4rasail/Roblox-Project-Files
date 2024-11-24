local RunService = game:GetService("RunService")

function AddInputs(CurrentInputs,Add)
	for i,v in Add do
		table.insert(CurrentInputs,v)
	end

end

function CompareInputs(Entry1,Entry2)
	if not Entry1 or not Entry2 then return end
	if Entry1.Platform.Name == Entry2.Platform.Name then
		if Entry1.Name == Entry2.Name then
			return true
		end
	end
end

return function(CharConfig)
	local Configs = script:WaitForChild("Configs")
	local TypeInputHandler = require(script:WaitForChild("TypeInputHandler"))
	local ClientManager = {
		InputList = {},
		ActionsDone = {},
		Look = CFrame.new(),
		MouseCF = CFrame.new()
	}
	--if typeof(Controller) == "table" then
	ClientManager.CurrentInputs = {

	}
	ClientManager.RecordedInputs = {}

	ClientManager.Config = {}
	local ValidifyInput = function(InputInfo)
		--print("ERE")
	end
	local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))

	Indexes:OnLoad(function()
		local function AddedV(v:ModuleScript)
			if v:IsA("ModuleScript") then
				repeat task.wait() 
				until _G.Enums

				local Req = require(v)
				--print(Req)
				for e,x in Req do
					local Valid = true
					--print(ClientManager)
					for a,k in ClientManager.Config do
						if Indexes.Modules.Util.Array:Compare(x,k.Data) then
							Valid = false
							break
						end
					end
					if Valid then
						table.insert(ClientManager.Config,x)
					end
					--print(ClientManager.Config)
				end
			end
		end
		for i,v in Configs:GetChildren() do
			--task.spawn(function()
			AddedV(v)
			--end)
		end
		Configs.ChildAdded:Connect(AddedV)
	end)
	
	ClientManager.Events = {}

	local function BranchValidify(Branch,InputInfo)
		if Branch.TypeInputs then
			Branch = Branch.TypeInputs
		end

		local AllMet = false
		for i,v in Branch do
			if typeof(v) ~= "table" then return end
			if v.Data then
				local Result = CompareInputs(v.Data,InputInfo)
				if Result then
					return true end

			else 
				AllMet = BranchValidify(v,InputInfo)
				if AllMet then return true end
			end

		end
	end
	ValidifyInput = function(InputInfo)
		local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))

		_G.WaitUntil("IndexesLoaded")
		--print(ClientManager)
		--print(InputInfo)
		local IsMet =  BranchValidify(ClientManager.Config,InputInfo)
		--print(IsMet)
		return IsMet
			--[[for a,k in ClientManager.Config do
				for i,v in k.TypeInputs do
					--print(v)
					--print(InputInfo)
					if CompareInputs(v.Data,InputInfo) then
						--print(v)
						--print(InputInfo)
						return true
					end
				end
			end--]]
	end
	--end
	--if RunService:IsServer() then


	function ClientManager:AddInput(InputInfo,Holding)
		local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
		_G.WaitUntil("IndexesLoaded")
		--print(InputInfo)
		local Input = {
			Data = {}
		}

		for i,v in InputInfo do
			Input.Data[i] = v
		end
		Input.LastTiming = os.clock()
		Input.PressTime = 0
		--print(ClientManager.Config)
		--print(ClientManager.CurrentInputs)
		if not Holding then
			for i = 1,#(ClientManager.CurrentInputs) do
				local v = ClientManager.CurrentInputs[i]
				if not v then continue end
				if CompareInputs(v.Data,InputInfo) then
					table.remove(ClientManager.CurrentInputs,i)
					i -= 1
				end
			end
		end

		--print(Holding)
		if Holding then
			local Length = #(ClientManager.CurrentInputs)
			if Length > 0 then
				Input.PressTime = (Input.LastTiming - ClientManager.CurrentInputs[Length].LastTiming)
			end
			table.insert(ClientManager.CurrentInputs,Input)

		end
		--	print("IS IT HOLDING MY COCK??? ",Holding)
	end
	table.insert(ClientManager.Events,script.Parent:WaitForChild("Press").Event:Connect(function()

		local InputData = ClientManager.CurrentInputs


		local Entries = {}
		for e,x in ClientManager.Config do
			--print("TESTING THE NUTS OF ",x.Action)
			if TypeInputHandler:Check(InputData,x)  then
				--print("Added "..x.Action)
				table.insert(Entries,x)
			end
		end
		--print(ClientManager.CurrentInputs)
		--print(Entries)
		if #Entries == 0 then
			table.clear(ClientManager.ActionsDone)
			return end
		for i,v in ClientManager.ActionsDone do
			local Found
			for e,x in Entries do
				if x.Action == i then
					Found = true
					table.remove(Entries,e)
				end
			end
			if not Found then
				CharConfig:DoAction(i,{
					Holding = false
				})
				ClientManager.ActionsDone[i] = nil
			end
		end
		local HighestPriority = {}
		table.sort(Entries,function(Entry1,Entry2)
			local Priority = Entry1.Priority or 0
			local Priority2 = Entry1.Priority or 0
			return Priority > Priority2
		end)
		--print(Entries)
		for i,v in Entries do
			print(v.Action)
			ClientManager.ActionsDone[v.Action] = true
			CharConfig:DoAction(v.Action,{
				Holding = true
			})
		end
	end))

	local function Cleanup(CharConfig)
		for i,v in ClientManager.Events do
			v:Disconnect()
		end
		for i,v in ClientManager.CurrentInputs do
			table.clear(v)
		end
		table.clear(ClientManager.CurrentInputs)
		table.clear(ClientManager.Config)
		table.clear(ClientManager)


	end
	task.spawn(function()
		local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
		_G.WaitUntil("IndexesLoaded")
		Indexes.Modules.Util.Array:AddCleanupFunc(ClientManager,Cleanup)
	end)

	

	return ClientManager
end
