local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local NPCObject = {
	InputList = {},
	CurrentInputs = {},
	ActionsDone = {},
	Configs = {},
	DataStore = {},
	InputMappings = {},
	CurrentData = {
		
	},
	Decider = function(...)
		
	end,
	CurrentCost = 0,
	Costs = {}
	
}




function NPCObject:Press(Key,Options)
	Options = Options or {}
	--print(Key,Options)
	--print(Indexes.Modules)
	Indexes.Modules.Systems.InputHandler.AddInputExtra(NPCObject,Key,Options.Holding)
	
end

function NPCObject:Decide()
	if NPCObject.Decider then
		NPCObject.CurrentCost = 0
		NPCObject.Decider(NPCObject)
	end
	
end
function NPCObject:Train(Data,Config)
	
end

function NPCObject:SendData(Data)
	
	_G.Types.NodeMatrix(Data.Matrix)
	NPCObject.DataManager:Transform(nil,Data,function(CurrentData,Data)
		_G.Types.NodeMatrix(CurrentData)
		
		
	end)
end

if not NPCObject.Running then
	NPCObject.Running = true
	Indexes:OnLoad(function()
		--[[
		Useful Funcs
		]]
		local function ConfigAdded(v:ModuleScript,TabIndex)
			if v:IsA("ModuleScript") then
				local Req = require(v)
				local Tab = TabIndex or {}
				for i,v in Req do
					if typeof(i) == "number" then
					table.insert(Tab,v)
					elseif typeof(v) == "table" and typeof(Tab[i]) == "table" then
						Indexes.Modules.Util.Array:Override(Tab[i],v)
					else
						Tab[i] = v
					end
					
				end
				--print(Tab)
				TabIndex = Tab
				if #(v.Parent:GetChildren()) > 1 then
					v:Destroy()
				end
			end
		end
		local function FuncAdded(v:ModuleScript,Tab,Index)
			if v:IsA("ModuleScript") then
				local Req = require(v)
				local Func = Tab[Index] or function()
					
				end
				Func = function(...)
					
					Func(...)
					Req(...)
				end
				
				if #(v.Parent:GetChildren()) > 1 then
					v:Destroy()
				end
			end
		end
		

--[[
		Config Added
		]]
		for i,v in script:WaitForChild("Configs"):GetChildren() do
			ConfigAdded(v,NPCObject.Configs)
		end
		script.Configs.ChildAdded:Connect(function(child)
			ConfigAdded(child,NPCObject.Configs)
		end)
		
		--[[
		DataStore Added
		]]
		for i,v in script:WaitForChild("DataStore"):GetChildren() do
			ConfigAdded(v,NPCObject.DataStore)
		end
		script.DataStore.ChildAdded:Connect(function(child)
			ConfigAdded(child,NPCObject.DataStore)
		end)
		
		for i,v in script:WaitForChild("Deciders"):GetChildren() do
			FuncAdded(v,NPCObject,"Decider")
		end
		script.Deciders.ChildAdded:Connect(function(child)
			FuncAdded(child,NPCObject,"Decider")
		end)
		--[[
		Adding data to thing
		]]
		repeat task.wait() until NPCObject.DataStore and NPCObject.DataStore.Name
		NPCObject.DataManager =  Indexes.ServerModules.Systems.DataManager("NPCNeural"..NPCObject.DataStore.Name,NPCObject.DataStore)
		NPCObject.DataManagerAmount =  Indexes.ServerModules.Systems.DataManager("NPCNeuralAmount"..NPCObject.DataStore.Name,NPCObject.DataStore)
		local Data =NPCObject.DataManagerAmount:Get(nil) or {}
		NPCObject.CurrentData.AmountDimensions = Data.AmountDimensions or 3
		
		NPCObject.CurrentData.Matrix = _G.Types.NodeMatrix(NPCObject.CurrentData.AmountDimensions)
		repeat task.wait()
		--print(script.Parent)
		
		until script.Parent:IsA("Model")
		NPCObject.CharConfig = _G.Modules.Systems.CharacterManager(script.Parent).Data
		
		
		NPCObject.Task = task.spawn(function()
			while NPCObject.CharConfig.Controller and NPCObject.CharConfig.Controller.Parent do
				task.wait(.04)
				
			end
		end)
		
		local function InitAdded(v:ModuleScript)
			if v:IsA("ModuleScript") then
				task.spawn(require(v),NPCObject)
			end
		end
		for i,v in script:WaitForChild("Init"):GetChildren() do
			InitAdded(v)
		end
		script.Init.ChildAdded:Connect(InitAdded)
		local function Added(v)
			if v:IsA("ModuleScript") then
				v = require(v)
				for e,x in v do
					table.insert(NPCObject.InputMappings,x)
				end
			end
		end
		for i,v in script:WaitForChild("InputMappings"):GetChildren() do
			Added(v)
		end
		script.InputMappings.ChildAdded:Connect(Added)
		for i,v in Indexes.Modules.Configs.Inputs:GetChildren() do
			local Clone = v:Clone()
			Clone.Parent = script.InputMappings

		end
		NPCObject.Loaded = true
	end)
end

return NPCObject
