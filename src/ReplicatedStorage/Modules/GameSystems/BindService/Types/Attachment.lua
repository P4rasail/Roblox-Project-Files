return {
	Init = function(BindInfo,Part:Attachment,Target:BasePart,Parent:BasePart)
		local CF = Part.CFrame
		BindInfo.Origins[Part] = CF
		local Pos = CF.Position * (Target.Size/Part.Parent:GetAttribute("OriginSize"))
		Part:SetAttribute("OriginCF",Part.CFrame)
		Part.CFrame = CFrame.new(Pos) * CF.Rotation


		local function Changed()

			local CF = BindInfo.Origins[Part]
			local Pos = CF.Position * (Target.Size/Parent:GetAttribute("OriginSize"))
			Part.CFrame = CFrame.new(Pos) * CF.Rotation
		end
		table.insert(BindInfo.Events,Target:GetPropertyChangedSignal("Size"):Connect(Changed))
	end,
}