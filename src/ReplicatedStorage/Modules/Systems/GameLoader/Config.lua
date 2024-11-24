local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
local Config = {
	Important = {
		Modules:WaitForChild("Util"),
		Modules:WaitForChild("Systems"),
		
	},
	Skippable = {
		game:GetService("MaterialService"),
		game:GetService("ReplicatedStorage"),
		game:GetService("Lighting"),
		--workspace
	}
}

return Config
