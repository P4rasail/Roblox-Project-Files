--[[
	This module initializes character data for the game. It sets up character configurations
	and manages character statistics. The module handles both server and client environments.

	Dependencies:
	- RunService: Service to handle game loop and heartbeat events.
	- ReplicatedStorage: Service to store modules and assets shared between server and client.
	- Players: Service to manage player instances.
	- Indexes: Module required from ReplicatedStorage to manage data indexes.

	Functions:
	- Added(Plr: Player|Model, Controller: Model): Initializes character statistics for the given player or model.

	Parameters:
	- CharConfig: Configuration for the character, which can be an Instance or a table containing a Controller.

	Returns:
	- Data: A table containing the current character data and statistics.
]]
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

return function(CharConfig)
	local Controller:Model|Player = typeof(CharConfig) == "Instance" and CharConfig or CharConfig.Controller
	local Data = {}
	--Indexes:OnLoad(function()

	if RunService:IsServer() then
			local ServerStorage = game:GetService("ServerStorage")

			local CurrentData = Indexes.ServerModules.Configs.Data
			CurrentData = table.clone(CurrentData)
			Data.CurrentData = CurrentData

		local function Added(Plr:Player|Model,Controller:Model)
		Data.CharStats = table.clone(require(script:WaitForChild("CharStats")))
		
		end
		if Controller:IsA("Player") then
			if Controller.Character then
				Added(Controller,Controller.Character)
			end
			Controller.CharacterAppearanceLoaded:Connect(function(Char)
				Added(Controller,Char)
			end)
		else
			Added(Controller,Controller)
		end
		
	end
	--end)
	
	return Data
	
end