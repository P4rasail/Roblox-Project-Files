local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local Types = {
	_index = {
		CurrentTypes = {},
		OGObjs = {}
	}
}
local Enums = {}



function new(TypeIndex,...)
	if not Types._index.Loaded then
		repeat task.wait() until Types._index.Loaded
	end

	if not Types[TypeIndex] then
		return
	end






end


local EnumMetatable = {
	__index = function(tab,index)
		local Get = rawget(Enums,index)
		if rawget(Enums,index) then
		
			print(Get)
return Get
		elseif Enum[index] then
			return Enum[index]
			
		end
	end,
}


local metatable = {
	__index = function(tab,index)

		if rawget(Types,"_index").CurrentTypes[index] then
			return rawget(Types,"_index").CurrentTypes[index]
		elseif index == "Enum" then
			return Enums
		else
			return rawget(tab,index)
		end
	end,
}


function Types:Override(Type:string,Val:{[string]:any},OverrideOptions)
	if not Type then return end
	OverrideOptions = OverrideOptions or {}
	local ReturnedType = Types._index.CurrentTypes[Type]
end

if not Types.Running then
	Types.Running = true
	Types.TypeIndex = {}


	--Indexes:OnLoad(function()
local AttemptedLoads = {}
		local function EnumAdded(v)
			if v:IsA("ModuleScript") then
				AttemptedLoads[v.Name] = false
				task.spawn(function()
				local Req = require(v)
				if typeof(Req) == "function" then
					Req = Req(Types,Enums)
				end
				--print(v)
				--print(Req)
				setmetatable(Req,{
					__call = function(tab,...)
						local Funcs = rawget(Req,"Funcs")
						if Funcs and Funcs.Construct then
							return Funcs.Construct(...)
						end
					end,
					__index = function(tab,index)
						--print(tab)
						
						local Funcs = rawget(Req,"Funcs")
						--print(Funcs)
						if Funcs and Funcs[index] then
							return Funcs[index]
						end
						local Raw = rawget(Req,"Enums")
						--print(Raw)
						if Raw then
							return rawget(Raw,index)
						end
						return rawget(Req,index)
					end,
				})
				Enums[v.Name] = Req
			AttemptedLoads[v.Name] = true
					
				end)
			end
		end
	--	print("Before Enums")
		for i,v in script:WaitForChild("Enums"):GetChildren() do
			--task.spawn(function()
			EnumAdded(v)
			--end)
		end
		script.Enums.ChildAdded:Connect(EnumAdded)
		--print("After Enums")
		local function Added(v)

			if v:IsA("ModuleScript") then
				local CurrentEntries = {}
				local function AddedDetail(x:Instance)
					if x:IsA("ModuleScript") then

						if not CurrentEntries[x.Name] then
							local Req = require(x)
							
							CurrentEntries[x.Name] = Req
						end
					end
				end
				local Func = require(v)
			if typeof(Func) == "function" then
				Func = Func(Types,Enums)
			end
				if Func then
					local CurrentInfo = Types._index.CurrentTypes[v.Name]
					if CurrentInfo then
						for e,x in Func do
							CurrentInfo[e] = x
						end
						local Val = Types._index.OGObjs[v.Name]
						for i,v in v:GetChildren() do
							v.Parent = Val
						end
						v:Destroy()

					else
						setmetatable(Func,{
							__call = function(tab,...)
								local Funcs = rawget(Func,"Funcs")
								if Funcs and Funcs.Construct then
									return Funcs.Construct(...)
								end
							end,
							__index = function(tab,index)

								local Funcs = rawget(Func,"Funcs")
								print(Funcs)
								if Funcs and Funcs[index] then
									return Funcs[index]
								end
						--[[local Raw = rawget(Req,"Enums")
						print(Raw)
						if Raw then
							return rawget(Raw,index)
						end]]
								return rawget(Func,index)
							end,
						})
						Types._index.OGObjs[v.Name] = v
						Types._index.CurrentTypes[v.Name] = Func
						for e,x in v:GetChildren() do
							AddedDetail(x)
						end
						v.ChildAdded:Connect(AddedDetail)
						
					end
				end
			end
		end
		for i,v in script:WaitForChild("Types"):GetChildren() do
			Added(v)
		end
		script:WaitForChild("Types").ChildAdded:Connect(Added)
		setmetatable(Types,metatable)
		setmetatable(Enums,EnumMetatable)
		local Valid = false
		repeat
			task.wait()
			Valid = true
			for i,v in AttemptedLoads do
				if not v then
					Valid = false 
					break 
				end
			end
		until Valid
		_G.Types = Types
		_G.Enums = Enums
		Types.Loaded = true
	--end)


end

return Types
