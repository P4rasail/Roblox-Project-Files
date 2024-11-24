local HitboxInfo = {
	Hitboxes = {}
}

if not HitboxInfo.Running then
	HitboxInfo.Running = true
	local function Added(v:ModuleScript)
		if v:IsA("ModuleScript") then
			HitboxInfo.Hitboxes[v.Name] = require(v)
		end
		--print(HitboxInfo)
	end
	for i,v in script:GetChildren() do
		Added(v)
	end
	script.ChildAdded:Connect(Added)
end
return HitboxInfo
