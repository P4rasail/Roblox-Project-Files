return function(NPCObject)
	
	local CharConfig = NPCObject.CharConfig
	 
	repeat task.wait() until  CharConfig.Signal and NPCObject.Configs and NPCObject.Configs.SetBattleEnter
	local Config = NPCObject.Configs
	local Signals = CharConfig.Signal
	if Signals.Stunned then return end
	--print(Config)
NPCObject.Costs.Stun = 0
Config.SetBattleEnter(function()
		NPCObject.Costs.Stun = 0
end)
	Signals.Stunned = function(AmountTimeStunned:number,AmountKnockback:number)
		NPCObject.Costs.Stun -= AmountTimeStunned * NPCObject.Configs.CostIndexes.Knockback
	end
	local Delta = 0
	local OldTime = os.clock()
	--print("Flight")
	--print(NPCObject.CharConfig.Controller)
	NPCObject.CharConfig:DoAction("Flight",{
		Toggle = true
	})
	local Total = 0
	local On = 1
	--print(NPCObject)
	local Data = CharConfig.Data
	local CharStats = Data.CharStats
	local Amount = #(CharStats.HitBy)
	local function Determine()
		Amount = #(CharStats.HitBy)
		if Amount > 0 then
			if CharConfig.LockTask then
				task.cancel(CharConfig.LockTask)
			end
			CharConfig.LockTask = task.delay(100,function()
				CharConfig.LockedOn = nil
				NPCObject:Press("W",{
					Holding = false
				})
			end)
			CharConfig.LockedOn = CharStats.HitBy[Amount].Killer
			NPCObject:Press("W",{
				Holding = true
			})
			
		end
	end
	Determine()
	while CharConfig.Controller do
		task.wait()
		Delta = os.clock() - OldTime
		OldTime = os.clock()
		Total += Delta
		NPCObject.Costs.Stun += Delta - NPCObject.Configs.CostIndexes.Stunned
		if Amount ~= #(CharStats.HitBy) then
			Determine()
		end
		
		if Total >= .2 and CharConfig.LockedOn then
			On = (On + 1)%4
			Total = 0
--print(NPCObject)
			if not NPCObject.NPCConfigs.Passive then
			NPCObject.CharConfig:DoAction("Hit",{
				Type = "M1"
			})
			end
			--[[NPCObject:Press("W",{
				Holding = On ~= 3
			})
			NPCObject:Press("Space",{
				Holding =  On ~= 2
			})]]
		end
		
	end
end