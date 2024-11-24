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
	Init = function(BindInfo,Part:ParticleEmitter,Target:BasePart,Parent)
		Parent = Parent or Part.Parent
		local Origins = {}
		local Types = {
			Width0 = "number",
			Width1 = "number",
			CurveSize0 = "number",
			CurveSize1 = "number",

			Segments = "number",
			
		}
		local Particle = Part
	local 	function SizePart(Prop:string,Size:Vector3)
		if not Origins[Prop] then
			Origins[Prop] = Particle[Prop]
		end
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

			local Size = (GetSize(Target)/Part:FindFirstAncestorWhichIsA("BasePart"):GetAttribute("OriginSize"))
			for i,v in Types do
				
				SizePart(i,Size)
			end
		end
		table.insert(BindInfo.Events,Target:GetPropertyChangedSignal("Size"):Connect(Changed))
		Changed()
	end,
}