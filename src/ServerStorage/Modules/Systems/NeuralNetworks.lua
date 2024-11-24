local RepStorage = game:GetService("ReplicatedStorage")
local DSService = game:GetService("DataStoreService")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local NeuralNetworks = {}

function NeuralNetworks.new(Key:string,Config)
	if NeuralNetworks[Key] then
		return NeuralNetworks[Key]
	end
	local Tab = {
		
	}
end

return NeuralNetworks
