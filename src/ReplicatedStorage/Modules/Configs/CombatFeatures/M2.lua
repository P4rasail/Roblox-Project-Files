

local M1 = {
	
}

M1.Func = function(HitTab,CharConfig,Options)
	local HitList = {}
	--if game:GetService("RunService"):IsServer() then
	CharConfig.Data.CharStats.Debounces.Hit = os.clock() + .4
	CharConfig.Data.CharStats.Debounces.M2 = os.clock() + .4
		_G.Modules.GameSystems.CombatService:AddCombatVal(CharConfig,"M2",{})
	--end
	if CharConfig.PlayerServer then  
		
	else
		CharConfig:DoAction("ShiftFlight",{
			Holding = false
		})
		local Animator = CharConfig.Animator
		local Mover = CharConfig.Mover
		local AnimManager =  _G.Modules.Systems.AnimManager
		HitTab.Lunge(CharConfig,{
			BaseVel = 140,
			VelocityTrack = 1/1.4,
			TimeTake = .5
		})
		local HitboxTimes,Anim = HitTab.PlayAnim(CharConfig,{
			Type = "M2",
			Speed = 1.9
		})
	local Controller=  CharConfig.Controller
	HitTab.HitDetect(CharConfig,{
		Model = Controller["HumanoidRootPart"],
			Extensions = {
				Controller["Left Arm"],
				Controller["Right Arm"],
				Controller["Left Leg"],
				Controller["Right Leg"]
			},
		HitFunc = function(Found,List)
			--print(List)
			
			--print(Found)
			if #Found > 0 then
				
				HitTab.Hit(CharConfig,{
					List = Found,
					HitType = "M2"
				})
				--print("Hit")
				--print(Found)
				return "Destroy"
				
			end
		end,
			HitboxTimes = HitboxTimes,
			Anim = Anim
	})
	end
end
M1.Check = function(HitTab,CharConfig,Options)
	return not _G.Modules.GameSystems.CombatService:CheckDebounce(CharConfig.Controller,{
		DebounceType = "Hit"
	})
end
M1.CharHit = function(HitTab,CharConfig,Mod:Model)
	local Char:Model = CharConfig.Controller
	
	local EnemyConfig = _G.Modules.Systems.CharacterManager(Mod)
	local EnemyHum:Humanoid = Mod:FindFirstChildWhichIsA("Humanoid")
	local EnemyRoot:BasePart = Mod:FindFirstChild("HumanoidRootPart")
	if EnemyHum then
		EnemyHum.Health -= 1.1
	end
	_G.Modules.GameSystems.RenderService:HitEffect(EnemyRoot,{
		Type = "LightHit"
	})
	_G.Modules.GameSystems.CombatService:Stun(Mod,{
		TimeLast = 1.5,
		Killer = Char,
		Knockback = 25,
		StunType = "Light"
	})
	
end

return M1
