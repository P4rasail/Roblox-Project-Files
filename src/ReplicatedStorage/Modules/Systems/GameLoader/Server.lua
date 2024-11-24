local RunService = game:GetService("RunService")

return function(GameLoader)
	local Loaded = {}
	_G.Modules.Systems.Networker:CreatePort("GameLoad",function(Player:Player,Type)
		if not Loaded[Player] then
			Loaded[Player] = true
		_G.LoadChar(Player)
		--_G.print(`{Player} Loaded!`)
		end
	end)
end