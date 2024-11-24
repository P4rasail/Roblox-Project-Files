

local Default = {
	Values = {
		
		
	},
	Actions = {
		Flight = function(NPCObject,Set)
			NPCObject.CharConfig:DoAction("Flight",{
				Toggle = Set
			})
		end,
		LockOn = function(NPCObject,Target)
			NPCObject.CharConfig:DoAction("LockOn",{
				Target = Target
			})
		end,
		Press = function(NPCObject,Key,Hold)
			NPCObject:Press(Key,Hold)
		end,
	},
	CostIndexes = {
		Stunned = 1,
		Knockback = 4
	},
	

}
local BattleEntries = {}
Default.SetBattleEnter = function(Func)
	if typeof(Func) ~= "function" then return end
	table.insert(BattleEntries,Func)
end
Default.SetBattleEnter(function(NPCObject)
	local CharConfig = NPCObject.CharConfig
	if not CharConfig.Data.CharStats.InBattle then
		CharConfig.Data.CharStats.InBattle = true
	end
end)

local Amount = 0
local Tab = Default.Values
for i,v in Tab do
	Amount += 1
end
local KeyPresses = {
	"W",
	"A",
	"S",
	"D",
	"Space",
	"LeftControl",
	"MouseButton1",
	"MouseButton2",

}



for i,v in KeyPresses do
	Amount += 1
	local Entry = {
		Action = "Press",
		Args = {
			v,
			true
		},
		Value = Amount,
		CurrentVal = 0
	}
	table.insert(Tab,Entry)
	Entry = table.clone(Entry)
	Amount += 1
	Entry.Args[2] = false
	Entry.Value = Amount
	table.insert(Tab,Entry)
	
end

function Iterate(TabAdd,Config)
	Config = Config or {}
	for i,v in TabAdd do
		Amount += 1
		local Entry = {
			Action = i,
			Args = v(true),
			Value = Amount,
			CurrentVal = 0
		}
		table.insert(Tab,Entry)
		if not _G.Modules.Util.Array:Compare(v(true),v(false)) then
		Entry = table.clone(Entry)
		Amount += 1
		Entry.Args = v(false)
		Entry.Value = Amount
		table.insert(Tab,Entry)
		end

	end
end
local AdditionalActions = {
	Flight = function(Correct)
		return {
			Correct
		}
	end,
	LockOn = function(Correct)
		return {
			script

			
			
		}
	end,
	
}


Iterate(AdditionalActions)

Default.Init = function(NPCObject)
	repeat task.wait() until NPCObject.CharConfig
	local CharConfig = NPCObject.CharConfig
	local Signals = CharConfig.Signal
	if Signals.SetBattleEnter then return end
	Signals.ReadyBattle = function()
		for i,v in BattleEntries do
			task.spawn(function()
				v(NPCObject)
			end)
		end
	end
	Signals.SetBattleEnter = Default.SetBattleEnter
end


return Default