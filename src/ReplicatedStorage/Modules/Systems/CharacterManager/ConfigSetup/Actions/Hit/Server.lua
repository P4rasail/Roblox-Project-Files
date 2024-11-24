local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local Server = {}



if not Server.Running then
	Server.Running = true
	Indexes:OnLoad(function()
		repeat task.wait() until Server.CharConfig
		
	end)
end

return Server
