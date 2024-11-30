

local Knockback = {
	
}

Knockback.Func = function(HitTab,CharConfig,Options)
	local HitList = {}
	--if game:GetService("RunService"):IsServer() then
		CharConfig.Data.CharStats.Debounces.Hit = os.clock() + 1.2
		_G.Modules.GameSystems.CombatService:ResetCombo(CharConfig)
		
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
			BaseVel = 130,
			VelocityTrack = 1/1.4,
			TimeTake = .25
		})
		local HitboxTimes,Anim = HitTab.PlayAnim(CharConfig,{
			Type = "M2",
			Speed = 3
		})
		HitTab.ResetAnims(CharConfig,"All")
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
					HitType = "Knockback"
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
Knockback.Check = function(HitTab,CharConfig,Options)
	return not _G.Modules.GameSystems.CombatService:CheckDebounce(CharConfig.Controller,{
		DebounceType = "Hit"
	})
end
Knockback.CharHit = function(HitTab,CharConfig,Mod:Model)
	local Char:Model = CharConfig.Controller
	
	local EnemyConfig = _G.Modules.Systems.CharacterManager(Mod)
	local EnemyHum:Humanoid = Mod:FindFirstChildWhichIsA("Humanoid")
	local EnemyRoot:BasePart = Mod:FindFirstChild("HumanoidRootPart")
	if EnemyHum then
		EnemyHum.Health -= 1.6
	end
	_G.Modules.GameSystems.RenderService:HitEffect(EnemyRoot,{
		Type = "Knockback"
	})
	_G.Modules.GameSystems.CombatService:Stun(Mod,{
		TimeLast = 3,
		Killer = Char,
		Knockback = 250,
		StunType = "Light"
	})
	
end

return Knockback
