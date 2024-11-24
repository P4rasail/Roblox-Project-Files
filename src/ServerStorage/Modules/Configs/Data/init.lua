local RepStorage = game:GetService("ReplicatedStorage")

local Indexes=  require(RepStorage:WaitForChild("Indexes"))

local Data = {}

if not script:GetAttribute("Running") then
	script:SetAttribute("Running",true)
	Indexes:OnLoad(function()
	local function ChildAdded(v:ModuleScript) 
		if v:IsA("ModuleScript") then
			local Req = require(v)
			local CurrentTab = Data[v.Name] or {}
			Indexes.Modules.Util.Array:Override(CurrentTab,Req)
			Data[v.Name] = CurrentTab
		end
	end
	for i,v in script:GetChildren() do
		ChildAdded(v)
	end
	script.ChildAdded:Connect(ChildAdded)
	end)
end

return Data
