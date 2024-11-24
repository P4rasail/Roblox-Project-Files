local Config = {
	{
		TypeInputs = {

			{
				Data = _G.Enums.Key.Space,

			},
		},
		Action = "Jump",
		Priority = 1,
		
	},
	{
		TypeInputs = {

			{
				Data = _G.Enums.Key.LeftShift,
			},
			{
				ConditionalType = "Or",
				Data = _G.Enums.Key.RightShift,
			},
		},
		Conditionals = {
			{
				Type = {"Movement", "IsFlying"},
				Target = "CurrentUser",
				Not = true

			},
		},
		Holdable = true,
		Action = "Run",
		Priority = 2,

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


		Action = "FlightMove",
		Priority = 1
	},
	
}

return Config
