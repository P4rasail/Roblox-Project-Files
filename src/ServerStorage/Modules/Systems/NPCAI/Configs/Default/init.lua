
local Tab = {
	AILevel = 5
}

function Tab:Load(Script:ModuleScript)
	local ConfigsScr = Script:WaitForChild("Configs")
	
	local Configs = script:FindFirstChild("Configs")
	if Configs then
		for i,v in Configs:GetChildren() do
			v:Clone().Parent = ConfigsScr
		end
	end
	local DataStore = script:FindFirstChild("DataStore")
	if DataStore then
		DataStore:Clone().Parent = Script
	end
end

if not Tab.Running then
	Tab.Running = true
	
end
return Tab