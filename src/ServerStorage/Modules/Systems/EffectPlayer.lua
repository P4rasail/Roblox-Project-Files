local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))



local EffectPlayer = {}

function EffectPlayer:ShiftFlight(Char:Model,Options)
	Options = Options or {}
	--print(Char)
	--print(Options)
	Indexes.Modules.GameSystems.RenderService:ShiftFlight(Char,Options)
end
function EffectPlayer:Dash(Char:Model,Options)
	Options = Options or {}
	--print(Char)
	--print(Options)
	Indexes.Modules.GameSystems.RenderService:Dash(Char,Options.Holding)
end
function EffectPlayer:HitEffect(HumRootPart:BasePart,Options)
	Options = Options or {}
	--print(Char)
	--print(Options)
	Indexes.Modules.GameSystems.RenderService:HitEffect(HumRootPart,Options)
end

return EffectPlayer
