local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))



return {
	Func = function(CharConfig,Options)
		--print(CharConfig.Controller)
		--print(CharConfig.PlayerServer)
		if not CharConfig.PlayerServer then
		local MoverManager =  Indexes.Modules.Systems.MoverManager
		local AnimManager =  Indexes.Modules.Systems.AnimManager
		local Mover = CharConfig.Mover
		--repeat task.wait() until CharConfig.Signal
		--print(CharConfig.Signal)
		--print(Options.Holding)
		CharConfig.Signal.Run(Options.Holding)
		if Options.Holding then
			--print("Boost")
			CharConfig.RunBoost = 5
			CharConfig.Running = true
		else
			--print("Unboost")
			CharConfig.RunBoost = 1
			CharConfig.Running = false
		end
		end
	end,

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}