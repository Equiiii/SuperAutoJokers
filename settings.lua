local config = SuperAutoJokers.config

SuperAutoJokers.config_tab = function()
	return {
		n = G.UIT.ROOT, config = {align = "cm", padding = 0.1, colour = G.C.BLACK}, nodes = {
			{n = G.UIT.R, config = {align = "cm", padding = 0.1, colour = G.C.RED, r = 0.1}, nodes = {
				{n = G.UIT.O, config = {align = "cm", object = DynaText({string = "Enable/Disable Packs Here!", colours = {G.C.UI.TEXT_LIGHT}, scale = 0.5})}}
		}
	},
		create_toggle({
			label = "Turtle Pack",
			ref_table = SuperAutoJokers.config,
			ref_value = "turtle_pack"
		}),
		create_toggle({
			label = "Puppy Pack",
			ref_table = SuperAutoJokers.config,
			ref_value = "puppy_pack"
		}),
		create_toggle({
			label = "Disable Vanilla Jokers",
			ref_table = SuperAutoJokers.config,
			ref_value = "disable_vanilla"
		})
	}}
end