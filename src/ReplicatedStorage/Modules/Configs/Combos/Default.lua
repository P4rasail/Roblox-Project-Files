return function(HitTab)

local Config = {
	SpecialCombos = {
		{
			Order = {
			{
			Type = "M1",
			Amount = 1
			},
			{
				ConditionalType = "And",
				Type = "M2",
				Amount = 1
			},
					{
						ConditionalType = "And",
						Type = "M1",
						Amount = 1
					},
					{
						ConditionalType = "And",
						Type = "M2",
						Amount = 1
					},

			},
			Action = "Knockback"
		},
		{
			
			AmountNeeded = {
				{
					Entries = {
						{
						Type = "M1",
						Weight = 1
						},
							{
								Type = "M2",
								Weight = 2
							}
					},
						Amount = 10,
					
				},
			},
			Action = "Knockback"
		}
	},
	
	Options = {
		RandomCombo = true
	},
	
	
	
}

return Config
end
