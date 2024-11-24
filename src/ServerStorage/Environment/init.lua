local Environment = {}

function Environment:Load(CharController)
	Environment.CharController = CharController
	for i,v in script:GetChildren() do
		task.spawn(function()
			require(v)(Environment)
		end)
	end
end

return Environment
