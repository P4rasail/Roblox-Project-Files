local UIService = game:GetService("UserInputService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

_G.WaitUntil("IndexesLoaded")

local Req = Indexes.Modules.Systems.InputHandler


UIService.InputBegan:Connect(function(inpObject,focused)
	if focused then return end
	Req:AddInput(inpObject,true)
end)
UIService.InputEnded:Connect(function(inpObject)
	Req:AddInput(inpObject,false)
end)