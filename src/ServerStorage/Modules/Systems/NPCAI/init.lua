local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local NPCAI = {
	NPCs = {},
	Configs = {},
	
}

function ResolveConfig(Config)
	if typeof(Config) == "string" then
		Config = NPCAI.Configs[Config]
	end
	if Config then
		Config = Config:Clone()
	end
	return Config
end

function NPCAI:HookUp(Model:Model,Config)
	Config = Config or {}
	if not Model then return end
	if not Model:IsA("Model") or game.Players:GetPlayerFromCharacter(Model) then return end
	local Found = Model:FindFirstChild("NPCObject") 
	if Found then
		return require(Found)
	end
	Config = ResolveConfig(Config.Name)
	if not Config then 
		Config = ResolveConfig("Default")
	end
	
	local Clone = script.NPCObject:Clone()
	Config.Parent = Clone:WaitForChild("Configs")
	Config = require(Config)
	local Req = script:WaitForChild("Configs"):FindFirstChild(Model.Name)
	Config.Options = {}
	if Req then
for i,v in Req do
	Config.Options[i] = v
end
	end
	local NPCExternal = NPCAI.NPCs[Model.Name]
	Config.NPCConfigs = {}
	if NPCExternal then
		for i,v in NPCExternal do
			Config.NPCConfigs[i] = v
		end
	end
	if Config["Load"] then
		Config:Load(Clone)
	end
	Clone.Parent = Model
	
	return require(Clone)
	
	
	
end

if not NPCAI.Running then 
	NPCAI.Running = true
	local function Added(v:ModuleScript)
		if v:IsA("ModuleScript") then
			NPCAI.Configs[v.Name] = v
		end
	end
	for i,v in script:WaitForChild("Configs"):GetChildren() do
		Added(v)
	end
	script.Configs.ChildAdded:Connect(Added)
	
	local function AddedNPC(v:ModuleScript)
		if v:IsA("ModuleScript") then
			NPCAI.NPCs[v.Name] = require(v)
		end
	end
	for i,v in script:WaitForChild("NPCs"):GetChildren() do
		Added(v)
	end
	script.NPCs.ChildAdded:Connect(Added)
	
	setmetatable(NPCAI,{
		__call = function(...)
			
			return NPCAI.HookUp(...)
		end,
	})
end

return NPCAI
