local player = game.Players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()

local hrp:BasePart = char:WaitForChild("HumanoidRootPart")

local frame = script.Parent:WaitForChild("Frame")

local origin = Vector2.new(frame.Position.X.Scale,frame.Position.Y.Scale)
local origin2 = Vector2.new(frame.CanvasGroup.Position.X.Scale,frame.CanvasGroup.Position.Y.Scale)


local maxOffset = .03

local velocitySlow = 3000

function getYCF()
	return CFrame.Angles(0,math.atan2(workspace.CurrentCamera.CFrame.LookVector.X * -1,workspace.CurrentCamera.CFrame.LookVector.Z * -1),0)
end

function getRelativeVel()
	local vel = workspace.CurrentCamera.CFrame:VectorToObjectSpace(hrp.AssemblyLinearVelocity)
	vel *= maxOffset/300
	--print(vel)
	return Vector3.new(math.clamp( vel.X,-maxOffset,maxOffset),math.clamp( -vel.Y,-maxOffset,maxOffset),math.clamp( vel.Z,-maxOffset,maxOffset))
end

local User = frame.User
local delta=  0
local currVel  = getRelativeVel()
User.Label.Text = player.DisplayName
User.Shadow.Text = player.DisplayName
while true do
	delta = task.wait()
	currVel += (getRelativeVel() - currVel) * math.sin(delta * math.pi/2) * .2
	frame.Position = UDim2.fromScale(origin.X +currVel.X,origin.Y +currVel.Y)
	frame.CanvasGroup.Position = UDim2.fromScale(origin2.X + currVel.X,origin2.Y + currVel.Y)
end