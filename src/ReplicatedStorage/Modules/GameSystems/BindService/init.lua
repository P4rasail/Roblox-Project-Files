local BindService = {
	List = {},
	Types = {}
}

function BindTo(Model:Model,Target:Model,BindInfo,PastFirst,Parent)
	--print(BindInfo)
local Valid = Parent
	for i,v in Model:GetChildren() do
		if not Valid then
			Parent = v
		end
		local FindConnection = BindInfo["FindConnection"] and BindInfo.FindConnection(v,Target)
		if not FindConnection then
			FindConnection = Target:FindFirstChild(v.Name)
		end
		if not PastFirst and not FindConnection then
			continue
		end
		
		if PastFirst then
			FindConnection = Target
		end
		
		--print(FindConnection)
		for e,x in BindService.Types do
			if v:IsA(e) then

				x.Init(BindInfo,v,FindConnection,Valid and Parent or v.Parent)
				break
			end
		end
		if #(v:GetChildren()) ~= 0 then
			BindTo(v,FindConnection,BindInfo,true,Parent)
		end
	end
end

function BindService:Bind(Model:Model,Target:Model,Config)
--print("Bind")
--print(Target)
	Config = Config or {}
	if not Model and not Config.Unbind then
		error("Model is nonexistent")
		return
	end
	if not Target then
		error("Target is nonexistent")
		return
	end
	
	local Tag = Config.Tag or "Default"
	local Unbind = Config.Unbind
	
	for i,v in Target:GetChildren() do
		if v:GetAttribute("BindService") then
			if v.Name == Tag then
				v:SetAttribute("Stopped",true)
			end
		end
	end
	if not BindService.List[Target] then
			BindService.List[Target] = {}
			Target.Destroying:Once(function()
				for i,v in BindService.List[Target] do
				if v["Cleanup"] then
					task.spawn(function()
						v.Cleanup()
					end)
				end
				v.Model:Destroy()
			end
				print("WOAHOK")
				table.clear(BindService.List[Target])
				BindService.List[Target] = nil
				Target:ClearAllChildren()
				print(BindService.List)
		end)
	end
	if not Unbind then
		if not Model then return end
		Model = Model:Clone()
		local BindInfo = {
			ClothIndexes = {},
			Target = Target,
			Origins = {},
			Events = {},
			Offset = Config.Offset or CFrame.new(),
			Emit = Config.Emit
		}
		if typeof(BindInfo.Offset) == "Vector3" then
			BindInfo.Offset = CFrame.new(Vector3.zero,BindInfo.Offset)
		end
		local BindOptions = Model:FindFirstChild("BindOptions")
		if BindOptions and BindOptions:IsA("ModuleScript") then
			BindOptions = require(BindOptions)(BindInfo)
		else
			BindOptions = {}
		end
		BindInfo.BindOptions = BindOptions
		Model.Name = Tag
		Model:SetAttribute("Delay",0)
		Model:SetAttribute("BindService",true)
		local function Thing()
			if BindInfo.Events then
			for i,v in BindInfo.Events do
				v:Disconnect()
			end
			end
			table.clear(BindInfo)
		end
		
		Model:GetAttributeChangedSignal("Stopped"):Connect(function()
			if Model:GetAttribute("Stopped") then
				Thing()
				--print(Model:GetAttribute("Delay"))
				task.delay(Model:GetAttribute("DelayOverride") or Model:GetAttribute("DoDelay") and Model:GetAttribute("Delay"),function()
					Model:Destroy()
				end)
			end
		end)
Model.Destroying:Once(function()
	--Event:Disconnect()
			Thing()
	for i,v in Model:GetDescendants() do
		v:Destroy()
	end
	
	
	
end)

for i,v in Model:GetChildren() do
	if v:IsA("Humanoid") then
		v:Destroy()
	end
end
		BindTo(Model,Target,BindInfo)
		Model.Parent = Target
		BindInfo.Model = Model
		BindService.List[Target][Tag] = BindInfo
	
			
		if BindInfo.Emit then
			task.spawn(function()
		
			repeat task.wait() until BindInfo.MaxTime
			local Start = os.clock()
			repeat task.wait() until os.clock() >= Start + (BindInfo.MaxTime or 0)
			Model:Destroy()
				return
		end)
		
		end
		return BindInfo
		
	end
	
	

end

if not BindService.Running then
	BindService.Running = true
	local function Added(v:ModuleScript)
		if v:IsA("ModuleScript") then
			BindService.Types[v.Name] = require(v)
		end
	end
	for i,v in script:WaitForChild("Types"):GetChildren() do
		Added(v)
	end
	script.Types.ChildAdded:Connect(Added)
end

return BindService
