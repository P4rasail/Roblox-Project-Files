local RunService = game:GetService("RunService")

return function(GameLoader)
	repeat task.wait() until _G.Types and _G.Types.Loaded
	local Player = game.Players.LocalPlayer
	_G.Modules.Systems.Networker:SendPortData("GameLoad")
	for i,v in Player.PlayerScripts:GetChildren() do
		if v:IsA("ModuleScript") and v.Name == "Environment" then
			task.spawn(function()
			local Environment = require(v)
			Environment:Load()
			end)
		end
	end
end