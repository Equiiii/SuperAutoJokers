--For Sloth
SMODS.Rarity {
    key = "token",
    loc_txt = {
        name = "Token"
    },
    pools = { ["Joker"] = true, },
    default_weight = 0.0001,
    badge_colour = HEX("FF6A00"),
    get_weight = function(self, weight, object_type)
        return weight
    end,
}

SMODS.Joker {
    key = "slothjoker",
    atlas = "turtlejokers",
    pos = {x = 0, y = 6},
    rarity = "sapjokers_token",
    blueprint_compat = true,
    cost = 1,
    discovered = false,
    config = {},
    loc_txt = {
        name = "Sloth",
        text = {
            "{C:attention}Truly believes in you!{}"
        }
    }
}