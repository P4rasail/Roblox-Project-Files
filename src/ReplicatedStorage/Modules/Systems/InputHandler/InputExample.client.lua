local UIService = game:GetService("UserInputService")

repeat task.wait() until script.Owner.Value

local Req = require(script.Owner.Value)


local List = Req.Funcs
UIService.InputBegan:Connect(function(inpObject,focused)
	if focused then return end
	
end)