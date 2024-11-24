return function(Environment)
	
	local RepStorage = game:GetService("ReplicatedStorage")
	local UIService = game:GetService("UserInputService")
	local CAService = game:GetService("ContextActionService")

	local Indexes = require(RepStorage:WaitForChild("Indexes"))

	
	local CharConfig = Indexes.Modules.Systems.CharacterManager()
	CharConfig  =require(CharConfig)(game.Players.LocalPlayer)

	
	local InputFormats = {
		["Type"] = {

			"UserInputType",
			"Name"
		},
		["Key"] = {
			"KeyCode",
			"Name"
		}
	}


	local function SolveEntry(Input,Info,Index,Format)
		if not Input or not Info or not Index or not Format then return end
		local Entry = InputFormats[Index]
		local Val =  Input
		if typeof(InputFormats[Index]) == "table" then
			for i,v in InputFormats[Index] do
				Val = Val[v]
			end
		else
			Val = Val[Format]
		end
		Info[Index] = Val

	end

	local function GetInputInfo(Input:InputObject)
		local Info = {}
		for i,v in InputFormats do
			SolveEntry(Input,Info,i,v)
		end
		return Info
	end

UIService.InputBegan:Connect(function(Input,focused)
	if focused then return end
		if Input.UserInputType == Enum.UserInputType.MouseMovement then return end
		local Info
		--print(Input.KeyCode.Name)
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			Info = _G.Enums.Key[Input.KeyCode.Name]
		end
		--print(Info)

		CharConfig.Inputs:PushInput(Info,true)
end)
UIService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then return end

		local Info
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			Info = _G.Enums.Key[Input.KeyCode.Name]
		end
		--print(Info)
		CharConfig.Inputs:PushInput(Info,false)
end)
	_G.Indexes.Modules.Systems.InputHandler:AddFunction(function(Input:InputObject,Holding)
		if Holding then
			
		else
			
		end
	--[[if Focused then return end
	if Input.UserInputType == Enum.UserInputType.MouseMovement then return end
	local Info
	if Input.UserInputType == Enum.UserInputType.Keyboard then
		Info = _G.Enums.Key[Input.KeyCode.Name]
	end
	--print(Info)
	
	CharConfig.Inputs:PushInput(Info,true)]]


	end)
	local function CharAdded(Char:Model)
		
		--[[_G.Indexes.Modules.GameSystems.BindService:Bind(game.ReplicatedStorage.Models.Clothes.Goku,Char,{
			Tag = "Clothing"

		})
		--[[_G.Indexes.Modules.Systems.AnimHandler:PlayAnim(Char:WaitForChild("Humanoid"):WaitForChild("Animator") ,79030849282172,{},function(Pose:Pose)
			if Pose.Name == "Left Arm" then
				return false
			end
			return true
		end)--]]
		--[[_G.Indexes.Modules.Systems.AnimHandler:Create(Char,{}):CreateAnim(79030849282172,{
			PartListType = "Exclude",
			PartList = {
				"Left Arm",
				"Right Arm",
				"Head"
			},
			Weight = 4
		})
		_G.Indexes.Modules.Systems.AnimHandler:Create(Char,{}):CreateAnim(97417023688837,{
			PartListType = "Exclude"
		})
		_G.Indexes.Modules.Systems.AnimHandler:Create(Char,{}):CreateAnim(81069515041299,{
			PartListType = "Exclude"
		})]]
	end
	local Plr = game.Players.LocalPlayer
	if Plr.Character then
		CharAdded(Plr.Character)
	end
	Plr.CharacterAppearanceLoaded:Connect(function(Char)
		CharAdded(Plr.Character)
	end)
	
	task.spawn(function()
		local Plr = game.Players.LocalPlayer
		local Mouse = Plr:GetMouse()
		local Cam = workspace.CurrentCamera
		while Plr.Parent do
			--print("LOL")
			task.wait()
			CharConfig.Inputs:SendInfo({
				MouseCF = Mouse.Hit,
				Look = Cam.CFrame
			})
		end
	end)

--[[local Matrix = _G.Types.Matrix(4,5,10)
local Matrix2 = _G.Types.Matrix(3,2,5)

Matrix *= Matrix2]]
end