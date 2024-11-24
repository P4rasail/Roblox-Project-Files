local Config = {
	{
		TypeInputs = {

			{
				Data = _G.Enums.Key.X,

				Time = .5
			},
		},
		Action = "Dash",
		Priority = 4,
		Holdable = true,
		
	},
	{
		TypeInputs = {
			{
				{
					Data = _G.Enums.Key.W
				},
				{
					ConditionalType = "Or",
					Data =  _G.Enums.Key.A
				},
				{
					ConditionalType = "Or",
					Data =  _G.Enums.Key.S
				},
				{
					ConditionalType = "Or",
					Data =  _G.Enums.Key.D
				},
				{
					ConditionalType = "Or",
					Data =  _G.Enums.Key.Space
				},
				{
					ConditionalType = "Or",
					Data =  _G.Enums.Key.LeftControl
				},
			},
			
		},
		Holdable = true,


		Action = "DashMove",
		Priority = 1
	},
	
}

return Config
