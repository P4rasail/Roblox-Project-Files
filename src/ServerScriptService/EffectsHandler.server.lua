local RepStorage = game:GetService("ReplicatedStorage")

local Events = RepStorage:WaitForChild("Events")

local Indexes = require(RepStorage:WaitForChild("Indexes"))
repeat task.wait() until _G.Loaded

local ExcludePort = {}

for i,v in Indexes.ServerModules.Systems.EffectPlayer do
	if typeof(v) == "function" then
		Indexes.Modules.Systems.Networker:CreatePort(i,function(player:Player,Options)
if not player.Character then return end
			v(Indexes.ServerModules.Systems.EffectPlayer,player.Character,Options)
		end)
	end
	
end
