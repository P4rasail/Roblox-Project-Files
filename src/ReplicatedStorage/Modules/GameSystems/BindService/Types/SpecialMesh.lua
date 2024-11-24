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
	Init = function(BindInfo,Part:SpecialMesh,Target:BasePart,Parent:BasePart)
		local Model:Part = Part.Parent


		
			Part:SetAttribute("OriginSize",Part.Scale)
			
		local function Changed()
			Part.Scale = GetSize(Target) * (Part:GetAttribute("OriginSize")/Parent:GetAttribute("OriginSize"))

		end
		table.insert(BindInfo.Events,Target:GetPropertyChangedSignal("Size"):Connect(Changed))

	end,
}