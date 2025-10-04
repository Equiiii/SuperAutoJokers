G.localization.misc.dictionary.sapjokers_scorpion_saved = "Saved by Scorpion"
init_localization()

SMODS.Atlas {
    key = "jokers",
    path = "Jokers.png",
    px = 71,
    py = 95,
}
--For Sloth
SMODS.Rarity {
    key = "token",
    loc_txt = {
        name = "Token"
    },
    pools = { ["Joker"] = true, },
    default_weight = 0.001,
    badge_colour = HEX("FF6A00"),
    get_weight = function(self, weight, object_type)
        return weight
    end,
}

SMODS.Joker {
    key = "slothjoker",
    atlas = "jokers",
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
--Pool of Sell Jokers
SMODS.ObjectType({
    key = "sell",
    default = "j_sapjokers_beaverjoker",
    cards = {
            "j_sapjokers_duckjoker",
            "j_sapjokers_beaverjoker",
            "j_sapjokers_dogjoker",
            "j_sapjokers_skunkjoker",
            "j_sapjokers_cowjoker",
            "j_sapjokers_tigerjoker",
            "j_diet_cola",
            "j_luchador",
            "j_invisible",
            },
    inject = function(self)

SMODS.ObjectType.inject(self)
    end,
})
SMODS.Joker:take_ownership("diet_cola",{
    pools = {sell = true},
})
SMODS.Joker:take_ownership("luchador",{
    pools = {sell = true},
})
SMODS.Joker:take_ownership("invisible",{
    pools = {sell = true},
})

-- Test Joker
SMODS.Joker {
    key = "joker",
    atlas = "jokers",
    pos = { x = 0, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 2,
    discovered = true,
    config = { extra = { mult = 9 }, },
    loc_txt = {
        name = "Test Joker",
        text = {
            "{C:red,s:1.1}+#1#{} Mult",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

--Duck
SMODS.Joker {
    key = "duckjoker",
    pos = {x = 0, y = 0},
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = { extra = { duck_rounds = 0, total_rounds = 2 }},
    pools = {sell = true},
    loc_txt = {
        name = "Duck",
        text = {
            "After {C:attention}#2#{} rounds,",
            "sell this Joker to",
            "gain a {C:tarot}Death{}",
            "{C:inactive}(Must have room){}",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#)"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.duck_rounds, card.ability.extra.total_rounds }}
    end,

    calculate = function(self, card, context)
        if context.selling_self and (card.ability.extra.duck_rounds >= card.ability.extra.total_rounds) and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) and not context.blueprint then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.0,
                func = (function()
                    local card = create_card("Tarot",G.consumeables, nil, nil, nil, nil, "c_death")
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                return true
                end)}))
        end
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            card.ability.extra.duck_rounds = card.ability.extra.duck_rounds + 1
            if card.ability.extra.duck_rounds >= card.ability.extra.total_rounds then
                local eval = function(card) return not card.REMOVED end
                juice_card_until(card, eval, true)
                return {
                    message = "Active!",
                    colour = G.C.FILTER
                }
            else
                return {
                    message = (card.ability.extra.duck_rounds .. "/" .. card.ability.extra.total_rounds),
                    colour = G.C.FILTER
                }
            end
        end
    end,
}
--Beaver
SMODS.Joker {
    key = "beaverjoker",
    atlas = "jokers",
    pos = {x = 1, y = 0},
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Beaver",
        text = {
            "Sell this {C:attention}Joker{} to",
            "Instantly gain a",
            "{C:tarot}Wheel of Fortune{}",
            "{C:inactive}(Must have room){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.c_wheel_of_fortune
        return { vars = {}}
    end,

    calculate = function(self, card, context)
        if context.selling_self and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.0,
                func = (function()
                    local card = create_card("Tarot",G.consumeables, nil, nil, nil, nil, "c_wheel_of_fortune")
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                return true
                end)}))
            end
        end,
}
--Pigeon
--Otter
SMODS.Joker {
    key = "otterjoker",
    pos = {x = 3, y = 0},
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { dollars = 3 }},
    loc_txt = {
        name = "Otter",
        text = {
            "{C:money}Gold{} cards give {C:money}$3{}",
            "when {C:attention}discarded{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars }}
    end,

    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff and SMODS.has_enhancement(context.other_card, "m_gold") then
            return {
                dollars = card.ability.extra.dollars
            }
        end
    end,
}
--Pig
SMODS.Joker {
    key = "pigjoker",
    pos = {x = 4, y = 0},
    rarity = 1,
    blueprint_compat = true,
    cost = 3,
    discovered = true,
    config = { extra = { sell_cost = 2, odds = 3 }},
    loc_txt = {
        name = "Pig",
        text = {
            "Each scored {C:attention}4{} has a",
            "{C:green}#2# in #3#{} chance",
            "to increase this Joker's",
            "sell value by {C:money}$1{}",
        },
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_cost, (G.GAME.probabilities.normal or 1), card.ability.extra.odds }}
    end,
    

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 4 or next(SMODS.find_card("j_sapjokers_parrotjoker")) ==  true then
                if pseudorandom("pigjoker") < G.GAME.probabilities.normal / card.ability.extra.odds then
                    card.sell_cost = card.sell_cost + 1
                    return {message = "Value Up!"}
                end
            end
        end
    end,
}
--Ant
--Mosquito
--Fish
SMODS.Joker {
    key = "fishjoker",
    atlas = "jokers",
    pos = {x = 7, y = 0},
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { creates = 1, sell_count = 0 }},
    loc_txt = {
        name = "Fish",
        text = {
            "After selling 3 {C:attention}Jokers{},",
            "create a random",
            "{C:tarot}Tarot{} card",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.creates, card.ability.extra.sell_count }}
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card.ability.set == "Joker" and not context.selling_self then
            card.ability.extra.sell_count = card.ability.extra.sell_count + 1
            if card.ability.extra.sell_count == 3 then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.add_card {
                                set = "Tarot",
                            }
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                    card.ability.extra.sell_count = 0
                    return {
                        message = "+1 Tarot",
                        colour = G.C.TAROT
                    }
                end
            else
                return {
                    message = card.ability.extra.sell_count .. "/3",
                    colour = G.C.TAROT
                }
            end
        end
    end,
}
--Cricket
SMODS.Joker {
    key = "cricketjoker",
    pos = {x = 8, y = 0},
    rarity = 1,
    blueprint_compat = true,
    cost = 3,
    discovered = true,
    config = {extra = { draw_cards = 5 }},
    loc_txt = {
        name = "Cricket",
        text = {
            "When {C:attention}Blind{} is selected,",
            "draw {C:attention}5{} extra",
            "cards to hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.draw_cards }}
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn then
            SMODS.draw_cards(card.ability.extra.draw_cards)
        end
    end,
}
--Horse
--Snail
SMODS.Joker {
    key = "snailjoker",
    pos = {x = 0, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { chips = 90 }},
    loc_txt = {
        name = "Snail",
        text = {
            "{C:chips}+#1#{} Chips,",
            "{C:chips}-5{} Chips for each",
            "{C:attention}Shop Reroll{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips }}
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            if card.ability.extra.chips - 5 <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = "Out of Chips",
                    colour = G.C.CHIPS
                }
            else
                card.ability.extra.chips = card.ability.extra.chips - 5
                return {
                    message = "-5",
                    colour = G.C.CHIPS
                }
            end
        end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            } 
        end
    end,
}
--Crab
SMODS.Joker {
    key = "crabjoker",
    pos = {x = 1, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 15 }},
    loc_txt = {
        name = "Crab",
        text = {
            "{C:mult}+#1#{} Mult,",
            "{C:mult}-1{} Mult for each",
            "{C:attention}Shop Reroll{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            if card.ability.extra.mult - 1 <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = "Out of Mult",
                    colour = G.C.MULT
                }
            else
                card.ability.extra.mult = card.ability.extra.mult - 1
                return {
                    message = "-1",
                    colour = G.C.MULT
                }
            end
        end
    end,
}
--Swan
SMODS.Joker {
    key = "swanjoker",
    pos = {x = 2, y = 1},
    rarity = 1,
    blueprint_compat = false,
    cost = 3,
    discovered = true,
    config = { extra = { dollars = 0 }},
    loc_txt = {
        name = "Swan",
        text = {
            "Earn {C:money}$1{} at the",
            "end of round for",
            "each owned {C:attention}Joker{}",
            "{C:inactive}(Currently {}{C:money}$#1#{}{C:inactive})",
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.dollars * (G.Jokers and #G.Jokers.cards or 0) }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.dollars = #G.jokers.cards
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end,
}
--Rat
SMODS.Joker {
    key = "ratjoker",
    pos = {x = 3, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 0, mult_mod = 4 }},
    loc_txt = {
        name = "Rat",
        text = {
            "{C:mult}+4{} Mult when hand",
            "is played, resets at",
            "end of round",
            "{C:inactive}(Currently {C:mult}+#1#{}{C:inactive} Mult){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod }}
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod
            return {
                message = localize {
                    type = "variable",
                    key = "a_mult",
                    vars = {card.ability.extra.mult_mod}
                }
            }
        end
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            card.ability.extra.mult = 0
            return {
                message = localize("k_reset")
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}
--Hedgehog
--Peacock
--Flamingo
SMODS.Joker {
    key = "flamingojoker",
    pos = {x = 6, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 0 }},
    loc_txt = {
        name = "Flamingo",
        text = {
            "This Joker gains {C:mult}+1{} Mult",
            "for each {C:attention}consecutive{} hand played",
            "with at most 2 scoring{C:attention}suits",
            "{C:inactive}(Currently {C:red}+#1#{}{C:inactive} Mult){}",
            
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,
    
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local two_suits = true
            local suits = {
                ["Hearts"] = 0,
                ["Diamonds"] = 0,
                ["Clubs"] = 0,
                ["Spades"] = 0,
            }
            for _, card in ipairs(context.scoring_hand) do
                if not SMODS.has_any_suit(context.scoring_hand[_]) then
                    if context.scoring_hand[_]:is_suit('Hearts', true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif context.scoring_hand[_]:is_suit('Diamonds', true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif context.scoring_hand[_]:is_suit('Spades', true) and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif context.scoring_hand[_]:is_suit('Clubs', true) and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            if suits["Hearts"] + suits["Diamonds"] + suits["Clubs"] + suits["Spades"] > 2 then
                two_suits = false
            end
            if two_suits == true then
                card.ability.extra.mult = card.ability.extra.mult + 1
                return {
                    message = "+1 Mult",
                    colour = G.C.ATTENTION
                }
            else
                card.ability.extra.mult = 0
                return {
                    message = "Reset",
                    colour = G.C.ATTENTION
                }
            end
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}
--Worm
SMODS.Joker {
    key = "wormjoker",
    pos = {x = 7, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { chips = 0 }},
    loc_txt = {
        name = "Worm",
        text = {
            "This Joker gains {C:chips}+10{} Chips",
            "when a hand higher than",
            "{C:attention}Three of a Kind{} is {C:attention}discarded{}",
            "{C:inactive}(Currently{} +{C:chips}#1# {C:inactive}Chips){}",
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.chips }}
    end,

    calculate = function(self, card, context)
        if context.pre_discard and not context.hook then
            local hand, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            if hand ~= "High Card" and hand ~= "Pair" and hand ~= "Two Pair" and hand ~= "Three of a Kind" then
                card.ability.extra.chips = card.ability.extra.chips + 10
                return {
                    message = "Upgraded!",
                }
            end
        end

        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
            }
        end
    end,
}
--Kangaroo
--Spider
SMODS.Joker {
    key = "spiderjoker",
    pos = {x = 9, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = {
        chips = 1,
        mult = 1,
        dollars = 1,
        hand_mod = 1,
        discard_mod = 1,
        repetitions = 1,
        hand_size_mod = 1,
        config_pick = 0,
    }},
    loc_txt = {
        name = "Spider",
        text = {
            "{C:attention}+1{} ...???",
            "{C:inactive}(May require room){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.chips,
            card.ability.extra.mult,
            card.ability.extra.dollars,
            card.ability.extra.hand_mod,
            card.ability.extra.discard_mod,
            card.ability.extra.repetitions,
            card.ability.extra.hand_size_mod,
            card.ability.extra.config_pick
        }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.config_pick = pseudorandom("j_sapjokers_spiderjoker", 0, 9)
            if card.ability.extra.config_pick == 3 and not context.blueprint then
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hand_mod
            elseif card.ability.extra.config_pick == 4 and not context.blueprint then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard_mod
            elseif card.ability.extra.config_pick == 6 and not context.blueprint then
                G.hand:change_size(card.ability.extra.hand_size_mod)
            elseif card.ability.extra.config_pick == 7 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.0,
                    func = (function()
                        local card = create_card("Tarot",G.consumeables, nil, nil, nil, nil, nil)
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                    return true
                    end)}))
            elseif card.ability.extra.config_pick == 8 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.0,
                    func = (function()
                        local card = create_card("Planet",G.consumeables, nil, nil, nil, nil, nil)
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                    return true
                    end)}))
            elseif card.ability.extra.config_pick == 9 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.0,
                    func = (function()
                        local card = create_card("Spectral",G.consumeables, nil, nil, nil, nil, nil)
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                    return true
                    end)}))
            end
        end
        if context.joker_main then
            if card.ability.extra.config_pick == 0 then
                return {
                    chips = card.ability.extra.chips
                }
            elseif card.ability.extra.config_pick == 1 then
                return {
                    mult = card.ability.extra.mult
                }
            elseif card.ability.extra.config_pick == 2 then
                return {
                    dollars = card.ability.extra.dollars
                }
            end
        end
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
            if card.ability.extra.config_pick == 5 then
                return {
                    repetitions = card.ability.extra.repetitions
                }
            end
        end
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            if card.ability.extra.config_pick == 3 then
                G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand_mod
            elseif card.ability.extra.config_pick == 4 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard_mod
            elseif card.ability.extra.config_pick == 6 then
                G.hand:change_size(-card.ability.extra.hand_size_mod)
            end
        end
    end,

}
--Dodo
--Badger
SMODS.Joker {
    key = "badgerjoker",
    pos = {x = 1, y = 2},
    rarity = 2,
    blueprint_compat = false,
    cost = 4,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Badger",
        text = {
            "If played hand contains exactly",
            "{C:attention}2{} cards that share a",
            "{C:attention}rank and suit{},",
            "destroy the first",
        }
    },
    calculate = function(self, card, context)
        if context.after and #context.full_hand == 2 and context.full_hand[1]:get_id() == context.full_hand[2]:get_id() 
        and context.full_hand[1].base.suit == context.full_hand[2].base.suit and not context.blueprint then
            SMODS.destroy_cards(context.full_hand[1])
            return {
                message = "Destroyed!",
            }
        end
    end,
}
--Dolphin
--Giraffe
SMODS.Joker {
    key = "giraffejoker",
    pos = {x = 3, y = 2},
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 0 }},
    loc_txt = {
        name = "Giraffe",
        text = {
            "This Joker gains",
            "{C:mult}+3{} Mult when {C:attention}Blind{} is",
            "selected with an empty",
            "{C:attention}Joker{} slot",
            "{C:inactive}(Currently {C:mult}+#1#{}{C:inactive} Mult){}",
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and #G.jokers.cards < G.jokers.config.card_limit then
            card.ability.extra.mult = card.ability.extra.mult + 3
            return {
                message = "Upgraded!",
            }
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
            }
        end
    end,
}
--Elephant
SMODS.Joker {
    key = "elephantjoker",
    pos = {x = 4, y = 2},
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 1 }},
    loc_txt = {
        name = "Elephant",
        text = {
            "This Joker gains {X:mult,C:white}0.5X{} Mult",
            "when played hand is",
            "{C:attention}Not Allowed",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}",
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = {center.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.debuffed_hand and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + 0.5
            return {
                message = "Upgraded!",
            }
        end

        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}
--Camel
--Rabbit
SMODS.Joker {
    key = "rabbitjoker",
    pos = {x = 6, y = 2},
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { sell_value = 1 }},
    loc_txt = {
        name = "Rabbit",
        text = {
            "When a Joker is {C:attention}bought{},",
            "increase its {C:attention}sell value{}",
            "by {C:money}$1{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_value }}
    end,
    calculate = function(self, card, context)
        if context.buying_card and context.card.ability.set == "Joker" then
            local j_rightmost = G.jokers.cards[#G.jokers.cards]
            if j_rightmost.set_cost then
                j_rightmost.ability.extra_value = (j_rightmost.ability.extra_value or 0) + card.ability.extra.sell_value
                j_rightmost:set_cost()
            end
            return {
                message = "Value Up!",
                colour = G.C.MONEY
            }
        end
    end,
}
--Ox
--Dog
SMODS.Joker {
    key = "dogjoker",
    pos = {x = 8, y = 2},
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 5,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Dog",
        text = {
            "Sell this Joker to",
            "add a random {C:edition}Holographic",
            "card to deck",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_holo
    end,
    calculate = function(self, card, context)
        if context.selling_self then
            local dog_card = SMODS.add_card { set = "Base", edition = "e_holo", area = G.deck}
            return {
                message = "+1 Card",
                colour = G.C.EDITION,
            }
        end
    end
}
--Sheep
--Skunk
SMODS.Joker {
    key = "skunkjoker",
    pos = {x = 0, y = 3},
    rarity = 2,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Skunk",
        text = {
            "Sell this Joker to",
            "reduce boss blind's score",
            "requirement by {C:attention}66%",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self then
            if G.GAME.blind:get_type() == "Boss" then
                G.GAME.blind.chips = G.GAME.blind.chips / 3
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            end
        end
    end,
}
--Hippo
--Bison
SMODS.Joker {
    key = "bisonjoker",
    pos = {x = 2, y = 3},
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { mult = 0 }},
    loc_txt = {
        name = "Bison",
        text = {
            "This Joker gains",
            "{C:mult}+2{} Mult when a",
            "{C:attention}Joker{} is sold",
            "{C:inactive}(Currently{} +{C:mult}#1#{} {C:inactive}Mult)"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.selling_card and context.card.ability.set == "Joker" and not context.blueprint and not context.selling_self then
            card.ability.extra.mult = card.ability.extra.mult + 2
            return {
                message = "Upgraded!"
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
            }
        end
    end,
}
--Blowfish
SMODS.Joker {
    key = "blowfishjoker",
    atlas = "jokers",
    pos = {x = 3, y = 3},
    rarity = 2,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = {extra = { xmult = 3 }},
    loc_txt = {
        name = "Blowfish",
        text = {
            "{X:mult,C:white}X3{} Mult, reduce poker",
            "hands to level {C:attention}1{} when",
            "{C:attention}Blind{} is selected",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            for poker_hand_key, _ in pairs(G.GAME.hands) do
                if G.GAME.hands[poker_hand_key].level > 1 then
                    local level_downs = (G.GAME.hands[poker_hand_key].level - 1) * -1
                    level_up_hand(self, poker_hand_key, true, level_downs)
                end
            end
            return {
                message = "Level Down!",
                mcolour = G.C.RED
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end

}
--Turtle
SMODS.Joker {
    key = "turtlejoker",
    pos = {x = 4, y = 3},
    rarity = 2,
    blueprint_compat = false,
    cost = 4,
    discovered = true,
    config = { extra = { discard_mod = 4, hand_mod = -2 }},
    loc_txt = {
        name = "Turtle",
        text = {
            "{C:red}+4{} discards,",
            "{C:blue}-2{} hands per round",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.discard_mod, card.ability.extra.hand_mod }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard_mod
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hand_mod
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard_mod
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand_mod
    end,
}
--Squirrel
SMODS.Joker {
    key = "squirreljoker",
    pos = {x = 5, y = 3},
    rarity = 2,
    blueprint_compat = false,
    cost = 7,
    discovered = true,
    config = { extra = { dollars = 0}},
    loc_txt = {
        name = "Squirrel",
        text = {
            "Earn {C:money}$2{} at the end",
            "of round for each {C:spectral}Spectral",
            "card used this run",
            "{C:inactive}(Currently {}{C:money}$#1#{}{C:inactive})",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars }}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.dollars = G.GAME.consumeable_usage_total.spectral * 2
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end,
}
--Penguin
--Deer
--Whale
--Parrot
SMODS.Joker {
    key = "parrotjoker",
    pos = {x = 9, y = 3},
    rarity = 2,
    blueprint_compat = false,
    cost = 6,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Parrot",
        text = {
            "All cards are considered",
            "{C:attention}2s{}, {C:attention}4s{}, {C:attention}6s{}, and {C:attention}8s",
            "for applicable {C:attention}Joker{} effects",
            "{C:inactive}(incompatible with other modded jokers){}"
        }
    },
}
--Other garbage parrot related code
SMODS.Joker:take_ownership("sixth_sense", {
    calculate = function(self, card, context)
        if context.destroy_card and not context.blueprint then
            if next(SMODS.find_card("j_sapjokers_parrotjoker")) then
                if #context.full_hand == 1 and context.destroy_card == context.full_hand[1] and G.GAME.current_round.hands_played == 0 then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = (function()
                                    local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'sixth')
                                    card:add_to_deck()
                                    G.consumeables:emplace(card)
                                    G.GAME.consumeable_buffer = 0
                                return true
                            end)}))
                        return {
                            message = localize("k_plus_spectral"),
                            colour = G.C.SECONDARY_SET.Spectral,
                            remove = true
                        }
                    end
            else
                if #context.full_hand == 1 and context.destroy_card == context.full_hand[1] and G.GAME.current_round.hands_played == 0 and context.full_hand[1]:get_id() == 6 then
                    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = (function()
                                    local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'sixth')
                                    card:add_to_deck()
                                    G.consumeables:emplace(card)
                                    G.GAME.consumeable_buffer = 0
                                return true
                            end)}))
                        return {
                            message = localize("k_plus_spectral"),
                            colour = G.C.SECONDARY_SET.Spectral,
                            remove = true
                        }
                    end
                end
            end
        end
    end
end,
true
})

SMODS.Joker:take_ownership("mail",{
    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff then
            if G.GAME.current_round.mail_card.id == 2 or G.GAME.current_round.mail_card.id == 4 or G.GAME.current_round.mail_card.id == 6
            or G.GAME.current_round.mail_card.id == 8 then
                if next(SMODS.find_card("j_sapjokers_parrotjoker")) then
                    ease_dollars(5)
                    return {
                        message = localize('$')..5,
                        colour = G.C.MONEY,
                    }
                end

            elseif context.other_card:get_id() == G.GAME.current_round.mail_card.id then
                ease_dollars(self.ability.extra)
                return {
                    message = localize('$')..self.ability.extra,
                    colour = G.C.MONEY,
                }
            end
        end
    end,
    true
})

--not currently working
SMODS.Joker:take_ownership("8_ball", {
    key = "8_ball",
    config = { extra = { odds = 4 }},
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "sapjokers_8_ball")
        return { vars = { numerator, denominator }}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
                #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    if (next(SMODS.find_card("j_sapjokers_parrotjoker")) or context.other_card:get_id() == 8) --[[and SMODS.pseudorandom_probability(card, 'sapjokers_8_ball', 1, card.ability.extra.odds)]] then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        return {
                            extra = {focus = card, message = localize('k_plus_tarot'), func = function()
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'before',
                                    delay = 0.0,
                                    func = (function()
                                            local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, '8ba')
                                            card:add_to_deck()
                                            G.consumeables:emplace(card)
                                            G.GAME.consumeable_buffer = 0
                                        return true
                                    end)}))
                            end},
                            colour = G.C.SECONDARY_SET.Tarot,
                            card = card
                        }
                    end
                end
    end,
    true
})

SMODS.Joker:take_ownership("wee",{
    config = { extra = { chips = 0, chip_mod = 8}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod }}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and (context.other_card:get_id() == 2 or next(SMODS.find_card("j_sapjokers_parrotjoker"))) and not context.blueprint then
                card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
                        return {
                            extra = {focus = card, message = localize('k_upgrade_ex')},
                            card = card,
                            colour = G.C.CHIPS
                        }
            end
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
    true
})

SMODS.Joker:take_ownership("walkie_talkie", {
config = { extra = { chips = 10, mult = 4}},
loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.chips, card.ability.extra.mult}}
end,
calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and (context.other_card:get_id() == 10 or context.other_card:get_id() == 4 or next(SMODS.find_card("j_sapjokers_parrotjoker"))) then
                    return {
                        chips = card.ability.extra.chips,
                        mult = card.ability.extra.mult,
                        card = card
                    }
            end
        end,
    true
})

SMODS.Joker:take_ownership("fibonacci", {
    config = { extra = { mult = 8}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and (
                context.other_card:get_id() == 2 or 
                context.other_card:get_id() == 3 or 
                context.other_card:get_id() == 5 or 
                context.other_card:get_id() == 8 or 
                context.other_card:get_id() == 14 or next(SMODS.find_card("j_sapjokers_parrotjoker"))) then
                    return {
                        mult = card.ability.extra.mult,
                        card = card
                    }
            end
        end,
        true
})

SMODS.Joker:take_ownership("even_steven", {
    config = { extra = { mult = 4}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,
    calulate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
                (context.other_card:get_id() <= 10 and 
                context.other_card:get_id() >= 0 and
                context.other_card:get_id()%2 == 0 or next(SMODS.find_card("j_sapjokers_parrotjoker")))
                then
                    return {
                        mult = card.ability.extra.mult,
                        card = card
                    }
            end
        end,
        true
})

SMODS.Joker:take_ownership("idol", {
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
                    sendDebugMessage(G.GAME.current_round.idol_card.rank)
                    if G.GAME.current_round.idol_card.rank == "2" or G.GAME.current_round.idol_card.rank == "4"
                    or G.GAME.current_round.idol_card.rank == "6" or G.GAME.current_round.idol_card.rank == "8" then
                        if next(SMODS.find_card("j_sapjokers_parrotjoker")) and context.other_card:is_suit(G.GAME.current_round.idol_card.suit) then
                            return {
                                x_mult = 2,
                                colour = G.C.RED,
                                card = card
                            }
                        end
                    elseif context.other_card:get_id() == G.GAME.current_round.idol_card.id and context.other_card:is_suit(G.GAME.current_round.idol_card.suit) then
                        return {
                            x_mult = 2,
                            colour = G.C.RED,
                            card = card
                        }
                    end
            end
        end,
        true
})

SMODS.Joker:take_ownership("hack", {
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 2 or 
                context.other_card:get_id() == 3 or 
                context.other_card:get_id() == 4 or 
                context.other_card:get_id() == 5 or next(SMODS.find_card("j_sapjokers_parrotjoker")) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = card
                    }
                end
            end
        end,
    true
})


--Scorpion
SMODS.Joker {
    key = "scorpionjoker",
    pos = {x = 0, y = 4},
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 5,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Scorpion",
        text = {
            "Prevents death if only",
            "{C:attention}High Card{} was played",
            "this blind",
            "{C:red,E:2}self destructs{}"
        }
    },

    calculate = function(self, card, context)
        if context.setting_blind then
            card.is_active = true
            return {
                message = "Active!",
            }
        end
        if context.before and not context.blueprint and context.scoring_name ~= "High Card" then
            card.is_active = false
            return {
                message = "Inactive!",
            }
        end
        if not context.blueprint and context.end_of_round and context.game_over and card.is_active == true then
            card:start_dissolve()
            return {
                message = localize("k_saved_ex"),
                saved = true,
                colour = G.C.RED
            }
        end
    end,
}
--Croc
--Rhino
SMODS.Joker {
    key = "rhinojoker",
    pos = {x = 2, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { chips = 0, chips_gain = 3, chips_loss = 0 }},
    loc_txt = {
        name = "Rhino",
        text = {
            "{C:chips}+3{} Chips when any",
            "card is {C:attention}scored,",
            "{C:chips}-3{} Chips for {C:attention}unscored{} cards",
            "{C:inactive}(Currently{} +{C:chips}#1#{} {C:inactive}Chips)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chips_gain, card.ability.extra.chips_loss }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + 3
            return {
                message = localize {
                    type = "variable",
                    key = "a_chips",
                    vars = {card.ability.extra.chips_gain},
                },
            }
        end
        if context.before then
            if #context.full_hand > #context.scoring_hand then
                card.ability.extra.chips_loss = 3 * (#context.full_hand - #context.scoring_hand)
                card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.chips_loss
                return {
                    message = localize {
                        type = "variable",
                        key = "a_chips_minus",
                        vars = {card.ability.extra.chips_loss},
                    }
                }
            end
        end
        
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
}
--Monkey
SMODS.Joker {
    key = "monkeyjoker",
    pos = {x = 3, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { dollars = 6 }},
    loc_txt = {
        name = "Monkey",
        text = {
            "Lucky cards {C:attention}held in{}",
            "{C:attention}hand{} grant {C:money}$6{} at",
            "end of round",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
        return { vars = { card.ability.extra.dollars }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.end_of_round and context.cardarea == G.hand then
            if SMODS.has_enhancement(context.other_card, "m_lucky") then
                if context.other_card.debuff then
                    return {
                        message = localize("k_debuffed"),
                        colour = G.C.RED
                    }
                else
                    return {
                    dollars = card.ability.extra.dollars,
                }
                end
            end
        end
    end,
}
--Armadillo
--Cow
SMODS.Joker {
    key = "cowjoker",
    pos = {x = 5, y = 4},
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 6,
    discovered = true,
    config = { extra = {cow_rounds = 0, total_rounds = 1}},
    pools = {sell = true},
    loc_txt = {
        name = "Cow",
        text = {
            "In {C:attention}1{} round,",
            "Sell this {C:attention}Joker{} to",
            "gain an {C:spectral}Aura",
        }
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = "c_aura", set = "Spectral"}
        return { vars = {} }
    end,

    calculate = function(self, card, context)
        if context.selling_self and (card.ability.extra.cow_rounds >= card.ability.extra.total_rounds) and not context.blueprint then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.0,
                func = (function()
                    local card = create_card("Spectral",G.consumeables, nil, nil, nil, nil, "c_aura")
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                return true
                end)}))
        end
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            card.ability.extra.cow_rounds = card.ability.extra.cow_rounds + 1
            if card.ability.extra.cow_rounds >= card.ability.extra.total_rounds then
                return {
                    message = "Active!",
                }
            end
        end
    end,
}
--Seal
--Rooster
--Shark
SMODS.Joker {
    key = "sharkjoker",
    pos = {x = 8, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 3 }},
    loc_txt = {
        name = "Shark",
        text = {
            "{X:mult,C:white}X3{} Mult if full",
            "deck has{C:attention} <37{} or",
            "{C:attention}>67{} total cards",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if #G.playing_cards < 37 or #G.playing_cards > 67 then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end,
}
--Turkey
--Leopard
--Boar
--Tiger
SMODS.Joker {
    key = "tigerjoker",
    pos = {x = 2, y = 5},
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 8,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Tiger",
        text = {
            "When this is sold,",
            "gain a {C:attention}Rare Tag",
        }
    },
    calculate = function(self, card, context)
        if context.selling_self then
            add_tag(Tag("tag_rare"))
        end
    end,
}
--Wolverine
SMODS.Joker {
    key = "wolverinejoker",
    pos = {x = 3, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { repetitions = 2 }},
    loc_txt = {
        name = "Wolverine",
        text = {
            "If played hand is a",
            "{C:attention}Straight Flush{} without an {C:attention}Ace{},",
            "retrigger scored cards twice",
        }
    },

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.poker_hands["Straight Flush"] then
            local ace_check = true
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:get_id() == 14 then
                    ace_check = false
                    break
                end
            end

            if ace_check == true then
                return {
                    repetitions = card.ability.extra.repetitions
                }
            end
        end
    end,
}
--Gorilla
SMODS.Joker {
    key = "gorillajoker",
    pos = {x = 4, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { chips = 200, consumableslots = 1,}},
    loc_txt = {
        name = "Gorilla",
        text = {
            "{C:chips}+200{} Chips,",
            "-1{C:attention} Consumable {}Slot",
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.chips, center.ability.extra.consumableslots }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - 1
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
}
--Dragon
SMODS.Joker {
    key = "dragonjoker",
    pos = {x = 5, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 8,
    discovered = true,
    config = { extra = { creates = 1, reroll_count = 0}},
    loc_txt = {
        name = "Dragon",
        text = {
            "After {C:attention}2{} Shop Rerolls,",
            "create a random",
            "{C:attention}Sell{} Joker",
            "{C:inactive}(Must have room){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.creates, card.ability.extra.reroll_count}}
    end,
    calculate = function(self, card, context)
        if context.reroll_shop then
            card.ability.extra.reroll_count = card.ability.extra.reroll_count + 1
            if card.ability.extra.reroll_count == 2 then
                if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                    G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.add_card {
                                set = "sell",
                            }
                            G.GAME.joker_buffer = 0
                            return true
                        end
                    }))
                    card.ability.extra.reroll_count = 0
                    return {
                        message = "+1 Joker",
                        colour = G.C.ATTENTION
                    }
                end
                
            else
                return {
                    message = "1/2",
                    colour = G.C.ATTENTION
                }
            end
        end
    end
}
--Mammoth
SMODS.Joker {
    key = "mammothjoker",
    pos = {x = 6, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = {mult = 40, jokerslots = 1,}},
    loc_txt = {
        name = "Mammoth",
        text = {
            "{C:mult}+40{} Mult,",
            "-1{C:attention} Joker {}Slot",
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.mult, center.ability.extra.jokerslots }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - 1
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}
--Cat
SMODS.Joker {
    key = "catjoker",
    atlas = "jokers",
    pos = {x = 7, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { tags = 1,}},
    loc_txt = {
        name = "Cat",
        text = {
            "When {C:attention}Blind{} is",
            "Skipped, create a",
            "{C:attention}Double Tag",
        }
    },

    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.tags }}
    end,

    calculate = function(self, card, context)
        if context.skip_blind then
            add_tag(Tag("tag_double"))
            return {
                tags = card.ability.extra.tags,
                message = "Skipped!",
            }
        end
    end
}
--Snake
SMODS.Joker {
    key = "snakejoker",
    atlas = "jokers",
    pos = {x = 8, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = {extra = { xmult = 2 }},
    loc_txt = {
        name = "Snake",
        text = {
            "If on the {C:attention}third{} hand",
            "of round, played {C:attention}Steel{}",
            "cards give {X:mult,C:white}X#1#{} Mult",
            "when scored",
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.xmult}}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and G.GAME.current_round.hands_played == 2
            and SMODS.has_enhancement(context.other_card, "m_steel") then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}
--Fly
SMODS.Joker {
    key = "flyjoker",
    atlas = "jokers",
    pos = {x = 9, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { repetitions = 1,}},
    loc_txt = {
        name = "Fly",
        text = {
            "Retrigger the first {C:attention}four{}",
            "cards played in scoring",
        }
    },

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card ~= context.scoring_hand[5] then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end,
}
