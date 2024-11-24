local RunService = game:GetService("RunService")

local Tweens = {
	Tweens = {},
	Functions = {}
}
local Props = {
	GUIObject = {
		Position = UDim2.new()
	}
}
export type Entry = {
	Property:string,
	Value:{any},
	Time:number

}

function Correct(Object)
	if typeof(Object) ~= "table" then
		return {Object}
	end
	return Object
end
function CorrectEntry(Object)
	if typeof(Object) == "table" then
		if typeof(Object[1]) ~= "table" then
			Object = {Object}
		end
		return Object
	end
end

function InitiateTweenObj(Object:GuiButton)
	if not Tweens.Tweens[Object] then
		Tweens.Tweens[Object] = {}
	end
	if not Tweens.Functions[Object] then
		Tweens.Functions[Object] = {}
	end
end

local UDimTypes = {
	{
		Name = "X",
		Types = {
			"Scale",
			"Offset"
		}
	},
	{
		Name = "Y",
		Types = {
			"Scale",
			"Offset"
		}
	}
}
local ColorTypes = {
	"R",
	"G",
	"B"
}
function Tweens:Lerp(Object:GuiButton,Property:string,Value2:any,Alpha:number)
	local Type = typeof(Object[Property])
	if Type == "number" or Type == "Vector3" or Type == "Vector2" then
		Object[Property] += (Value2-Object[Property]) * Alpha
	elseif Type == "UDim2" then
		local Obj = {}

		for i,v in UDimTypes do
			for e,x in v.Types do
				local Val = Object[Property][v.Name][x] + (Value2[v.Name][x] - Object[Property][v.Name][x]) * Alpha
				table.insert(Obj,Val)
			end
		end
		Object[Property] = UDim2.new(unpack(Obj))
	elseif Type == "Color3" then
		local Obj = {}
		for i,v in ColorTypes do
			local Val = Object[Property][v] + (Value2[v] - Object[Property][v] ) * Alpha
			table.insert(Obj,Val)	
		end
		Object[Property] = Color3.new(unpack(Obj))
	elseif Type == "CFrame" then
		Object[Property] = Object[Property]:Lerp(Value2,Alpha)
	end
end

function Tweens:AddTween(Object:GuiButton,Entries:{Entry},Options:{
	Completed:()->()?,
	UseLastFunc:boolean?
	}?)
	Options = Options or {}
	Entries = Correct(Entries)
	if not Entries or not Object then return end
	InitiateTweenObj(Object)
	local Tab = Tweens.Tweens[Object]
	local Funcs = Tweens.Functions[Object]

	for i,v in Entries do
		local success = pcall(function()
			Object[v.Property] = Object[v.Property]
		end)
		if not success then
			table.remove(Entries,i)
		end
	end
	for i,v in Entries do
		if Options.UseLastFunc then
		if Funcs[v.Property] then
			task.spawn(Funcs[v.Property])
		end
		end
		if Tab[v.Property] then
			task.cancel(Tab[v.Property])
		end
		Funcs[v.Property] = Options.Completed
		Tab[v.Property] = task.spawn(function()
			for e,x in v.Value do
				local TimeTake = v.Time / #(v.Value)
--				print(TimeTake)
				local Delta = 0
				local OldTime = os.clock()
				local OsTime = os.clock() + TimeTake
				while os.clock() < OsTime do
					task.wait()
					Delta = os.clock() - OldTime
					OldTime = os.clock()
					Tweens:Lerp(Object,v.Property,x,(.12/TimeTake) ^ (1-Delta))

				end
				
				Object[v.Property] = x
				--print(Object[v.Property])
			end
			if Options.Completed then
				Options.Completed()
			end
			return
		end)
	end
end

return Tweens
