--Looked at JoyousSpring a LOT for this

local start_run_ref = Game.start_run
function Game:start_run(args)
    self.sapjokers_toy_card_area = CardArea(
        0,
        0,
        self.CARD_W * 0.95,
        self.CARD_H * 0.95,
        {
            card_limit = 1,
            type = "joker",
            highlight_limit = 1,
        }
    )
    SuperAutoJokers.toy_card_area = G.sapjokers_toy_card_area

    start_run_ref(self, args)

    SuperAutoJokers.toy_card_area.T.x = G.consumeables.T.x + 2.75
    SuperAutoJokers.toy_card_area.T.y = G.consumeables.T.y + 3

end

--Toys

SMODS.ConsumableType ({
    key = "toy",
    primary_colour = HEX("ff6a00"),
    secondary_colour = HEX("ff6a00"),
    collection_rows = {6, 6},
    shop_rate = 0,
    no_buy_and_use = true,
    loc_txt = {
        name = "Toy",
        collection = "Toys",
    },
})

SMODS.Consumable {
    key = "stick",
    set = "toy",
    pos = {x = 0, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2, mult = 10 } },
    can_use = false,
    loc_txt = {
        name = "Stick",
        text = {
            "{C:mult}+#2# {}Mult when held",
            "{C:red,s:0.8}Destroyed in #1# rounds",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end
    end,
}

SMODS.Consumable {
    key = "balloon",
    set = "toy",
    pos = {x = 1, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2, dollars = 5 } },
    can_use = false,
    loc_txt = {
        name = "Balloon",
        text = {
            "{C:money}+$#2#{} when destroyed",
            "{C:red,s:0.8}Destroyed in #1# rounds",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.dollars }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_destroyed"),
                    dollars = card.ability.extra.dollars
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end
    end,
}

SMODS.Consumable {
    key = "radio",
    set = "toy",
    pos = {x = 2, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2, bonus_chips = 25 } },
    can_use = false,
    loc_txt = {
        name = "Radio",
        text = {
            "When destroyed, +{C:chips}#2#{}",
            "chips to 5 random cards",
            "in the deck",
            "{C:red,s:0.8}Destroyed in #1# rounds",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.bonus_chips }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                pseudoshuffle(G.playing_cards)
                for i = 1, 5 do
                    G.playing_cards[i].ability.perma_bonus = G.playing_cards[i].ability.perma_bonus + card.ability.extra.bonus_chips
                end
                return {
                    message = localize("k_sapjokers_destroyed"),
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end
    end,
}

SMODS.Consumable {
    key = "tennisball",
    set = "toy",
    pos = {x = 0, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2, hand_count = 0 } },
    can_use = false,
    loc_txt = {
        name = "Tennis Ball",
        text = {
            "When held, the last scored",
            "card of every third",
            "hand is destroyed",
            "{C:red,s:0.8}Destroyed in #1# rounds",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.hand_count }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.hand_count = card.ability.extra.hand_count + 1
            if card.ability.extra.hand_count == 3 then
                card.ability.extra.hand_count = 0
                SMODS.destroy_cards(context.scoring_hand[#context.scoring_hand])
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = card.ability.extra.hand_count .. "/3",
                }
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end
    end,
}

SMODS.Consumable {
    key = "plasticsaw",
    set = "toy",
    pos = {x = 4, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2, repetitions = 1, odds = 2 } },
    can_use = false,
    loc_txt = {
        name = "Plastic Saw",
        text = {
            "When held, the first played card",
            "has a {C:green}#3# in #4#{} chance",
            "to retrigger",
            "{C:red,s:0.8}Destroyed in #1# rounds",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.repetitions, (G.GAME.probabilities.normal or 1), card.ability.extra.odds }}
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1]
        and pseudorandom("c_sapjokers_plasticsaw") < G.GAME.probabilities.normal / card.ability.extra.odds then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end
    end,
}


--Jokers

SMODS.Joker {
    key = "ferretjoker",
    pos = { x = 9, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 3,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Ferret",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 1 {C:attention}Toy",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card ({
                        key = pseudorandom_element({"c_sapjokers_balloon", "c_sapjokers_stick"}, "sapjokers_ferretjoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}

SMODS.Joker {
    key = "lemurjoker",
    pos = { x = 9, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 3,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Lemur",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 2 {C:attention}Toy",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card ({
                        key = pseudorandom_element({"c_sapjokers_tennisball"}, "sapjokers_lemurjoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}
