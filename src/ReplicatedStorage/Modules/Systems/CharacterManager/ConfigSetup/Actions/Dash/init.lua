local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))



local Dir = {
	W = (Vector3.FromAxis(Enum.Axis.Z)),
	S = -(Vector3.FromAxis(Enum.Axis.Z)),
	D = Vector3.FromAxis(Enum.Axis.X),
	A = -Vector3.FromAxis(Enum.Axis.X),
	Space = Vector3.FromAxis(Enum.Axis.Y),
	LeftControl = -Vector3.FromAxis(Enum.Axis.Y)
}

local function GetYCF(CF:CFrame)
	return CFrame.Angles(0,math.atan2(-CF.LookVector.X,-CF.LookVector.Z),0)

end
function Dash(CharConfig)
	if os.clock() < CharConfig.DashCooldown then return end
	CharConfig.DashCooldown = os.clock() + .4
	if RunService:IsServer() then
		Indexes.ServerModules.Systems.EffectPlayer:Dash(CharConfig.Controller)

		if CharConfig.PlayerServer then
			return
		end
	end
	local Controller:Model = CharConfig.Controller
	local HumRootPart:BasePart = Controller:WaitForChild("HumanoidRootPart")
	local Hum:Humanoid = Controller:FindFirstChildWhichIsA("Humanoid")
	local MoverManager =  Indexes.Modules.Systems.MoverManager
	local AnimManager =  Indexes.Modules.Systems.AnimManager
	local Mover = CharConfig.Mover
	
	local function getInputs(PrevDir)
		local Inputs = {
			W = false,
			A = false,
			S = false,
			D = false,
			Space = false,
			LeftControl = false
		}
		local CurrDir = Vector3.zero
		for i,v in CharConfig.Inputs.CurrentInputs do
			if Inputs[v.Name] ~= nil then
				Inputs[v.Name] = true
			end
		end
		for i,v in Inputs do
			if v then
				CurrDir += Dir[i]
			end
		end
		if CurrDir.Magnitude == 0 then
			CurrDir = PrevDir
		end
		CurrDir = CurrDir.Unit

		--print(Inputs)
		return CurrDir
	end
	local Vel = 200 + HumRootPart.AssemblyLinearVelocity.Magnitude/1.8
	--print(CFrame.new(Vector3.zero,GetDirection()).LookVector)
	local Dir = getInputs(Vector3.FromAxis(Enum.Axis.Z))
	local CF = CharConfig.Inputs.Look
	if not CharConfig.Flying then
		CF = GetYCF(CF)
	end
	local function Set()
		Dir = getInputs(Dir)
		Controller:SetAttribute("DashDir",Dir)
		CF = CharConfig.Inputs.Look
		if not CharConfig.Flying then
			CF = GetYCF(CF)
		end
		CharConfig.CurrCF = CF
		CharConfig.TargCF = CF
	MoverManager:add(Mover, "Vel","dash",((CF).LookVector * Dir.Z + CF.RightVector * Dir.X + CF.UpVector * Dir.Y) * Vel,6)
	--print(CurrC0)
	MoverManager:add(Mover,"Gyro","dash",CF,6)
	end
	Set()
	local TimeTake = .3
	local EndGoal = os.clock() + TimeTake
	local Delta = 0
	local OldTime = os.clock()
	local Aim = Vel/2
	CharConfig.FinishedDashing = false
	CharConfig.DashEnd = EndGoal
	repeat
		task.wait()
		Delta = os.clock() - OldTime
		OldTime = os.clock()
		Vel += (Aim-Vel) * (.06/TimeTake)^(1-Delta)
		Set()
	until os.clock() >= EndGoal
	MoverManager:destroy(Mover,"Gyro","dash")
	MoverManager:destroy(Mover,"Vel","dash")
	CharConfig.FinishedDashing = true
end
return {
	Func = function(CharConfig,Options)
		local MoverManager =  Indexes.Modules.Systems.MoverManager
		local AnimManager =  Indexes.Modules.Systems.AnimManager
		local Mover = CharConfig.Mover
		--if Options.Holding then
		--	print(CharConfig)
		--	print(Options)
		CharConfig.DashCooldown = CharConfig.DashCooldown or 0
		if CharConfig.DashTask then
			repeat task.wait() 
			--print("Waiting")	
			until os.clock() >= CharConfig.DashEnd
			task.cancel(CharConfig.DashTask)
			CharConfig.DashEnd = 0
		end
		if Options.Holding then
			CharConfig.New = false
			CharConfig.DashEnd = 0
			CharConfig.DashTask = task.spawn(function()
				while true do
					CharConfig.New = true
		Dash(CharConfig)
		CharConfig.New = false
		repeat task.wait() until os.clock() >= CharConfig.DashCooldown
		end
		end)
		else
			MoverManager:destroy(Mover,"Gyro","dash")
			MoverManager:destroy(Mover,"Vel","dash")
		end
		--end
	end,
	RemoteType = "Function"

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}