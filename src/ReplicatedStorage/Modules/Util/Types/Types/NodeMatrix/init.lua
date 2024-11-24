local DefaultEntry = {
}
function CopyTable(Table)
	
end

function GetMatriceSize(Matrix)
	if not Matrix then return end
	local MatriceSizes = {#Matrix,0}
	local MaxHeight = 0
	for i,v in Matrix do
		MaxHeight = math.max(MaxHeight,#v)
	end
	MatriceSizes[2] = MaxHeight
	return MatriceSizes
end

function GetTotal(Matrix)
	if typeof(Matrix) ~= "table" then return 0 end
	local Total = 0
	for i,v in Matrix.Nodes do
		Total += v.Value
		if typeof(v.Nodes) == "table" then
			Total += GetTotal(v)
		end
	end
	return Total
end



function OperateNumToMatrix(Entry1,Number,OperateFunc)
	OperateFunc = OperateFunc or "Add"
	if not Entry1 or not Number then return end
	Entry1 = CopyTable(Entry1)
	
	for i,v in Entry1.Nodes do
		if OperateFunc == "Add" then
			v.Value += Number
		elseif OperateFunc == "Subtract" then
			v.Value -= Number
		elseif OperateFunc == "Multiply" then
			v.Value *= Number
		elseif OperateFunc == "Divide" then
			v.Value /= Number
		elseif OperateFunc == "Power" then
			v.Value ^= Number
		elseif OperateFunc == "Log" then
			v.Value = math.log(v.Value,Number)
		elseif OperateFunc == "Set" then
			v.Value = Number
		end
		if v.Nodes then
			OperateNumToMatrix(v,Number,OperateFunc)
		end
	end
	return Entry1
end

function GetShorter(Entry1,Entry2)
	if not Entry1 then
		return {#(Entry2.Nodes)}
	end
	if not Entry2 then
		return {#(Entry1.Nodes)}
	end
	local Comparison = {}
	Comparison[1] = math.min(#(Entry1.Nodes),#(Entry2.Nodes))
	if typeof(Entry1.Nodes[1]) == "table" and typeof(Entry2.Nodes[1]) == "table" then
		local newComparison = GetShorter(Entry1.Nodes[1],Entry2.Nodes[2])
		for i,v in newComparison do
			table.insert(Comparison,v)
		end
	end
	return Comparison
end



function OperateMatrices(Entry1,Entry2,OperateFunc,Optional)
	if not Entry1 or not Entry2 then return end
	Entry1 = CopyTable(Entry1)
	Optional = Optional or {}
	local Shorter = GetShorter(Entry1,Entry2)
	local function SetRepeat(Place1,Place2,Index)
		for i = 1, Shorter[Index].Nodes do
			
			if typeof(Place1.Nodes[i].Value) == "number" and typeof(Place2.Nodes[i].Value) == "number" then
				if OperateFunc == "Add" then
					Place1.Nodes[i].Value += Place2.Nodes[i].Value
					elseif OperateFunc == "Subtract" then
					Place1.Nodes[i].Value -= Place2.Nodes[i].Value
				elseif OperateFunc == "Multiply" then
					Place1.Nodes[i].Value *= Place2.Nodes[i].Value
				elseif OperateFunc == "Divide" then
					Place1.Nodes[i].Value /= Place2.Nodes[i].Value
				elseif OperateFunc == "Power" then
					Place1.Nodes[i].Value ^= Place2.Nodes[i].Value
				elseif OperateFunc == "Log" then
					Place1.Nodes[i].Value = math.log(Place1.Nodes[i].Value,Place2.Nodes[i].Value)
				elseif OperateFunc == "Set" then
					Place1.Nodes[i].Value = Place2.Nodes[i].Value
				end
			end
			if typeof(Place1.Nodes[i].Nodes) == "table" and typeof(Place2.Nodes[i].Nodes) == "table" then
				SetRepeat(Place1.Nodes[i],Place2.Nodes[i],Index + 1)
				end
		end
	end
	SetRepeat(Entry1,Entry2,1)
	return Entry1
end

function Operation(Entry1,Entry2,OperationType)
	OperationType = OperationType or "Set"
	if typeof(Entry1) == "number" then
		if typeof(Entry2) == "number" then
			return 
		end

		return OperateNumToMatrix(Entry2,Entry1,OperationType)
	
elseif typeof(Entry2) == "number" then
		return OperateNumToMatrix(Entry1,Entry2,OperationType)

end
	return OperateMatrices(Entry1,Entry2,OperationType)

end

local AcceptableDivisions = {}

local function DoOperation(tab1,tab2,typeOperation)
	if typeof(tab2) == "number" or typeof(tab2) == "table" then
		return Operation(tab1,tab2,typeOperation)
	end
end

local Metatable = {
	__add = function(tab1,tab2)
		return DoOperation(tab1,tab2,"Add")
	end,
	__sub = function(tab1,tab2)
		return DoOperation(tab1,tab2,"Subtract")
	end,
	__mul = function(tab1,tab2)
		return DoOperation(tab1,tab2,"Multiply")
	end,
	__div = function(tab1,tab2)
		return DoOperation(tab1,tab2,"Divide")
	end,
	__pow = function(tab1,tab2)
		return DoOperation(tab1,tab2,"Add")
	end,
	__lt = function(tab1,tab2)
		local Operations = {
			GetTotal(tab1),
			GetTotal(tab2)
		}
		if #Operations == 0 then return true end
		return Operations[1]< Operations[2]
	end,
	__le = function(tab1,tab2)
		local Operations = {
			GetTotal(tab1),
			GetTotal(tab2)
		}
		if #Operations == 0 then return true end
		return Operations[1] <= Operations[2]
	end,
	__tostring = function(tab)
		local STR = "\n"
		for i,v in tab do
			for e,x in v do
				STR = STR.." "..tostring(x)
			end
			STR = STR.."\n"
		end
		return STR
	end,


}
CopyTable = function(Tab1)
	Tab1 = table.clone(Tab1)
	setmetatable(Tab1,Metatable)
	return Tab1
end
function CreateDefaultMatrix(Dimensions:{any},StartNum:number?)
	StartNum = StartNum or 0

	local Matrix = {
		Nodes = {},
		Value = StartNum
	}
	local CurrentNode = Matrix
	local function SetDimension(CurrentNode,Index)
		Index = Index or 1
		for i = 1, Dimensions[Index] do
			local Tab = {
				Value = StartNum
			}
			if Dimensions[Index + 1] then
				Tab.Nodes = {}
				SetDimension(Tab,Index + 1)
			end
			table.insert(CurrentNode.Nodes,Tab)
		end
	end
	SetDimension(Matrix,1)

	setmetatable(Matrix, Metatable)
	return Matrix
end

function BindMatrix(Matrix)
	setmetatable(Matrix,Metatable)
end

function ModifyMatrix(Matrix1,Matrix2)
	if not Matrix1 then return Matrix2 end
	if not Matrix2 then return Matrix1 end
	
end



local Funcs = {
	Construct = function(...)
		local Args = {...}
		if #Args == 2 then
		return CreateDefaultMatrix(Args[1],Args[2],0)
		elseif #Args == 3 then
			if typeof(Args[3]) == "table" then
				local Matrice = CreateDefaultMatrix(Args[1],Args[2],0)
				return Operation(Matrice,Args[3],"Set")
			elseif typeof(Args[3]) == "number" then
				return CreateDefaultMatrix(Args[1],Args[2],Args[3])
			end
		elseif #Args == 1 then
			if typeof(Args[1]) == "table" then
				BindMatrix(Args[1])
			elseif typeof(Args[1]) == "number" then
				local Dimensions = {}
				for i = 1,Args[1] do
					table.insert(Dimensions,Args[1])
				end
				return CreateDefaultMatrix(Dimensions,Args[1],0)
			end
		end
	end,
	
}
return {
	Funcs = Funcs

}