local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local Tab = {
	Cooldown = 0
}

Tab.Func = function(CharConfig,Options)

	local MoverManager =  Indexes.Modules.Systems.MoverManager
	local AnimManager =  Indexes.Modules.Systems.AnimManager
	local Mover = CharConfig.Mover
	if not  CharConfig.ShiftCooldown then
		CharConfig.ShiftCooldown = 0
	end
	--print(CharConfig.ShiftCooldown-os.clock() )
	if Options.Holding and not CharConfig.ShiftFlight then
		local Hum:Humanoid = CharConfig.Controller.Humanoid
		if Hum.MoveDirection.Magnitude == 0 then 
			print("Not moving")
			return end
		if os.clock() < CharConfig.ShiftCooldown then
			return
		else
			CharConfig.ShiftCooldown = math.huge
		end
		if RunService:IsClient() then
			CharConfig.Cam.Offsets.ShiftFlight = CFrame.Angles(0,math.pi/4,0) * CFrame.new(14,0,0)
		CharConfig.BoostMulti = 0
		end
		CharConfig.ShiftFlight = true
		print("FlightShift")
		task.wait(.5)
		task.delay(.2,function()
			if RunService:IsClient() then
				CharConfig.Cam.Offsets.ShiftFlight = nil
			end
		end)
		print("Done")
		if not CharConfig.ShiftFlight then
			CharConfig.Data.CharStats.ShiftFlight = false
			CharConfig.ShiftFlight = false
			CharConfig.ShiftCooldown = os.clock()  + .3
			return
		end
		
	elseif CharConfig.Data.CharStats.ShiftFlight then
		CharConfig.ShiftCooldown = os.clock() + .3
	end
	if RunService:IsClient() then
		if Options.Holding then
			
			--CharConfig.Cam:ShakeInstanceOnce(CharConfig.Cam.Presets.ShiftFlight)
			local Time = os.clock() + .5
			
			Indexes.Modules.Util.Array:SetIndex(CharConfig.Cam,"OffsetType","ShiftFlight",function()
				return true
			end)

		else
			Indexes.Modules.Util.Array:SetIndex(CharConfig.Cam,"OffsetType","Default")
		end
		--Indexes.Modules.Systems.Networker:SendPortData("ShiftFlight",_G.Enums.NetworkSendType.FastEvent,Options)

	else
		if not Options.Holding and CharConfig.Data.CharStats.ShiftFlight then
			Options.StopFlight = true
		end
		print("ShiftFlightEffect")
		Indexes.ServerModules.Systems.EffectPlayer:ShiftFlight(CharConfig.Controller,Options)

	end
	CharConfig.Data.CharStats.ShiftFlight = Options.Holding	
	if Options.Holding then
		--print("Boost")
		CharConfig.BoostMulti = 6
		CharConfig.ShiftFlight = true
	else
		--print("Unboost")
		CharConfig.BoostMulti = 1
		CharConfig.ShiftFlight = false
	end
end


return Tab