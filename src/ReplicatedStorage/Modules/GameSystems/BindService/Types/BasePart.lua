function GetSize(Part:BasePart)
	local Size = Part.Size
	if Part:IsA("Part") then
		for i,v:SpecialMesh in Part:GetChildren() do
			if v:IsA("SpecialMesh") then
				if v.MeshType == Enum.MeshType.Head then
					Size *= v.Scale
					local Min = math.min(Size.X,Size.Z)
					Size = Vector3.new(Min,Size.Y,Min)
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
	Init = function(BindInfo,Part:BasePart,Target:BasePart,Parent)
		BindInfo.Offset = BindInfo.Offset or CFrame.new()
		local Weld = Instance.new("Weld")
		Parent = Parent or Part.Parent
		local Model = Parent:GetAttribute("BindService")
		Part.Anchored = false
		Part.CanCollide  = false
		Part.CanTouch = false
		Part.Massless = true
		if not Model then
			local CF =Parent:GetAttribute("OriginCF"):ToObjectSpace(Part.CFrame)
			BindInfo.Origins[Part] = CF
			local Pos = (BindInfo.Offset * CF).Position * (GetSize(Target)/Parent:GetAttribute("OriginSize"))
			Weld.C0 =   CFrame.new(Pos)* BindInfo.Offset.Rotation * CF.Rotation 
			Part:SetAttribute("OriginSize",GetSize(Part))
			Part:SetAttribute("OriginCF",Part.CFrame)
			Part.Size = GetSize(Target) * (Part:GetAttribute("OriginSize")/Parent:GetAttribute("OriginSize"))
		else
			Weld.C0 = BindInfo.Offset 
			Part:SetAttribute("OriginSize",GetSize(Part))
			Part:SetAttribute("OriginCF",Part.CFrame)
			Part.Transparency = 1
			Part.Size = GetSize(Target)
		end
		local function Changed()
			if not BindInfo.Origins then return end
			if Model then
				Part.Size = GetSize(Target)
				Weld.C0  = BindInfo.Offset
			else

				local CF = BindInfo.Origins[Part]
				local Pos = (BindInfo.Offset * CF).Position * (GetSize(Target)/Parent:GetAttribute("OriginSize"))
				Weld.C0 = CFrame.new(Pos)* BindInfo.Offset.Rotation * CF.Rotation
				Part.Size = GetSize(Target) * (Part:GetAttribute("OriginSize")/Parent:GetAttribute("OriginSize"))

			end
		end
		task.spawn(function()
			while Part.Parent and BindInfo.Origins do
				task.wait()
				Changed()
			end
		end)
		table.insert(BindInfo.Events,Target:GetPropertyChangedSignal("Size"):Connect(Changed))
		Changed()
		Weld.Part0 = Target
		Weld.Part1 = Part
		Weld.Parent = Part
	end,
}