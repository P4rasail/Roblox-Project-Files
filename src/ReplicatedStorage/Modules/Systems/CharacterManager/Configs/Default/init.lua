return function(CharConfig,Config)
local RunService = game:GetService("RunService")
local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
print(CharConfig)
if RunService:IsServer() then
	Config = Config or {}
	CharConfig.Script = script
	Indexes:OnLoad(function()
	

--[[
local ActionTab = Config.ActionTab or {}
for i,v in ActionTab do
	CharConfig.ActionMods[i] = v
end]]



--print("Current")
		local Environment = CharConfig.ServerEnvironment
		if Environment then
			Environment:Load(CharConfig)
		end
		end)
return CharConfig

else
--Client-Sided code
--return CharConfig
		Indexes:OnLoad(function()


print("Client")
		local Environment = CharConfig.Environment
if Environment then
			Environment:Load(CharConfig)
end
end)
end
end
