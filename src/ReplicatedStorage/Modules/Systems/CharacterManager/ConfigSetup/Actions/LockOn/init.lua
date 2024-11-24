local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))



return {
	Func = function(CharConfig,Options)
		local MoverManager =  Indexes.Modules.Systems.MoverManager
		local AnimManager =  Indexes.Modules.Systems.AnimManager
		local Mover = CharConfig.Mover
		local Targ:Model
		if CharConfig.Cam then
			local UIService = game:GetService("UserInputService")
			local Things = {}
			local CurrentCam = workspace.CurrentCamera
			local MousePos = UIService:GetMouseLocation()
			for i,v in workspace.characters:GetChildren() do
				if v:IsA("Model") and v ~= CharConfig.Controller then
					local PrimPart:BasePart = v:FindFirstChild("HumanoidRootPart")
					if PrimPart then
						local ScreenPart = CurrentCam:WorldToScreenPoint(PrimPart.Position)
					--UIService:Get
					--print(ScreenPart)
						if ScreenPart.Z >= 0 and ScreenPart.Z <= 600 then
							table.insert(Things,{
								Mod = v,
								Distance = (Vector2.new(ScreenPart.X,ScreenPart.Y) - MousePos).Magnitude + ScreenPart.Z^.5
							})
						end
					end
				end
			end
			table.sort(Things,function(Part1,Part2)
				return Part1.Distance < Part2.Distance
			end)

			Options.Target = Things[1] and Things[1].Distance < 700 and Things[1].Mod
			if CharConfig.Cam.LockedOn == Options.Target then
				Options.Target = nil
			end
		end
		if Options.Target then
			local Targ:Model = Options.Target
			if typeof(Targ) == "Instance" and Targ:IsA("Model") then
				CharConfig.LockedOn = true
				if CharConfig.Cam then
					CharConfig.Cam.LockedOn = Targ
				end
			else
				CharConfig.LockedOn = nil
				if CharConfig.Cam then
					CharConfig.Cam.LockedOn = nil
				end
			end
		else
			CharConfig.LockedOn = nil
			if CharConfig.Cam then
					CharConfig.Cam.LockedOn = nil
				end
		end
		--print(CharConfig.Cam)
	end,

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}