local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

function FlightToggle(CharConfig,Toggle)
	local MoverManager =  Indexes.Modules.Systems.MoverManager
	local AnimManager =  Indexes.Modules.Systems.AnimManager
	local Mover = CharConfig.Mover
	local CharTable = CharConfig
	local Controller = CharConfig.Controller
	if Controller:IsA("Player") then
		Controller = Controller.Character
	end
	local Char = Controller
	local Hum:Humanoid = Controller:WaitForChild("Humanoid")
	local Animator = CharConfig.Animator
	if RunService:IsServer() then
		CharConfig.Data.CharStats.Flight.Flying = true
	end
	if CharConfig.PlayerServer then
		if CharTable.FlightTask then
			task.cancel(CharTable.FlightTask)
		end
		
		return
	end
	CharConfig.Flying = Toggle ~= nil and Toggle or not CharConfig.Flying
	if CharConfig.Flying then
		CharConfig.StopFallJump()
		if Hum then
			if CharTable.FlightTask then
				task.cancel(CharTable.FlightTask)
			end
			local HumRootPart:BasePart = Char:WaitForChild("HumanoidRootPart")
			
			--if Args.Hold then
			local AnimWeights = {
				flightLeft = 0,
				flightRight = 0,
				flightForward= 0,
				flightIdle = 0,
				flightBack= 0,
				flightUp = 0,
				flightDown = 0
			}
			local AnimObjects = {

			}
			AnimObjects.flightIdle = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Idle"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightIdle * 2,
				ID = "flightIdle"
			}
			)
			AnimObjects.flightForward = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Forward"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightForward * 2,
				ID = "flightForward"
			}
			)
			AnimObjects.flightBack= AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Back"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightBack * 2,
				ID = "flightBack"
			}
			)
			AnimObjects.flightLeft = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Left"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightLeft * 2,
				ID = "flightLeft"
			}
			)
			AnimObjects.flightRight = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Right"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightRight * 2,
				ID = "flightRight"
			}
			)
			AnimObjects.flightUp = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Up"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightUp * 2,
				ID = "flightUp"
			}
			)
			AnimObjects.flightDown = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Down"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightDown * 2,
				ID = "flightDown"
			}
			)
			--print(CharConfig)
			local function getInputs()
				local Inputs = {
					W = false,
					A = false,
					S = false,
					D = false,
					Space = false,
					LeftControl = false
				}
				for i,v in CharConfig.Inputs.CurrentInputs do
					if Inputs[v.Name] ~= nil then
						Inputs[v.Name] = true
					end
				end
				
				--print(Inputs)
				return Inputs
			end

			local function DetermineTravel()
				--print(CharTable)
				local Vec = Vector3.zero
				local Inputs = getInputs()
				if RunService:IsServer() then
					CharConfig.Data.CharStats.KeysPressed = Inputs
				end
				--print(Inputs)
				Vec += Vector3.new(0,0,1 * (Inputs["W"] and 1 or Inputs["S"] and -1 or 0))
				Vec += Vector3.new(1 * (Inputs["D"] and 1 or Inputs["A"] and -1 or 0),0,0)
				Vec += Vector3.new(0,1 * (Inputs["Space"] and 1 or Inputs["LeftControl"] and -1 or 0),0)
					--[[if Vec.Magnitude == 0 then
						Vec = Vector3.new(0,0,1)
					end]]
				if Vec.Magnitude ~= 0 then
					Vec = Vec.Unit
				end
			
				--	print(Vec)
				return Vec
			end
			local function DetermineFlightKey()
				local Inputs =getInputs()
				local Vec =DetermineTravel()

				AnimWeights.flightForward = Inputs.W and 2 or -2
				AnimWeights.flightLeft = Inputs.A and 2 or -2
				AnimWeights.flightRight = Inputs.D and 2 or  -2
				AnimWeights.flightBack = Inputs.S and 2 or  -2
				AnimWeights.flightUp = Inputs.Space and 2 or  -2
				AnimWeights.flightDown = Inputs.LeftControl and 2 or  -2

				--print(Vec.Magnitude)
				AnimWeights.flightIdle = Vec.Magnitude ~= 0 and -2 or 2
				--					print(AnimWeights)
			end
			local function GetTilt()
				local RV = HumRootPart.CFrame.RightVector
				return-math.clamp( HumRootPart.AssemblyLinearVelocity.Unit:Dot(RV)*math.pi/1,-math.pi/4,math.pi/4)
			end
			CharTable.FlightTask = task.spawn(function()
				local DeltaTime =0
				local Move = Vector3.new(0,0,1)
				local TargC0 = 0
				local CurrC0 = 0
				local TargVel = Vector3.zero
				local CurrentVel = Vector3.zero
				CharTable.TargCF = CFrame.new()
				CharTable.CurrCF = CFrame.new()
				CharTable.BoostMulti = 1
				CharTable.CurrentVel = 0

				local OldTime = os.clock()
				local Face=  Move
				--print(CharTable.Inputs)
CharTable.CurrentBoost = 1
				while true do
					task.wait()
					DeltaTime = os.clock() - OldTime
					OldTime = os.clock()
					DetermineFlightKey()
					Move = DetermineTravel()
					Face = Move
					if Face.Magnitude == 0 then
						Face = Vector3.new(0,0,1)
					end
					Char:SetAttribute("FlightTravel",Face)
				--	print(Face)

					if HumRootPart.AssemblyLinearVelocity.Magnitude > 10 and DetermineTravel().Z ~= 0 then
						TargC0 = GetTilt()
					else
						TargC0 = 0							
					end
					if Move.Magnitude ~= 0 then
						CharConfig.TargCF = CharTable.Inputs.Look 

					else
						--TargCF = CharTable.Inputs.Look * CFrame.Angles(0,0,CurrC0)
						TargC0 = 0

					end
					--print(TargC0)
					CurrC0 += (TargC0 - CurrC0) * .1 ^(1-DeltaTime)
					if not CharConfig.BoostMulti then
						CharConfig.BoostMulti = 1
					end
				
					--* 70 * CharTable.BoostMulti * CharTable.DashMulti
					CharTable.CurrentVel += (70 * CharTable.BoostMulti - CharTable.CurrentVel) * .1^(1-DeltaTime)
					TargVel = (CharTable.Inputs.Look.LookVector * Move.Z + CharTable.Inputs.Look.RightVector * Move.X + CharTable.Inputs.Look.UpVector * Move.Y) * CharTable.CurrentVel
					--CharTable.CurrentVel = nil
					CurrentVel += (TargVel - CurrentVel) * math.clamp(DeltaTime * 8,0,1)
					--print(AnimWeights)
					for i,v in AnimObjects do
						v:AdjustWeight(v.WeightCurrent + (AnimWeights[i] * 1 - v.WeightCurrent) * .08 ^ (1-DeltaTime),0)
						if math.abs((AnimWeights[i] * 1 - v.WeightCurrent)) > .98 then
							AnimWeights[i] = v.WeightCurrent
						end
					end
					CharTable.CurrCF = CharTable.CurrCF:Lerp(CharConfig.TargCF,math.clamp(.15^(1-DeltaTime),0,1))
					MoverManager:add(Mover, "Vel","flight",CurrentVel,4)
					--print(CurrC0)
					MoverManager:add(Mover,"Gyro","flight",CharTable.CurrCF* CFrame.Angles(0,0,CurrC0),4)
				end
			end)





		end
		--end
	else
		if CharTable.FlightTask then
			task.cancel(CharTable.FlightTask)
		end
		CharConfig:DoAction("ShiftFlight",{
			Holding = false
		})
		AnimManager:StopAnim(CharConfig.Animator,{ "flightIdle",
			"flightForward",
			"flightLeft",
			"flightRight",
			"flightBack",
			"flightUp",
			"flightDown"
		})
		MoverManager:destroy(Mover,"Gyro","flight")
		MoverManager:destroy(Mover,"Vel","flight")
if Hum.FloorMaterial == Enum.Material.Air then
			CharConfig.PlayFallAnim()
end
	end	
end

return {
	Func = function(CharConfig,Options)
		local MoverManager =  Indexes.Modules.Systems.MoverManager
		local AnimManager =  Indexes.Modules.Systems.AnimManager
		local Mover = CharConfig.Mover
		--if Options.Holding then
	--	print(CharConfig)
	--	print(Options)
		FlightToggle(CharConfig,Options.Toggle)
		--end
	end,

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}