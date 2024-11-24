local PlatformManager = {
	Mods = {}
}



function PlatformManager:Check()
	
end

if not PlatformManager.Running then
	PlatformManager.Running = true
	for i,v in script:GetChildren() do
		if v:IsA("ModuleScript") then
			if v.Name ~= "Config" then
				PlatformManager.Mods[v.Name] = require(v)
			end
		end
	end
end
 
return PlatformManager
