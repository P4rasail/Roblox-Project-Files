return function(BindInfo)
	
	local BindTable = {
	

	AutoSize = true,
	Offset = CFrame.new()
	}
	local FuncHooks = {}
	FuncHooks.SetColor = function(Part:Instance,ColorType,Color,Tween)
		
	end
	BindInfo.FuncHooks = FuncHooks
	BindInfo.Connections = {
		
	}
	
	return BindTable
	
	end