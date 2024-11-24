
return {
	{
		TypeInputs = {

			{
				Data = _G.Enums.Key.MouseButton3

				--Amount = 2,
			},
			{
				ConditionalType = "Or",
				Data = _G.Enums.Key.L

				--Amount = 2,
			},
		},
		Action = "LockOn",
		Priority = 1
	},
	{
		TypeInputs = {

			{
				Data = _G.Enums.Key.MouseButton2

				--Amount = 2,
			},

		},

		Conditionals = {
			{
				Type = "Loaded",
				Object = "CharacterManager",
				Targets = {
					"CurrentUser"


				}

			},
			{
				Comparison = "And",
				Type = "Check",
				Object = "Player",
				Targets = {
					{
						Type = "Index"
					}

				}
			},

		},
		Action = "CameraMove",
		Priority = 1
	},
}