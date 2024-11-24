local player = game.Players.LocalPlayer


local layerFrames = {
	"rbxassetid://15176253500",
	"rbxassetid://15176253281",
	"rbxassetid://15176233223",
	"rbxassetid://15176232995",
	"rbxassetid://15176226569",
	"rbxassetid://15176226454",
	"rbxassetid://15176226102",
	"rbxassetid://15176226102",
	"rbxassetid://15176225937",
	"rbxassetid://15176225690",
	"rbxassetid://15176219880",
	"rbxassetid://15176219736",
	"rbxassetid://15176219618",
	"rbxassetid://15176219513",
	"rbxassetid://15176219380",
	"rbxassetid://15176219226"
}
local currentFPS = 0
local targetFPS = 0
local targetTrans = 1
local currentTrans = 1
local maxFrames = #layerFrames
local currentFrame = 1
local char:Model = player.Character or player.CharacterAdded:Wait()
local humRootPart:BasePart = char:WaitForChild("HumanoidRootPart")

local gui = script.Parent
local frame = gui.frame

local timePassed = 0
local delayTime = 0
while true do
	delayTime =task.wait()
if not humRootPart.Parent then script.Parent.Enabled = false break end

script.Parent.Enabled = true
	targetFPS = math.clamp(humRootPart.AssemblyLinearVelocity.Magnitude/4 + 64,16,512)
	targetTrans = math.clamp((-(humRootPart.AssemblyLinearVelocity.Magnitude - 128)/64),0.9,1) 
	if not char:GetAttribute("MotionLines") then script.Parent.Enabled = false continue end
	currentFPS += (targetFPS - currentFPS) * .5^delayTime
	currentTrans += (targetTrans - currentTrans) * .6^delayTime
	timePassed = (timePassed + delayTime* currentFPS)%(maxFrames + 1)
	currentFrame = math.floor(timePassed)
	frame.ImageTransparency = currentTrans
	if layerFrames[currentFrame] then
		frame.Image = layerFrames[currentFrame]
	end
	

end