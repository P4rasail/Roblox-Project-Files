local RepStorage = game:GetService("ReplicatedStorage")

local Events = RepStorage:WaitForChild("Events")

local Indexes = require(RepStorage:WaitForChild("Indexes"))
local PartAmounts = {}
print("GetGameInfo")
_G.GetGameInfo = function(player,Inst:Instance)
	if Inst and typeof(Inst) == "Instance" then
		if not Indexes.Loaded then
			repeat task.wait() until Indexes.Loaded
		end
		if PartAmounts[Inst] then
			return PartAmounts[Inst]
		end
		local Count = Indexes.Modules.Util.Array:CountTable(Inst:GetDescendants())
		PartAmounts[Inst] = Count
		local Events = {}
		table.insert(Events,Inst.DescendantAdded:Connect(function()
			PartAmounts[Inst] += 1
		end))
		table.insert(Events,Inst.DescendantRemoving:Connect(function()
			PartAmounts[Inst] -= 1
		end))
		Inst.Destroying:Once(function()
			for i,v in Events do
				v:Disconnect()
			end
			table.clear(Events)
			PartAmounts[Inst] = nil
		end)
		return Count
	end
end
Indexes:Load()


Events.GetGameInfo.OnServerInvoke = _G.GetGameInfo