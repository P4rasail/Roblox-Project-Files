local RepStorage = game:GetService("ReplicatedStorage")

local Modules = RepStorage:WaitForChild("Modules")

local Systems = Modules:WaitForChild("Systems")

local GameLoader = require(Systems:WaitForChild("GameLoader"))

GameLoader:Load()