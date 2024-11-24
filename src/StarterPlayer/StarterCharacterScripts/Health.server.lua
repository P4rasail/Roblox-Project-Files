local Char:Model = script.Parent

local Hum:Humanoid = Char:FindFirstChildOfClass("Humanoid")
local HumRootPart:BasePart = Char:WaitForChild("HumanoidRootPart")
local DecayTime= 0
while true do
	DecayTime = task.wait()
	if HumRootPart.AssemblyLinearVelocity.Magnitude < 10 then
		Hum.Health = math.clamp(Hum.Health + DecayTime * .4,0,Hum.MaxHealth)
	end
end