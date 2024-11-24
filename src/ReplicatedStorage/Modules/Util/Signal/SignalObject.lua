local SignalObject = {
	Signals = {}
}

local SignalFuncs = {}

function SignalObject:CheckIfSignal(Signal)
	if typeof(Signal) ~= "table" then return false end
	return Signal.IsSignal == true and true or false
end


function SignalObject:Create(SignalName:string)
	if SignalObject[SignalName] then
		return SignalObject[SignalName]
	end
	local Signal = {
		Name = SignalName,
		Funcs = {},
		IsSignal = true
	}
	function Signal:Connect(Func)
		if typeof(Func) ~= "function" then
			print(debug.traceback("Func not a function like required",10))
			return
		end
		local Found = table.find(Signal.Funcs,Func)
		if Found then
			print(debug.traceback("Function already exists",10))
		else
			table.insert(Signal.Funcs,Func)
		end
		
	end
	setmetatable(Signal,{
		__call = function(tab,...)
			if rawget(tab,"_DESTROYED") then
				return
			end
			--print(tab.Funcs)
			for i,v in tab.Funcs do
				task.spawn(v,...)
			end
		end,
		__newindex = function(tab,index,val)
			if rawget(tab,"_DESTROYED") then
				return
			end
			if index == "_DESTROYED" and val == true then
				rawset(tab,index,true)
				local Tab = rawget(tab,"Funcs")
				table.clear(Tab)
				
				for i,v in tab do
					if i ~= "_DESTROYED" then
					rawset(tab,i,nil)
					end
				end
			end
			if index == "Funcs" then
				print("Attempt to override Signal funcs, N O")
			elseif index == "IsSignal" then
				
			else
				print(index,val)
				if typeof(val) == "function" then
					Signal:Connect(val)
				end
	
			end
		end,
		__index = function(tab,index)
			if rawget(tab,"_DESTROYED") then
				return
			end

			return rawget(tab,index)
		end,
	})
	SignalObject[SignalName] = Signal
	return Signal
	
	
	
end



function SignalObject:Call(SignalName:string,...)
	local Signal = SignalObject[SignalName]
	if Signal then
	Signal(...)
	else
		print(debug.traceback(`Signal {SignalName} does not exist`,10))
		
	end
end



if not SignalObject.Running then
	SignalObject.Running = true
	setmetatable(SignalObject,{
		__index = function(tab,index)
			if rawget(tab,"_DESTROYED") then
				return
			end
			local Signals = rawget(tab,"Signals")
			if Signals[index] then
				return Signals[index]
			else
				return rawget(SignalObject,index)
			end

		end,
		__newindex = function(tab,index,val)
			if rawget(tab,"_DESTROYED") then
				return
			end
			if index == "_DESTROYED" and val == true then
				rawset(tab,index,true)
				for i,v in rawget(tab,"Signals") do
					
				end
				for i,v in tab do
					if i ~= "_DESTROYED" then
					rawset(tab,i,nil)
					end
				end
			end
			if index == "Signals" then
				print("Stop yo goofy ass fuckin w the shit")
			else
				--print(tab,index,val)
				local Index = rawget(tab,index)
				if typeof(Index) == "function" then
					print(`attempted to set natural function of signal {index}. N O`)
				elseif index == "Running" then
					
				else
					local Signals = rawget(tab,"Signals")
					local Signal  =rawget(Signals,index)
					if Signal then
						if typeof(val) == "function" then
							Signal:Connect(val)
						end
					else
						if SignalObject:CheckIfSignal(val) then
							rawset(Signals,index,val)
						elseif typeof(val) == "function" then
							local Obj = SignalObject:Create(index)
							--print(Obj)
							Obj:Connect(val)
							
							
						end
				end
				end
				
			end
			
		end,

	})
	SignalObject.Cleanup = function()
		SignalObject._DESTROYED = true
	end
	script.Destroying:Once(function()
		SignalObject.Cleanup()
	end)
end

return SignalObject
