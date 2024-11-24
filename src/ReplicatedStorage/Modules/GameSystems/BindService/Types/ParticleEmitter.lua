function GetSize(Part:BasePart)
	local Size = Part.Size
	if Part:IsA("Part") then
		for i,v:SpecialMesh in Part:GetChildren() do
			if v:IsA("SpecialMesh") then
				if v.MeshType == Enum.MeshType.Head then
					Size *= v.Scale / 1.25
				elseif v.MeshType == Enum.MeshType.FileMesh then
					Size *= v.Scale / 100
				else
					Size *= v.Scale
				end
			end
		end
	end
	return Size
end

return {
	Init = function(BindInfo,Part:ParticleEmitter,Target:BasePart,Parent:BasePart)
		Parent = Parent or Part.Parent
		local Origins = {}
		local Types = {
			Size = "NumberSequence",
			Speed = "NumberRange",
			Acceleration = "Vector3",
			Drag = "number",
			VelocityInheritance = "number"


		}
		local Particle = Part
		local Set = false
		local 	function SizePart(Prop:string,Size:Vector3)
			if not Origins[Prop] then
				Origins[Prop] = Particle[Prop]
			end
			--print(Size.Magnitude)
			if Types[Prop] == "NumberSequence" then
				Size = Size.Magnitude
				local NumSeq:{NumberSequenceKeypoint} = Origins[Prop].Keypoints
				local EmptyEq = {}
				for i,v in NumSeq do
					EmptyEq[i] = NumberSequenceKeypoint.new(v.Time,v.Value * Size,v.Envelope * Size)
				end
				Particle[Prop] = NumberSequence.new(EmptyEq)
			elseif Types[Prop] == "NumberRange" then
				Size = Size.Magnitude
				Particle[Prop] = NumberRange.new(Origins[Prop].Min * Size,Origins[Prop].Max * Size)
			elseif Types[Prop] == "Vector3" then
				Particle[Prop] = Origins[Prop] * Size
			elseif Types[Prop] == "number" then
				Size = Size.Magnitude

				Particle[Prop] = Origins[Prop] * Size
			end
		end
		local function Changed()

			local Size = (GetSize(Target)/Parent:GetAttribute("OriginSize"))
			--print(Size)

			for i,v in Types do
				SizePart(i,Size)
			end
		end
		local TimeLife = Part:GetAttribute("EmitDelay") or 0
		TimeLife += Part.Lifetime.Max / Part.TimeScale
		local SetOnce = false
		local function SetTime(Emit)
			Set = true

			if Part.Enabled or BindInfo.Emit then
				TimeLife = Part:GetAttribute("EmitDelay") or 0
				TimeLife += Part.Lifetime.Max / Part.TimeScale
				Parent.Parent:SetAttribute("Delay",math.max(Parent.Parent:GetAttribute("Delay"),TimeLife ))
				SetOnce = true	
			elseif SetOnce then
				Parent.Parent:SetAttribute("Delay",math.max(Parent.Parent:GetAttribute("Delay"),TimeLife ))
			end
		end
		table.insert(BindInfo.Events,Part:GetPropertyChangedSignal("Enabled"):Connect(function()
			SetTime()
		end))

		SetTime()
		table.insert(BindInfo.Events,Target:GetPropertyChangedSignal("Size"):Connect(Changed))
		Changed()
		--print(Target:GetFullName())
		local TimeLife = Part:GetAttribute("EmitDelay") or 0
		TimeLife += Part.Lifetime.Max / Part.TimeScale
		--if not Part.Parent:GetAttribute("OverrideSize") then

		--end
		if BindInfo.Emit then
			task.delay(Part:GetAttribute("EmitDelay"),function()
				Part:Emit(Part:GetAttribute("EmitCount"))
			end)


			if not BindInfo.MaxTime or TimeLife >= BindInfo.MaxTime then
				BindInfo.MaxTime = TimeLife
			end
		end
	end,
}