local Config = {}

Config.Init = function(CharConfig,Index)
	for i,v in Config do
		if i ~= "Init" then
		CharConfig[i] = v
		end
	end
end
Config.ChildAdded = function(Args)
	Args = Args or {}
	local NewInst:Instance = Args.Instance
	local CurrentTab = Args.CurrentTab
	local CharConfig = Args.CharConfig
	local Req = Args.Req
	if typeof(Req) == "table" then
		for i,v in Req do
			CharConfig[i] = v
		end
	else
		CharConfig[NewInst.Name] = Req or NewInst
	end
	

end

return Config
