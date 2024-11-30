

local M1 = {
	
}

M1.Func = function(HitTab,CharConfig,Options)
	local HitList = {}
	--if game:GetService("RunService"):IsServer() then
		CharConfig.Data.CharStats.Debounces.Hit = os.clock() + .25
	CharConfig.Data.CharStats.Debounces.M1 = os.clock() + .25
		_G.Modules.GameSystems.CombatService:AddCombatVal(CharConfig,"M1",{})
	--end
	if CharConfig.PlayerServer then  
		
	else
		local Animator = CharConfig.Animator
		local Mover = CharConfig.Mover
		local AnimManager =  _G.Modules.Systems.AnimManager
		CharConfig:DoAction("ShiftFlight",{
			Holding = false
		})
		HitTab.Lunge(CharConfig,{
			BaseVel = 80,
			VelocityTrack = 1/1.4,
			TimeTake = .2
		})
		local HitboxTimes,Anim = HitTab.PlayAnim(CharConfig,{
			Type = "M1",
			Speed = 3
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
					HitType = "M1"
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
		EnemyHum.Health -= .8
	end
	_G.Modules.GameSystems.RenderService:HitEffect(EnemyRoot,{
		Type = "LightHit"
	})
	_G.Modules.GameSystems.CombatService:Stun(Mod,{
		TimeLast = 1,
		Killer = Char,
		Knockback = 20,
		StunType = "Light"
	})
	
end

return M1
