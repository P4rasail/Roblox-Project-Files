local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CamShaker = require(script:WaitForChild("CameraShaker"))
local CameraObject = {
	Events = {},
	Zoom = 10,
	TargZoom = 10,
	MaxZoom = NumberRange.new(5,40),
	VelocityDivide = 24,
	Enabled = true,
	Type = "Normal",
	Offset = CFrame.new(0,.7,1),
	OffsetConfigs = {
		Default = CFrame.new(),
		ShiftFlight = CFrame.new(2,1,1)
	},
	Offsets = {
		
	},
	TargetInput = Vector3.new(),
	CurrentInput = Vector3.new(),
	CurrentVelTrack = Vector3.new(),
	TargetVelTrack = Vector3.new(),
	CurrentFOV = 70,
	LockedOn = nil,
	LockOffset = CFrame.new(5,5,25),
	ShakeOffset = CFrame.new(),
	OffsetType = "Default",
	VelocityLimit = .8,
	ShiftLockKeybinds = {
		Flight = {
			Enum.KeyCode.LeftAlt,
		Enum.KeyCode.RightAlt
		},
		Default = {
			Enum.KeyCode.LeftControl,
			Enum.KeyCode.RightControl
		}
	},
	ShiftLock = false,
	BaseSensitivity = .15,
	

}



local function GetShiftLockEnabled()
	local GameSettings:UserGameSettings = CameraObject.GameSettings
	local devAllowsMouseLock = game.Players.LocalPlayer.DevEnableMouseLock
	local devMovementModeIsScriptable = game.Players.LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.Scriptable
	local userHasMouseLockModeEnabled = GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch
	local userHasClickToMoveEnabled =  GameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove
 return devAllowsMouseLock and userHasMouseLockModeEnabled and not userHasClickToMoveEnabled and not devMovementModeIsScriptable

end

local function SetGameSettings()
	if CameraObject.GameSettings then return CameraObject.GameSettings end
	CameraObject.Settings = UserSettings()	-- ignore warning

	CameraObject.GameSettings = CameraObject.Settings.GameSettings
	return CameraObject.GameSettings
end

local function GetShiftlockType()
	--print(CameraObject.CharConfig)
	if CameraObject.CharConfig then
	if CameraObject.CharConfig.Flying then
		return "Flight"
	end
end
	return "Default"
end

local function ParentConnected()
	if script.Parent ~= CameraObject.Cam then
		--print("Yo")
		for i,v in CameraObject.Events do
			v:Disconnect()
		end
		if script.Parent == nil then return end
		CameraObject.Cam = script.Parent
		local Cam:Camera = CameraObject.Cam
		
		local SignalObject = Indexes.Modules.Util.Signal(script.Parent)
		CameraObject.Signal = SignalObject
		local GameSettings:UserGameSettings = SetGameSettings()
		
		table.insert(CameraObject.Events,UserInputService.InputBegan:Connect(function(input,focused)
			GameSettings = SetGameSettings()
			local Index = GetShiftlockType() or "Default"
			if focused then return end
			if not GetShiftLockEnabled() then
				CameraObject.ShiftLock = false
			end
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				CameraObject.HoldingDown = true
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			elseif table.find(CameraObject.ShiftLockKeybinds[Index],input.KeyCode) then
				print(GetShiftLockEnabled())
				if GetShiftLockEnabled() then
					CameraObject.ShiftLock = not CameraObject.ShiftLock
					if CameraObject.ShiftLock then
						UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
					else
						if not CameraObject.HoldingDown then
						UserInputService.MouseBehavior = Enum.MouseBehavior.Default
						end
						end
					end
				end
		
		end))
		table.insert(CameraObject.Events,UserInputService.InputEnded:Connect(function(input)
			GameSettings = SetGameSettings()
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				CameraObject.HoldingDown = false
				if not CameraObject.ShiftLock then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end
				end
		end))
		local OldTime = os.clock()
		
		
		table.insert(CameraObject.Events,UserInputService.InputChanged:Connect(function(input)
			GameSettings = SetGameSettings()
			if input.UserInputType == Enum.UserInputType.MouseMovement and (CameraObject.HoldingDown or CameraObject.ShiftLock) then
				GameSettings = CameraObject.GameSettings or {
					MouseSensitivity = 1
				}
				local Target = CameraObject.TargetInput + (input.Delta * (os.clock() - OldTime)) * CameraObject.BaseSensitivity * Vector3.new(-1,1,1)
				Target = Vector3.new(Target.X,math.clamp(Target.Y,-.9,.9),Target.Z)
				CameraObject.TargetInput = Target
				OldTime = os.clock()
			elseif input.UserInputType == Enum.UserInputType.MouseWheel then
				CameraObject.TargZoom -= input.Position.Z * (CameraObject.MaxZoom.Min + CameraObject.MaxZoom.Max)/2 * .2
				CameraObject.TargZoom = math.clamp(CameraObject.TargZoom,CameraObject.MaxZoom.Min,CameraObject.MaxZoom.Max)
			
			end
		end))
		
		local Cam:Camera = CameraObject.Cam
		local PrimPart:BasePart
		local primPartCF = CFrame.new()
		local currentPos = Vector3.new()
		local currentHumPos = Vector3.new()
		
		local function GetPartFromSubject(Subject:Humanoid):BasePart
			if not Subject then return end
			local Char = Subject.Parent
			if not Char or not Char.Parent then return end
			if not CameraObject.CharConfig or CameraObject.CharConfig.Controller ~= Char then
				CameraObject.CharConfig = _G.Modules.Systems.CharacterManager(Char).Data

			end
			return Subject.Parent:FindFirstChild("HumanoidRootPart")
		end
		local function GetBend(primaryPart:BasePart)
			--local Unit = (cam.CFrame.Rotation):PointToWorldSpace(primaryPart.AssemblyLinearVelocity/4)


			return -Cam.CFrame:VectorToObjectSpace(primaryPart.AssemblyLinearVelocity)/CameraObject.VelocityDivide
		end
		local function GetFOV(PrimPart:BasePart)
			return 70 + math.clamp(PrimPart.AssemblyLinearVelocity.Magnitude/10,0,70)
		end

		table.insert(CameraObject.Events,RunService.PreRender:Connect(function(deltaTime)
			Cam = CameraObject.Cam
			if Cam then
				if CameraObject.Enabled then
					local TotalOffset = CFrame.new()
					for i,v in CameraObject.Offsets do
						TotalOffset *= v
					end
					OldTime = os.clock()
					PrimPart = GetPartFromSubject(Cam.CameraSubject)
					if PrimPart then
						Cam.CameraType = Enum.CameraType.Scriptable
						primPartCF = PrimPart.CFrame--,math.clamp(CamSmoothness * 1.5,0,1)) 

						CameraObject.TargetVelTrack = GetBend(PrimPart)
						CameraObject.CurrentFOV += (GetFOV(PrimPart) - CameraObject.CurrentFOV) * .3^(1-deltaTime)
						CameraObject.CharConfig.LockedOn = CameraObject.LockedOn
						if CameraObject.LockedOn then
							CameraObject.TargetVelTrack = CameraObject.TargetVelTrack.Unit * math.clamp(CameraObject.TargetVelTrack.Magnitude,-CameraObject.VelocityLimit * CameraObject.LockOffset.Position.Magnitude,CameraObject.VelocityLimit *CameraObject.LockOffset.Position.Magnitude)

						else
						CameraObject.TargetVelTrack = CameraObject.TargetVelTrack.Unit * math.clamp(CameraObject.TargetVelTrack.Magnitude,-CameraObject.VelocityLimit * CameraObject.Zoom,CameraObject.VelocityLimit * CameraObject.Zoom)
						end
						if CameraObject.TargetVelTrack ~= CameraObject.TargetVelTrack then
							CameraObject.TargetVelTrack = Vector3.zero
						end
						CameraObject.CurrentVelTrack += (CameraObject.TargetVelTrack-CameraObject.CurrentVelTrack) * .15^(1-deltaTime)
					CameraObject.CurrentInput += (CameraObject.TargetInput - CameraObject.CurrentInput) * .3^(1-deltaTime)
						CameraObject.Zoom += (CameraObject.TargZoom - CameraObject.Zoom) * .3^(1-deltaTime)
						--CamObject.zoom =cameraHandler.aimZoom--+= (cameraHandler.aimZoom - cameraHandler.zoom) * math.clamp(deltaTime * cameraHandler.rigidFactor,0,1)
						currentPos = Vector3.new(math.sin(CameraObject.CurrentInput.X),CameraObject.CurrentInput.Y,math.cos(CameraObject.CurrentInput.X)) * Vector3.new(math.cos(CameraObject.CurrentInput.Y),1,math.cos(CameraObject.CurrentInput.Y)) * CameraObject.Zoom
						local TargOffset = CameraObject.Offset * CameraObject.OffsetConfigs[CameraObject.OffsetType] * TotalOffset
						CameraObject.CurrentOffset = CameraObject.CurrentOffset:Lerp(TargOffset,.08^(1-deltaTime))
						if CameraObject.CurrentOffset ~= CameraObject.CurrentOffset then
							CameraObject.CurrentOffset = CameraObject.Offset * CameraObject.OffsetConfigs[CameraObject.OffsetType] 
						end
						--print(CameraObject.CurrentOffset)
						currentHumPos = (primPartCF).Position
						if currentHumPos ~= currentHumPos then
							currentHumPos = Vector3.zero
						end
						Cam.FieldOfView = CameraObject.CurrentFOV
if CameraObject.LockedOn then
	 
	local LockPart:BasePart = CameraObject.LockedOn.HumanoidRootPart
	if not CameraObject.LockCF then
		CameraObject.LockCF = Cam.CFrame * CFrame.new(0,0,(LockPart.Position - Cam.CFrame.Position).Magnitude * -1)

	end
							CameraObject.LockCF = CameraObject.LockCF:Lerp(LockPart.CFrame,.3^(1-deltaTime))
							Cam.CFrame = CFrame.new((primPartCF).Position,CameraObject.LockCF.Position) * CameraObject.CurrentOffset * CameraObject.LockOffset * CFrame.new(CameraObject.CurrentVelTrack) * CameraObject.ShakeOffset


						else
							CameraObject.LockCF = nil
							Cam.CFrame = CFrame.new(currentHumPos + currentPos,currentHumPos)  * CameraObject.CurrentOffset * CFrame.new(CameraObject.CurrentVelTrack) * CameraObject.ShakeOffset
						end
						end
				end
			end
		end))
	end
end



if not CameraObject.Running then
	
	CameraObject.Running = true
CameraObject.CurrentOffset = CameraObject.Offset
	ParentConnected()
	script:GetPropertyChangedSignal("Parent"):Connect(ParentConnected)
	SetGameSettings()
	local Cam:Camera
	local Shaker = CamShaker
	CameraObject.ShakeObject = Shaker.new(Enum.RenderPriority.First.Value,function(shakeCF:CFrame)
		CameraObject.ShakeOffset = shakeCF
	end)
	CameraObject.ShakeObject:Start()
	CameraObject.Instances = Shaker.CameraShakeInstance
	CameraObject.Presets = Shaker.Presets
	local ShakeCD = 0
	for i,v in Shaker do
		if typeof(v) == "function" then
			CameraObject[i] = function(...)
				
				local Args = {...}
				if Args[1] == CameraObject then
				table.remove(Args,1)
				end
				
				return CameraObject.ShakeObject[i](CameraObject.ShakeObject,unpack(Args))
			end
		end
	end
	
	_G.WaitUntil("IndexesLoaded")
	
end

return CameraObject
