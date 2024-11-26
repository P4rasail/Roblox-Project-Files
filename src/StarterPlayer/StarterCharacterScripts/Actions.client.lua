local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local Char = script:FindFirstAncestorWhichIsA("Model")

Indexes:OnLoad(function()
	local CharManager = Indexes.Modules.Systems.CharacterManager:Create(Char)
CharManager = CharManager.Data
print(CharManager)
	print(Indexes.Modules.Systems.InputHandler["SetupChar"])
	Indexes.Modules.Systems.InputHandler:SetupChar(CharManager)
	CharManager.Cam = Indexes.Modules.Systems.CameraManager:ConnectCam(workspace.CurrentCamera)
	workspace.CurrentCamera.CameraSubject = Char
end)

