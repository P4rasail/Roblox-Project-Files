local KeyframeService = game:GetService("KeyframeSequenceProvider")
local RunService = game:GetService("RunService")
local RepService = game:GetService("ReplicatedStorage")

local Indexes = require(RepService:WaitForChild("Indexes"))
local AnimHandler = {
	Anims = {},
	Animators = {}
}
local AnimFuncs = {}
AnimFuncs.__index = AnimFuncs


function GetAnim(AnimIndex,Current)
	if not AnimIndex then return end
	Current = Current or script.Anims
	local Scr = Current
	local Temp = Scr:FindFirstChild(AnimIndex[1])
	if Temp then
		table.remove(AnimIndex,1)
		Scr = Temp
	end
	if #AnimIndex >= 1 then
		return GetAnim(AnimIndex,Scr)
	end
	print(Scr)
	if not Scr:IsA("Animation") then
		return
	end
	return Scr
end
function EditPoses(Keyframe:Keyframe|Pose,Func:(Pose)->(boolean?))
	local Poses
	local ReturnedPoses = {}
	if Keyframe:IsA("Keyframe") then
		Poses = Keyframe:GetPoses()

	else
		Poses = Keyframe:GetSubPoses()

	end

	for i,v:Pose in Poses do

		local Return = Func(v)
		if not Return then
			table.remove(Poses,i)
			continue 

		end
		if #(v:GetSubPoses()) ~= 0 then
			EditPoses(v,Func)
		end
	end
	return Poses

end

function GetPoseData(Char:Model,Keyframe,Tab)

	local Poses
	local ReturnedPoses = Tab or {}
	if Keyframe:IsA("Keyframe") then
		Poses = Keyframe:GetPoses()

	else
		Poses = Keyframe:GetSubPoses()

	end


	for i,v:Pose in Poses do
		local Mod = Char:FindFirstChild(v.Name)
		if Mod then
			--if not ReturnedPoses[Mod] then
			ReturnedPoses[Mod] = {
				CFrame = v.CFrame,
				Weight = v.Weight,

			}
			--end

		end
		if #(v:GetSubPoses()) ~= 0 then
			GetPoseData(Char,v,ReturnedPoses)
		end
	end
	return ReturnedPoses
end

function GetWeightedTotals(Info,Anims,Motors)
	local WeightTable = {}
	local TotalNormals = {}
	--print(Info)
	for e,x in Info do
		WeightTable[e] = {}
		local Time = Anims[e].TimePosition
		--print(Time)
		--print(x)
		local Valid = false
		for i,v in x do
			if Valid then
				break
			end
			if not x[i + 1] or (math.abs(v.Time - Time  ) < math.abs(x[i + 1].Time - Time)) then
				for a,k in v.Poses[1] do
					local Index = 1
					v.Weight = Anims[e].Weight
					table.insert(WeightTable[e],v)
					Valid = true
					break
				end
			end
		end
	end
	for i,v in WeightTable do
		for a,k in v do
			for e,x in k.Poses[1] do
				if not TotalNormals[e] then
					TotalNormals[e] = k.Weight
				else
					TotalNormals[e] += k.Weight
				end
			end
		end
	end
	local TotalTransforms = {}
	for i,v in WeightTable do
		for a,k in v do
			for e,x in k.Poses[1] do
				if not TotalTransforms[e] then
					TotalTransforms[e] = Motors[e].C0:Lerp(x.CFrame,k.Weight/TotalNormals[e])
				else
					TotalTransforms[e] = TotalTransforms[e]:Lerp(x.CFrame,k.Weight/TotalNormals[e])
				end
			end
		end
	end
	return TotalTransforms, TotalNormals,WeightTable
end


function InitializeChar(Char:Model)
	local Anim = AnimHandler.Anims[Char]
	if not Anim then
		AnimHandler.Anims[Char] = {}
		AnimHandler.Anims[Char].Model = Char
		AnimHandler.Anims[Char].Anims = {}

		local CurrentAnims = {}
		local RootTypes = {}

		for i,v in Char:GetDescendants() do
			if v:IsA("Motor6D")then
				RootTypes[v.Part1] = v
				v:SetAttribute("OriginC0",v.C0)
				v:SetAttribute("OriginC1",v.C1)
			end
		end
		local function FrameStepped(Delta:number)
			local CurrentPose = {}
			local TotalNormals,TotalWeights
			for i,v in AnimHandler.Anims[Char].Anims do
				if not CurrentAnims[i] then
					local AnimInfo = {}
					
					for e,x in v.Data do
						local Poses = {}
						for a,k in x.Keyframes do
							table.insert(Poses,GetPoseData(Char,k,{}))
						end
						
						table.insert(AnimInfo,{
							Time = x.Time,
							Poses = Poses,
							Weight = v.Weight
						})
					end

					CurrentAnims[i] = AnimInfo
				end
				
				v.TimePosition += Delta * v.Speed
				if v.TimePosition > v.Length then
					v.TimePosition = v.TimePosition%(v.Length)
				end
				CurrentAnims[i].Weight = v.Weight
			end
			local Transforms,Normals,WeightedTable = GetWeightedTotals( CurrentAnims,AnimHandler.Anims[Char].Anims,RootTypes)
for i,v in Transforms do
	local Root = RootTypes[i]
	if Root then
		--print(v.Position)
		Root.C0 = Root:GetAttribute("OriginC0") * v
	end
end
		end
		if RunService:IsServer() then
			RunService.Stepped:Connect(function(Time,Delta)
				FrameStepped(Delta)
			end)
		elseif RunService:IsClient() then
			RunService.RenderStepped:Connect(function(Delta)
				FrameStepped(Delta)
			end)
		end
		Char.Destroying:Once(function()
			table.clear(AnimHandler.Anims[Char])
			AnimHandler.Anims[Char] = nil
		end)
		setmetatable(AnimHandler.Anims[Char],AnimFuncs)
		return AnimHandler.Anims[Char]
	end
	return Anim
end




function GetInfo(Animator:Model,AnimId:number,AnimOptions,Func:(Pose)->(boolean?))

	local AnimTab = InitializeChar(Animator)
	local AnimInfo = {}

	local Thing = KeyframeService:GetKeyframeSequenceAsync("rbxassetid://"..tostring(AnimId))


	local NewTab = {}
	Func = Func or function()
		--return true
	end
	local CurrentFunc = function(Pose:Pose)
		local ResultFunc = Func(Pose)
		if ResultFunc then
			return ResultFunc
		end
		AnimOptions.PartList = AnimOptions.PartList or {}
		local Result = table.find(AnimOptions.PartList,Pose.Name) 

--print(Result)
		if AnimOptions.PartListType == "Exclude" and Result or AnimOptions.PartListType == "Include" and not Result then
			return false
		end
		return true
	end
	for i,v in Thing:GetKeyframes() do
		table.insert(NewTab,{
			Time = v.Time,
			Keyframes = EditPoses(v,CurrentFunc)})
	end
	print(NewTab)
	local AnimInfo = {
		Data = NewTab,
		Speed = 1,
		Weight = 1,
		Priority = 1,
		TimePosition = 0,
		Id = AnimId
	}
	AnimInfo.Weight = AnimOptions.Weight or AnimInfo.Weight
	AnimInfo.Length = NewTab[#NewTab].Time
	AnimTab.Anims[AnimId] = AnimInfo

	return AnimInfo
end

function AnimHandler:Create(Char:Model,Options)
	if not Char then return end

	return InitializeChar(Char)
end

function AnimFuncs:CreateAnim(AnimId:number,Options,Func)
	local Info = GetInfo(self.Model,AnimId,Options,Func)
	function Info:Play()

	end
end

--[[

function AnimHandler.new(Char:Animator,AnimId:number,AnimOptions,Func:(Pose)->(boolean?))
	if not Char then return end
	
	AnimOptions = AnimOptions or {}
	AnimOptions.PartsList = AnimOptions.PartsList or {}
	AnimOptions.PartListType = AnimOptions.PartListType or "Exclude"
	local AnimObject = {
		Speed = 1,
		Looped = false,
		Priority = 1,
		Weight = 1
	}
	local Info = GetInfo(Char,AnimId,AnimOptions,Func)
	AnimObject.Info = Info
	function AnimObject:Play()
		
	end
	--print(Thing)
	
end
--]]
if not AnimHandler.Running then
	AnimHandler.Running = true
	Indexes:OnLoad(function()
		if RunService:IsClient() then
			_G.Indexes.Modules.Systems.Networker:CreatePort("Anim",function(Animator:Animator,Type:string)

			end)
		end
	end)
end
return AnimHandler
