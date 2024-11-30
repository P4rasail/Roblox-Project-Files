local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local CombatService = {
	ComboValues = require(script:WaitForChild("ComboValues")),
	StunTypes = {
		Light = 1
	},
	Tasks = {},
	DetermineTasks = {}
}

function FindStunMarkers(CharConfig,Keyword:string)
	if not CharConfig then return end
	local Markers = {}
	for i,v in CharConfig.Data.CharStats.HitBy do
		if v.StunType == Keyword or Keyword == "All" then
			table.insert(Markers,v)
		end
	end
	return Markers
end

function FindDebounce(CharConfig,Keyword:string)
	if not CharConfig then return end
	local Markers = {}
	local Found = CharConfig.Data.CharStats.Debounces[Keyword] 
	return Found and os.clock() < Found
end
function CombatService:RemoveStunMarker(CharConfig,Marker)
	if not CharConfig then return end
	if Marker == "All" then
		Marker = table.clone(CharConfig.Data.CharStats.HitBy)
	elseif typeof(Marker) == "string" and table.find(CombatService.StunTypes,Marker) then
		Marker = FindStunMarkers(CharConfig,Marker)
	elseif typeof(Marker) == "table" then
		if Marker.StunType then
			Marker = {Marker}
		end
		
	end
	for i,Marker in Marker do
		for i,v in CharConfig.Data.CharStats.HitBy do
			if v == Marker then
				table.remove(CharConfig.Data.CharStats.HitBy,i)
			end
			break
		end
	end
end

function CombatService:AddStunMarker(CharConfig,Options)
	if not CharConfig then return end
	local Entry = {
		Killer = Options.Killer,
		Damage = Options.Damage or 0,
		StunType = Options.StunType or "Light"
		
	}
	table.insert(CharConfig.Data.CharStats.HitBy,Entry)
	return Entry
	
end

function CombatService:Stun(Mod:Model,Options)
	if typeof(Mod) ~= "Instance" then return end
	
	local Find = CombatService.Tasks[Mod]
	local HRP:BasePart = Mod:FindFirstChild("HumanoidRootPart")
	local StunVal = CombatService.StunTypes[Options.StunType] or 0
	if (Find and (Find.Task and coroutine.status(Find.Task) == "running")) and StunVal < Find.Value then
		return
	end
	if Find then
		if Find.Task then
		task.cancel(Find.Task)
		end
	end
	local Start = os.clock()

	local function Determine()
		if Options.TimeLast then
			if os.clock() >= Start + Options.TimeLast then
				return true
			end
		end
		if Options.DestroyOnFunc then
			if Options.DestroyOnFunc(CharConfig) then
				return true
			end
		end
	end
	local CharConfig = Indexes.Modules.Systems.CharacterManager(Mod).Data
	if RunService:IsServer() then
		
		--print(CharConfig)
		if Options.Killer then
			local Marker = CombatService:AddStunMarker(CharConfig,Options)
			local function Destroy()
				CombatService:RemoveStunMarker(CharConfig,Marker)
			end

			if Options.DestroyOnFunc or Options.TimeLast then
				
			task.spawn(function()
				repeat task.wait() until Determine()
				Destroy()
			end)
			end
		end
		local Plr = game.Players:GetPlayerFromCharacter(Mod)
		if Plr then
			Indexes.Modules.Systems.Networker:SendPortData("Stun",nil,Plr,Options)
			return
		end
	end

	local Mover = CharConfig.Mover
	local Animator = CharConfig.Animator
	local MoverManager = Indexes.Modules.Systems.MoverManager
	local AnimManager = Indexes.Modules.Systems.AnimManager
	local Killer:Model = Options.Killer
	local KillerRP:BasePart = Killer and Killer:FindFirstChild("HumanoidRootPart")
	local Dir = Options.Dir or KillerRP and KillerRP.CFrame * CFrame.Angles(0,math.pi,0)
	if not Dir then return end
	local KnockDir = Options.KnockDir or Dir  * CFrame.Angles(0,math.pi,0)
	local Knock = Options.Knockback or 10
	CombatService.Tasks[Mod] = {
		Task = task.spawn(function()
		local Delta = 0
		local OldTime = os.clock()
		local Vel = KnockDir.LookVector * Knock
		local Aim = Vel/3
		repeat
			task.wait()
			Delta = os.clock() - OldTime
			OldTime = os.clock()
			if Options.TimeLast then
			Vel += (Aim - Vel) * (.3/Options.TimeLast)^(1-Delta)
				end
			MoverManager:add(Mover,"Vel","Stun",Vel,10)
			MoverManager:add(Mover,"Gyro","Stun",Dir,10)
		until Determine()
		MoverManager:destroy(Mover,"Vel","Stun")
		MoverManager:destroy(Mover,"Gyro","Stun")
		end),
		Value = StunVal
		}
end

function CombatService:RemoveStun(Mod:Model,Options)
	local Find = CombatService.Tasks[Mod]
	local HRP:BasePart = Mod:FindFirstChild("HumanoidRootPart")
	local StunVal = CombatService.StunTypes[Options.StunType] or 0
	if (Find and (Find.Task and coroutine.status(Find.Task) == "running")) and StunVal < Find.Value then
		return
	end
	if Find then
		if Find.Task then
			task.cancel(Find.Task)
		end
	end
	local Start = os.clock()


	local CharConfig = Indexes.Modules.Systems.CharacterManager(Mod).Data
	if RunService:IsServer() then
		CombatService:RemoveStunMarker(CharConfig,Options.StunType)
		local Plr = game.Players:GetPlayerFromCharacter(Mod)
		if Plr then
			Indexes.Modules.Systems.Networker:SendPortData("RemoveStun",nil,Plr,Options)
			return
		end
	end
end

function CombatService:CheckStun(Mod:Model,Options)
	if not Mod then return end
	local CharConfig = Indexes.Modules.Systems.CharacterManager(Mod).Data
	if RunService:IsServer() then
		return FindStunMarkers(CharConfig,Options.Marker or "All")
	else
		return Indexes.Modules.Systems.Networker:SendPortData("CheckStun",nil,Options)

	end
end

function CombatService:CheckDebounce(Mod:Model,Options)
	if not Mod then return end
	local CharConfig = Indexes.Modules.Systems.CharacterManager(Mod).Data
	--[[if RunService:IsServer() then
		return FindDebounce(CharConfig,Options.DebounceType)
	else
		return Indexes.Modules.Systems.Networker:SendPortData("CheckDebounce",nil,Options)

	end]]
	return FindDebounce(CharConfig,Options.DebounceType)
end

function CombatService:AddCombatVal(CharConfig,Type:string,Options)
	Options = Options or {}
	if not CharConfig then return end
	local Data = CharConfig.Data
	local CharStats = Data.CharStats
	local Entry = CombatService.ComboValues[Type]
	if Entry then
		Entry = table.clone(Entry)
		table.insert(CharStats.Combo,Entry)
	end
end

function CombatService:ResetCombo(CharConfig,Options)
	Options = Options or {}
	if not CharConfig then return end
	local Data = CharConfig.Data
	local CharStats = Data.CharStats
	table.clear(CharStats.Combo)
end

if not CombatService.Running then
	CombatService.Running = true
	if RunService:IsClient() then
		Indexes:OnLoad(function()
		Indexes.Modules.Systems.Networker:CreatePort("Stun",function(Options)
			local Char = game.Players.LocalPlayer.Character
			if not Char then return end
			--local CharConfig = Indexes.Modules.Systems.CharacterManager(Char)
			CombatService:Stun(Char,Options)
		end,{
			
		})
		Indexes.Modules.Systems.Networker:CreatePort("RemoveStun",function(Options)
			local Char = game.Players.LocalPlayer.Character
			if not Char then return end
				local CharConfig = Indexes.Modules.Systems.CharacterManager(Char).Data
			CombatService:RemoveStunMarker(CharConfig,Options)
		end,{

		})
			Indexes.Modules.Systems.Networker:CreatePort("CheckStun",function(Options)
				local Char = game.Players.LocalPlayer.Character
				if not Char then return end
				return CombatService:CheckStun(Char,Options)
			end,{

			})
			Indexes.Modules.Systems.Networker:CreatePort("CheckDebounce",function(Options)
				local Char = game.Players.LocalPlayer.Character
				if not Char then return end
				return CombatService:CheckDebounce(Char,Options)
			end,{

			})
		end)
	end
end

return CombatService
