local services = require(game:GetService("ReplicatedStorage").modules.services)

local serverStorage = services.serverStorage
local repStorage = services.repStorage

local modules = serverStorage.modules
local repModules = repStorage.modules

local npcManager = require(modules.npcManager)
local moverManager = require(repModules.moverManager)

repeat task.wait() until script.Parent:FindFirstChild("charStats") and script.Parent.Parent.Parent == workspace.characters and moverManager:getFromTarget(script.Parent.HumanoidRootPart)
script.Parent.charStats.stats.level.Value = 100

repeat task.wait() until workspace.characters:FindFirstChild("Codewasse") and (workspace.characters.Codewasse.Codewasse.PrimaryPart.Position - script.Parent.HumanoidRootPart.Position).Magnitude <= 40
local npc = npcManager.new(script.Parent,{
	target = workspace.characters.Codewasse.Codewasse
})
task.spawn(function()
	while task.wait(5) do
		script.Parent.charStats.action.combo.Value = ""
	end
end)
while true do
	npc:combat("R")
	task.wait(.4)
--	print("Jumper")
end