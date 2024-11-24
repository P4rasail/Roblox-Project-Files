local Config = {
	{
		TypeInputs = {
			{
				{
					{
						Data = _G.Enums.Key.N,

						--Amount = 2,
						Time = .5
					},
					{
						ConditionalType = "And",
						Data = _G.Enums.Key.V,

						--Amount = 2,
						Time = .5
					},
				},
				{
					ConditionalType = "And",
					{
						Data = _G.Enums.Key.K,

						--Amount = 2,
						Time = .5
					},
					{
						ConditionalType = "Or",
						Data = _G.Enums.Key.E,

						--Amount = 2,
						Time = .5
					},
				},
			},
			{
				ConditionalType = "Or",
				Data = _G.Enums.Key.Space,

				Amount = 2,
				Time = .5
			},
		},
		Action = "Flight",
		Priority = 2,

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
				Target = "CurrentUser"

			},
		},
		Holdable = true,
		Action = "ShiftFlight",
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
