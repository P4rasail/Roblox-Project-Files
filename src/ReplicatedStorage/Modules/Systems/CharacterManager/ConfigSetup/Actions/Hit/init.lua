--!nonstrict
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local Server = require(script:WaitForChild("Server"))

local HitboxInfo = require(script:WaitForChild("HitboxInfo"))

local HitTab = {

	Features = {},
	AllowedFeatures = {},
	Lunges = {}

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}

HitTab.Check = function(CharConfig,Options)
	return not _G.Check({
		"Combat",
		"IsStunned"},CharConfig)
end
HitTab.Func = function(CharConfig,Options)

if Options.Holding then
		HitTab.PressTime = os.clock()
		
elseif RunService:IsServer() or HitTab.PressTime and os.clock() <= HitTab.PressTime + .2 then
		Options = Options or {}
		Options = table.clone(Options)
		--print(HitTab.PressTime and os.clock() - HitTab.PressTime)

		--print(Options)
		--print(HitTab)
		--print(CharConfig)
		Options.OriginType = Options.Type 
		--print(CharConfig.Data.CharStats.Combo,#(CharConfig.Data.CharStats.Combo))
		if #(CharConfig.Data.CharStats.Combo) >= 7 then
			Options.Type = "Knockback"
		end
		--print(Options.Type)
		local Feature = HitTab.Features[Options.Type]
		--print(Options.Type)
		if not Feature then return end
		--print(Options)
		--print(Feature)
		local Check =   HitTab.Check
		if not Check(CharConfig,Options) then
			--print("False")
			return end
		if Feature.Check and not Feature.Check(HitTab,CharConfig,Options) then
			--print("Not check ity")
			return
		end
		--print(Feature)
		if Feature["Func"] then
			--print("EYOOOO")
			Feature.Func(HitTab,CharConfig,Options)
		end

		--if Options.Holding then
		--	print(CharConfig)
		--	print(Options)


		--end
end
end

HitTab.Hit = function(CharConfig,Options)
	if typeof(Options) ~= "table" then return end
	if RunService:IsClient() then
		Indexes.Modules.Systems.Networker:SendPortData("Hit"..CharConfig.Controller.Name,nil,Options)
	else

		local List = HitTab.Validify(CharConfig.Controller,Options)
		List = Options.List
		if not List then return end
		local Tab = HitTab.Features[Options.HitType] 
		if not Tab then return end
		--print(List)
		for i,v:Model in List do

			if v:IsA("Model") then

				local Hum:Humanoid = v:FindFirstChildWhichIsA("Humanoid")
				if Hum then
					if Tab["CharHit"] then
						task.spawn(function()
							Tab.CharHit(HitTab,CharConfig,v)
						end)
					end
				end
			end
		end
		return #List > 0
	end
end

function GetYCF(CF:CFrame)
	return CFrame.Angles(0,math.atan2(-CF.LookVector.X,-CF.LookVector.Z),0)

end
HitTab.Lunge = function(CharConfig,Options)
	local MoverManager,AnimManager,Mover,Animator

	if not CharConfig.PlayerServer then
		if HitTab.Lunges[CharConfig.Controller] then
			task.cancel(HitTab.Lunges[CharConfig.Controller])
		end
		local Controller:Model = CharConfig.Controller
		local HumRootPart:BasePart = Controller:WaitForChild("HumanoidRootPart")
		local Hum:Humanoid = Controller:FindFirstChildWhichIsA("Humanoid")
		local MoverManager =  Indexes.Modules.Systems.MoverManager
		local AnimManager =  Indexes.Modules.Systems.AnimManager
		local Mover = CharConfig.Mover
		Options.BaseVel = Options.BaseVel or 120
		Options.VelocityTrack = Options.VelocityTrack or 1/1.8
		local Dir = Options.Dir or Vector3.new(0,0,1)
		local Vel = Options.BaseVel + HumRootPart.AssemblyLinearVelocity.Magnitude*Options.VelocityTrack
		--print(CFrame.new(Vector3.zero,GetDirection()).LookVector)

		local CF = CharConfig.Inputs.Look
		if not CharConfig.Flying then
			CF = GetYCF(CF)
		end
		local Aim = Vel/2

		local function Set()
			CF = CharConfig.Inputs.Look
			if not CharConfig.Flying then
				CF = GetYCF(CF)
			end
			local LockedRP:BasePart?
			if CharConfig.LockedOn then
				LockedRP = CharConfig.LockedOn:FindFirstChild("HumanoidRootPart")
			end
			if LockedRP then
				CF = CFrame.new(HumRootPart.Position,LockedRP.Position)
				if (HumRootPart.Position- LockedRP.Position).Magnitude < 1.2 then
					Vel = 0
					Aim  =0
				end
			end
			CharConfig.CurrCF = CF
			CharConfig.TargCF = CF
			MoverManager:add(Mover, "Vel","lunge",((CF).LookVector * Dir.Z + CF.RightVector * Dir.X + CF.UpVector * Dir.Y) * Vel,7)
			--print(CurrC0)
			MoverManager:add(Mover,"Gyro","lunge",CF,7)
		end
		Set()
		local TimeTake = Options.TimeTake or .5
		local EndGoal = os.clock() + TimeTake
		local Delta = 0
		local OldTime = os.clock()
		HitTab.Lunges[CharConfig.Controller] = task.spawn(function()
		repeat
			task.wait()
			Delta = os.clock() - OldTime
			OldTime = os.clock()
			Vel += (Aim-Vel) * (.06/TimeTake)^(1-Delta)
			Set()
		until os.clock() >= EndGoal
		MoverManager:destroy(Mover,"Gyro","lunge")
		MoverManager:destroy(Mover,"Vel","lunge")
		end)

	end
end
HitTab.ResetAnims = function(CharConfig,Type)
	if not CharConfig.PlayerServer then
		if Type == "All" then
			table.clear(CharConfig.AnimList)
		else
			
		CharConfig.AnimList[Type] = {}
		end
	end
end
HitTab.PlayAnim = function(CharConfig,Options)
	if not CharConfig.PlayerServer then
		local AnimManager =  Indexes.Modules.Systems.AnimManager
		local Animator = CharConfig.Animator
		local Type = Options.Type or "M1"
		CharConfig.CombatStyle = CharConfig.CombatStyle or "Default"
		local Pick = Options.Pick
		if not CharConfig.AnimList then
			CharConfig.AnimList = {}
		end
		local SearchIndex = {
			CharConfig.CombatStyle,
			"Combat",
			Type
		}
		if not CharConfig.AnimList[Type] then
			CharConfig.AnimList[Type] = {}
		end
		if not Pick then
			local Children = AnimManager:GetAnims(SearchIndex)
			if #Children == 0 then
				print("No children found")
				return
			end
			if #Children >= #(CharConfig.AnimList[Type]) then
				for i = 1, math.min(#(CharConfig.AnimList[Type]),3) do
					table.remove(CharConfig.AnimList[Type],1)
				end
			end
			--print(CharConfig.AnimList[Type])
			repeat task.wait()
			Pick = Children[math.random(1,#Children)]
			until not table.find(CharConfig.AnimList[Type],Pick)
			
		end
		if not Pick then return end
		table.insert(CharConfig.AnimList[Type],Pick)
		table.insert(SearchIndex,Pick)
		local Anim = AnimManager:PlayAnim(Animator,SearchIndex,{
			Priority = Options.Priority or Enum.AnimationPriority.Action,
			Speed = Options.Speed or 1,
			FadeTime = .03
		})
		--print(Type)
		local HitboxType = HitboxInfo.Hitboxes[CharConfig.CombatStyle][Type][Pick]
		return HitboxType,Anim
		
		
		
	end
end

HitTab.Validify = function(Controller:Model,Options)
	if not Controller then return end
	if typeof(Options) ~= "table" then return {} end
	local Plr = game.Players:GetPlayerFromCharacter(Controller)
	local HRP:BasePart = Controller:WaitForChild("HumanoidRootPart")
	for i,v:Model in Options.List do
		if v:IsA("Model") then
			local vPart:BasePart = v:FindFirstChild("HumanoidRootPart")
			if vPart then
				if (vPart.Position - HRP.Position).Magnitude > 10 then
					table.remove(Options.List,i)
				end
			end
		end
	end
	return Options.List
end

function HitDetect(CharConfig,Options)
	--print(Options)
	--if RunService:IsServer() then
	if typeof(Options) ~= "table" then return end
	local HitboxManager=  Indexes.Modules.Systems.HitboxManager
	local Controller:Model = CharConfig.Controller
	Options.ExcludeChildren = true
	Options.ID = "Hit"
	Options.FilterFunc = function(Part:BasePart,Tab)
		local Mod = Part:FindFirstAncestorWhichIsA("Model") 
		if Mod and Mod ~= CharConfig.Controller then
			local Hum = Mod:FindFirstChildWhichIsA("Humanoid")
			if Hum then
				return Mod
			end
		end
	end

	local Mod = HitboxManager(Options.Model,"Character",Options.ID,
		Options.Extensions
	)
	--print(Mod)
	Mod.ExcludeChildren = Options.ExcludeChildren
	Mod:Filter(Options.FilterFunc)
	Mod.CreateFunc = function(List)
		--print(List)
		local Found = {}
		for i,Part in List do
			local Mod = Part 
			if Mod and Mod ~= CharConfig.Controller then
				local Hum = Mod:FindFirstChildWhichIsA("Humanoid")
				if Hum then
					if not table.find(Found,Mod) then
						table.insert(Found,Mod)
					end
				end
			end
		end
		--print(Found)
		return Options.HitFunc(Found,List)
	end
	Mod.CharStorage = {}
	table.insert(Mod.CharStorage,Options.Model)
	--print(Mod)
	local function Destroy()
		HitboxManager("Destroy",Options.Model,"Character",Options.ID)
	end
	if Options.TimeLast then
		task.delay(Options.TimeLast,function()
			Destroy()
		end)
	end
	if Options.DestroyOnFunc then
		task.spawn(function()
			repeat task.wait() until Options.DestroyOnFunc(Mod) or Mod["_DESTROYED"]
			Destroy()
		end)
	end
	return Mod
	--end
end
HitTab.HitDetect = function(CharConfig,Options)
	
	if typeof(Options) ~= "table" then return end
	--print(Options)
	if not Options.HitboxTimes or not Options.Anim then
		return HitDetect(CharConfig,Options)
	else
		local Anim:AnimationTrack = Options.Anim
		task.spawn(function()
			for i,v in Options.HitboxTimes do
				repeat task.wait()
					
				until Anim.TimePosition >= v.Start or not Anim.IsPlaying
				local function Decide()
					if not Anim.IsPlaying then
						return true
					end
					if Anim.TimePosition >= v.End then
						return true
					end
				end
				Options.DestroyOnFunc = Decide
				HitDetect(CharConfig,table.clone(Options))
				repeat task.wait() until Decide()
			end
		end)
	end
end

if not HitTab.Running then
	HitTab.Running = true
	Indexes:OnLoad(function()
		local function FeatureAdded(v:ModuleScript)
			if v:IsA("ModuleScript") then
				local Req = require(v)
				local Tab = HitTab.Features[v.Name] or {}
				Indexes.Modules.Util.Array:Override(Tab,Req)

				HitTab.Features[v.Name] = Tab
			end
		end
		for i,v in script:WaitForChild("Features"):GetChildren() do
			FeatureAdded(v)
		end
		script.Features.ChildAdded:Connect(FeatureAdded)
		if RunService:IsServer() then
			--print("Server")
			task.spawn(function()
				local Mod
				repeat
					task.wait()
					Mod = script:FindFirstAncestorWhichIsA("Model")
					--print(script:GetFullName())
				until Mod
				if  (Mod and Mod:FindFirstChildWhichIsA("Humanoid")) then 
					local CharConfig = Indexes.Modules.Systems.CharacterManager(Mod)
					local Plr = game.Players:GetPlayerFromCharacter(Mod)
					if Plr then

						Indexes.Modules.Systems.Networker:CreatePort("Hit"..Mod.Name,function(Player,Options)
							local Char = Player.Character 
							if not Char then return end
							local CharConfig = Indexes.Modules.Systems.CharacterManager(Char)
							--print(CharConfig)

							HitTab.Hit(CharConfig.Data,Options)
						end,{
							Replace = true,
							List = {Plr},
							ListType = "Include"
						},
						{
							Replace = true
						})
					end
				end
			end)
			--Indexes.Modules.Systems.Networker:CreatePort("")
		end
		for i,v in Indexes.Modules.Configs.CombatFeatures:GetChildren() do
			v:Clone().Parent = script.Features
		end
	end)

end

return HitTab