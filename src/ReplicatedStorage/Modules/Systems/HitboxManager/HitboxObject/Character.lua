--[[
   Creator: Paras/P4rasail
   Date: 2023/10/10
   Description: Character hitbox management.
   Functions: AddPart
   Example: HitboxObject:AddPart(parts)
   Generated by Copilot
]]

return function(HitboxObject)

	HitboxObject.EditMetatable({
		__index = function(tab,index)
			if index == "AddPart" then
				return function(parts)
					for i,v in parts do
						if not table.find(HitboxObject.CharStorage,v) then
							table.insert(HitboxObject.CharStorage,v)
						end
					end
				end
			
				
			else
				if rawget(tab,"_DESTROYED") then
					return
				end
				local Hitboxes = rawget(tab,"Hitboxes")
				if rawget(Hitboxes,index) then
					return rawget(Hitboxes,index)
				else
					return rawget(tab,index)
				end
			end
		end,

	})
if not HitboxObject.CharStorage then
	HitboxObject.CharStorage = {}
	end
	HitboxObject.OverlapParams = OverlapParams.new()
--	print(HitboxObject)
	HitboxObject.OverlapParams.Tolerance = .02
	HitboxObject.OverlapParams.MaxParts = 200
	HitboxObject.OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
	HitboxObject.OverlapParams.FilterDescendantsInstances = {
		workspace:WaitForChild("Effects"),
	}
	
	

	local function GetData(Part)
		if typeof(Part) ~= "Instance" and typeof(Part) ~= "table" then
			return 80
		end
		local Data = {}
		if typeof(Part) == "table" then
			for i,v in Part do
				Data[i] = v
			end
		elseif typeof(Part) == "Instance" then
			if Part:IsA("BasePart") then
				Data.Size = Part.Size
				Data.CFrame = Part.CFrame
			end
			if #(Part:GetChildren()) ~= 0 and not HitboxObject.ExcludeChildren then
				Data.Children = {}
				for i,v in Part:GetChildren() do
					table.insert(Data.Children,GetData(v))
				end
			end
		end
		return Data

	end
	local function OverrideTab(Results,Tab)
		for i,v in Results do
			if not table.find(Tab,v) then
				local Result = HitboxObject.FilterFunc(v)
				if Result then
					if typeof(Result) == "Instance" then
						table.insert(Tab,Result)
					else
						table.insert(Tab,v)
					end
				
				end
			end
		end
		return Tab
		
	end
	local function GetResults(Part,Tab)
		task.wait()
		Part = GetData(Part)
		if Part == 80 then return 80 end
		Tab = Tab or {}
		local SizeMod = HitboxObject.SizeMod or Vector3.one
		--print(Part)
		if Part.CFrame and Part.Size then
			local Size = Part.Size * SizeMod
			--print(Part.Size * Size)
		local Results = workspace:GetPartBoundsInBox(Part.CFrame,Size,HitboxObject.OverlapParams)
--print(Results)
OverrideTab(Results,Tab)

		end
		if Part.Children then
			for i,v in Part.Children do
				GetResults(v,Tab)
			end
		end
	--	print(Tab)
		return Tab
	end
	local function EvaluateHitbox(Part,Tab)
		
		
		
		local HitParts = Tab or {}
		local Start = os.clock()
		local Data = GetResults(Part,HitParts)
		if Data == 80 then
			return Data
		end
		--print("Time Took: ",os.clock() - Start)
		--print(Data)
		if Data.Children then
			for i,v in Data.Children do
				local Parts = EvaluateHitbox(v)
				OverrideTab(Parts,HitParts)
			end
		end
		return HitParts
	end
	HitboxObject.Runtime = task.spawn(function()
		--print(script:GetFullName())
		while script.Parent do
			task.wait()
			--print(HitboxObject)
			local Eval 
			for i,v in HitboxObject.CharStorage do
				HitboxObject.OverlapParams:AddToFilter(v)
				Eval  = EvaluateHitbox(v,Eval)
				--print(Eval)
				if Eval == 80 then
					table.remove(HitboxObject.CharStorage,i)
					continue
				else
					
				end
			end
			--task.wait()
			--print(unpack(HitboxObject.Funcs))
			--print(HitboxObject.Funcs)
			for e,x in HitboxObject.Funcs do
				--task.wait()
				if not x.Doing then
					--task.wait()
					x.Doing = true
					task.spawn(function()
						--print(Eval)
						local Return = x(Eval)
--print(Return)
						x.Doing = false
						if Return == "Destroy" then
							local Find = table.find(HitboxObject.Funcs,x)
							if Find then
								table.remove(HitboxObject.Funcs,Find)
							end
						end
					end)
				end
			end
		end
	end)

end