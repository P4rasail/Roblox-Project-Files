local Config = {
	{
		TypeInputs = {

			{
				Data = _G.Enums.Key.MouseButton1
			},
		},
		Action = "Hit",
		Priority = 1,
		Args = {
			Type = "M1"
		},
		Holdable = true
		
	},
	{
		TypeInputs = {

			{
				Data = _G.Enums.Key.MouseButton2
			},
		},
		Action = "Hit",
		Priority = 1,
		Args = {
			Type = "M2"
		},
		Holdable = true

	},
	
}

return Config
