local char = game.Players.LocalPlayer.Character

script.Parent.TextBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		if tonumber(script.Parent.TextBox.Text) then
			char:SetAttribute("CamSmoothness",tonumber(script.Parent.TextBox.Text))
		end
	end
end)