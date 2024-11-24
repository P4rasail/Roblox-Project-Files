return function(Environment)
	
	local RepStorage = game:GetService("ReplicatedStorage")
	
	local Indexes = require(RepStorage:WaitForChild("Indexes"))


	
	local Plr = Environment.CharController.Controller
	
	
	local function CharAdded(Char:Model)
		--print(Indexes.Modules.Systems)
		local MoverManager =  Indexes.Modules.Systems.MoverManager
		local AnimManager =  Indexes.Modules.Systems.AnimManager
		local HRP:BasePart = Char:WaitForChild("HumanoidRootPart")
		local Mover = MoverManager:create(HRP)
		local CharController = Environment.CharController
		CharController.Mover = Mover
		local Hum:Humanoid = Char:FindFirstChildOfClass("Humanoid")
		local Animator:Animator = Hum:FindFirstChild("Animator")
		
		CharController.Animator = AnimManager:createConstructor(Animator)
		
		
		
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
	
	if Plr:IsA("Player") then
	if Plr.Character then
		CharAdded(Plr.Character)
	end
	Plr.CharacterAppearanceLoaded:Connect(function(Char)
		CharAdded(Plr.Character)
	end)
	else
		CharAdded(Plr)
	end
	
	

--[[local Matrix = _G.Types.Matrix(4,5,10)
local Matrix2 = _G.Types.Matrix(3,2,5)

Matrix *= Matrix2]]
end