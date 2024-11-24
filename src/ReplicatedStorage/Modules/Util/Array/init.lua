local Lists = require(script:WaitForChild("Lists"))

local Array = {
	TableIndexes = {}
}

function Array:CountTable(Table:{},Settings)
	assert(typeof(Array) == "table","Array val not table")
	Settings = Settings or {}
	
	local NumbersOnly = Settings.NumbersOnly or false
	local NonRecursive = Settings.NonRecursive or false
	local Count = 0
	for i,v in Table do
		if NumbersOnly and typeof(i) == "number" or not NumbersOnly then
			Count += 1
		end
		if typeof(v) == "table" and not NonRecursive then
			Count += Array:CountTable(v,Settings)
		end
	end
	return Count
end

function Array:Compare(Array1:{any},Array2:{any})
	if Array1 == Array2 then return true end
	if typeof(Array1) ~= typeof(Array2) then return false end
	if typeof(Array1) == "table" then
		local IndexesChecked=  {}
		local Valid = true
	for i,v in Array1 do
		IndexesChecked[i] = true
		Valid = Array:Compare(v,Array2[i])
		if not Valid then return false end
	end
	for i,v in Array2 do
		if not IndexesChecked[i] then
			return false
		end
	end
		if Valid then return true end
	end
	return false
end

function Array:Override(Array1,Array2)
	if typeof(Array1) ~= "table" then
		return Array2
	end
	if typeof(Array2) ~= "table" then
		return Array1
	end
	for i,v in Array2 do
		if typeof(Array1[i]) == "table" then
			Array:OverrideTable(Array1[i],v)
		elseif Array1[i] == nil then
			Array1[i] = v
		elseif typeof(Array1[i]) == "function" and typeof(v) == "function" then
			Array1[i] = function(...)
				Array1[i](...)
				v(...)
			end
		end
	end
	
end



function Array:AddCleanupFunc(Array2,Cleanups)
	if not Array2 or not Cleanups then return end
	if typeof(Cleanups) == "function" then
		Cleanups = {Cleanups}
	end
	if typeof(Cleanups) ~= "table" then return end
	local Cleanup = Array2.Cleanup
	if typeof(Cleanup) == "table" then
		for i,v in Cleanups do
		table.insert(Cleanup,v)
		end
	elseif typeof(Cleanup) == "function" then
		table.insert(Cleanups,Cleanup)
		Array.Cleanup = Cleanups
	else
		Array.Cleanup = Cleanups
	end
end

function Array:Cleanup(Array2)
	if not Array2 then return end
	local ReportedFunc
	if typeof(Array2) == "table" then
		if Array2.Cleaning then return end
		Array2.Cleaning = true
		for i,v in Array2 do
			if typeof(v) == "table" then
				Array:Cleanup(Array2)
			elseif typeof(v) == "RBXScriptConnection" then
				v:Disconnect()
			elseif typeof(v) == "Instance" then
				if v:IsA("AnimationTrack") then
					v:Stop()
				end
				pcall(function()
				v:Destroy()
				end)
			elseif i == "Cleanup" and (typeof(v) == "function" or typeof(v) == "table") then
				ReportedFunc = v
			end
		end

	if typeof(ReportedFunc) == "function" then
		ReportedFunc = {ReportedFunc}
	end
	if typeof(ReportedFunc) == "table" and not Array.Cleaning then
		for i,v in ReportedFunc do
			v()
		end
	end
	table.clear(Array)
	Array.Cleaned = true
	end
end



function Array:SetIndex(ArrayInst:{},Index:string,Value,Func)
	if not Index  then
		print("Index doesnt exist",Index)
		return
	end
	if not ArrayInst then
		print("Array doesnt exist")
return
	end

local function FindInst()
	local Found
	local Index2 
	
	for i,v in Array.TableIndexes do
		if v.Table == ArrayInst and v.Index == Index then
			Found = v 
			Index2 = i
		end
	end
return Found,Index2
end
local Found = FindInst()
	if Found and Found.Task then
		task.cancel(Found.Task)
	end
	
	if not Found then
		Found = {
			Table = ArrayInst,
			Index =  Index
		}
		table.insert(Array.TableIndexes,Found)
	end
	if Func then
	Found.Task = task.spawn(function()
		if not Func() then
		repeat task.wait() until Func()
		end
		ArrayInst[Index] = Value
		local Found,Index = FindInst()
		if Index then
			Array.TableIndexes[Index] = nil
		end
return
	end)
	else
		ArrayInst[Index] = Value
		local Found,Index = FindInst()
		if Index then
			Array.TableIndexes[Index] = nil
		end
	end
end

function Array:CreateList()
	
end
return Array
