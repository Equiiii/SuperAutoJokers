init_localization()

SMODS.Atlas {
    key = "turtlejokers",
    path = "TurtleJokers.png",
    px = 71,
    py = 95,
}

SMODS.Atlas {
    key = "backs",
    path = "Backs.png",
    px = 71,
    py = 95,
}

SMODS.Back {
    key = "turtledeck",
    atlas = "backs",
    pos = {x = 0, y = 0},
    unlocked = true,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Turtle Deck",
        text = {
            "Start with a {C:attention}Fish{} and",
            "two random non-rare",
            "{C:attention}Sell {}jokers",
        }
    },
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.jokers then
                    SMODS.add_card {
                        key = "j_sapjokers_fishjoker"
                    }
                    for i = 1, 2 do
                        SMODS.add_card ({
                            key = pseudorandom_element(
                                {"j_sapjokers_beaverjoker",
                                 "j_sapjokers_duckjoker",
                                 "j_sapjokers_pigeonjoker",
                                 "j_sapjokers_dogjoker",
                                 "j_sapjokers_skunkjoker",
                                 "j_diet_cola",
                                 "j_luchador"
                                }, "turtledeck"
                            )
                        })
                    end
                    return true
                end
            end,
        }))
    end
}
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

--Pool of Sell Jokers
SMODS.ObjectType({
    key = "sell",
    default = "j_sapjokers_beaverjoker",
    cards = {
            "j_sapjokers_duckjoker",
            "j_sapjokers_beaverjoker",
            "j_sapjokers_pigeonjoker",
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
}, true)
SMODS.Joker:take_ownership("luchador",{
    pools = {sell = true},
}, true)
SMODS.Joker:take_ownership("invisible",{
    pools = {sell = true},
}, true)

--Duck
SMODS.Joker {
    key = "duckjoker",
    atlas = "turtlejokers",
    pos = {x = 0, y = 0},
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 2,
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
            return {
                message = localize("k_sapjokers_plus_death"),
                colour = G.C.TAROT
            }
        end
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            card.ability.extra.duck_rounds = card.ability.extra.duck_rounds + 1
            if card.ability.extra.duck_rounds >= card.ability.extra.total_rounds then
                local eval = function(card) return not card.REMOVED end
                juice_card_until(card, eval, true)
                return {
                    message = localize("k_active_ex"),
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
    atlas = "turtlejokers",
    pos = {x = 1, y = 0},
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 2,
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
                return {
                    message = localize("k_sapjokers_plus_wheel"),
                    colour = G.C.TAROT
                }
            end
        end,
}
--Pigeon
SMODS.Joker {
    key = "pigeonjoker",
    atlas = "turtlejokers",
    pos = {x = 2, y = 0},
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 2,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Pigeon",
        text = {
            "Sell this {C:attention}Joker{} to",
            "Instantly gain a",
            "random {C:planet}Planet{} card",
            "{C:inactive}(Must have room){}",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
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
            return {
                message = localize("k_plus_planet"),
                colour = G.C.PLANET
            }
        end
    end,
}
--Otter
SMODS.Joker {
    key = "otterjoker",
    atlas = "turtlejokers",
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
    atlas = "turtlejokers",
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
                    return {
                        message = localize("k_val_up")
                    }
                end
            end
        end
    end,
}
--Ant
SMODS.Joker {
    key = "antjoker",
    atlas = "turtlejokers",
    pos = {x = 5, y = 0},
    rarity = 1,
    blueprint_compat = false,
    cost = 5,
    discovered = true,
    config = { extra = { consumableslots = 1 }},
    loc_txt = {
        name = "Ant",
        text = {
            "+1 {C:attention}consumable{} slot",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.consumableslots }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.extra.consumableslots
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.extra.consumableslots
    end,
}
--Mosquito
SMODS.Joker {
    key = "mosquitojoker",
    atlas = "turtlejokers",
    pos = {x = 6, y = 0},
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 2 }},
    loc_txt = {
        name = "Mosquito",
        text = {
            "{C:attention}All{} played cards",
            "give {C:mult}+#1# {}Mult",
            "when scored",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}
--Fish
SMODS.Joker {
    key = "fishjoker",
    atlas = "turtlejokers",
    pos = {x = 7, y = 0},
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { sell_count = 0 }},
    loc_txt = {
        name = "Fish",
        text = {
            "After selling 3 {C:attention}Jokers{},",
            "create a random",
            "{C:tarot}Tarot{} card",
            "{C:inactive}(Must have room)",
            "{C:inactive}(Currently #1#/3)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_count }}
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card.ability.set == "Joker" and not context.selling_self then
            if not context.blueprint then
                if card.ability.extra.sell_count == 3 then
                    card.ability.extra.sell_count = 0
                end
                card.ability.extra.sell_count = card.ability.extra.sell_count + 1
            end
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
                    return {
                        message = localize("k_plus_tarot"),
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
    atlas = "turtlejokers",
    pos = {x = 8, y = 0},
    rarity = 1,
    blueprint_compat = true,
    cost = 3,
    discovered = true,
    config = { extra = { draw_cards = 5 }},
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
SMODS.Joker {
    key = "horsejoker",
    atlas = "turtlejokers",
    pos = {x = 9, y = 0},
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { dollars = 0, displayed_dollars = 2 }},
    loc_txt = {
        name = "Horse",
        text = {
            "Skipping a {C:attention}Blind{} gives",
            "{C:money}$2{} for each Blind",
            "{C:attention}skipped{} this run",
            "{C:inactive}(Currently {}{C:money}$#2#{}{C:inactive})",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.displayed_dollars }}
    end,

    calculate = function(self, card, context)
        if context.skip_blind then
            card.ability.extra.dollars = 2 * G.GAME.skips
            card.ability.extra.displayed_dollars = card.ability.extra.dollars + 2
            return {
                dollars = card.ability.extra.dollars
            }
        end
    end,
}
--Snail
SMODS.Joker {
    key = "snailjoker",
    atlas = "turtlejokers",
    pos = {x = 0, y = 1},
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = { extra = { chips = 90, chips_loss = 5 }},
    loc_txt = {
        name = "Snail",
        text = {
            "{C:chips}+#1#{} Chips,",
            "{C:chips}-#2#{} Chips for each",
            "shop {C:attention}reroll{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chips_loss }}
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            if card.ability.extra.chips - card.ability.extra.chips_loss <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_fainted"),
                    colour = G.C.CHIPS
                }
            else
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
--Crab
SMODS.Joker {
    key = "crabjoker",
    atlas = "turtlejokers",
    pos = {x = 1, y = 1},
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 15, mult_loss = 1 }},
    loc_txt = {
        name = "Crab",
        text = {
            "{C:mult}+#1#{} Mult,",
            "{C:mult}-#2#{} Mult for each",
            "shop {C:attention}reroll{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_loss }}
    end,
    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            if card.ability.extra.mult - card.ability.extra.mult_loss <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_fainted"),
                    colour = G.C.MULT
                }
            else
                card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.mult_loss
                return {
                    message = localize {
                        type = "variable",
                        key = "a_mult_minus",
                        vars = {card.ability.extra.chips_loss},
                    }
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
--Swan
SMODS.Joker {
    key = "swanjoker",
    atlas = "turtlejokers",
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
    atlas = "turtlejokers",
    pos = {x = 3, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 0, mult_mod = 4 }},
    loc_txt = {
        name = "Rat",
        text = {
            "{C:mult}+#2#{} Mult when hand",
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
SMODS.Joker {
    key = "hedgehogjoker",
    atlas = "turtlejokers",
    pos = {x = 4, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Hedgehog",
        text = {
            "Add {C:attention}half{} the total chip",
            "value of all unenhanced",
            "{C:attention}scoring{} cards to Mult",
            "{C:inactive}(rounded down){}",
        }
    },

    calculate = function(self, card, context)
        if context.joker_main then
            local hmult = 0
            for _, playing_card in ipairs(context.scoring_hand) do
                if not next(SMODS.get_enhancements(playing_card)) then
                    hmult = hmult + playing_card:get_chip_bonus()
                end
            end
            return {
                mult = math.floor(hmult/2)
            }
        end
    end,
}
--Peacock
SMODS.Joker {
    key = "peacockjoker",
    atlas = "turtlejokers",
    pos = {x = 5, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { chips = 35 }},
    loc_txt = {
        name = "Peacock",
        text = {
            "Played {C:attention}prime number{} cards",
            "give {C:chips}+#1#{} Chips",
            "when scored",
            "{C:inactive}(2, 3, 5, 7, J){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if (context.other_card:get_id() == 2 or
                context.other_card:get_id() == 3 or
                context.other_card:get_id() == 5 or
                context.other_card:get_id() == 7 or
                context.other_card:get_id() == 11 or next(SMODS.find_card("j_sapjokers_parrotjoker"))) then
                    return {
                        chips = card.ability.extra.chips
                    }
                end
            end
        end,
}
--Flamingo
SMODS.Joker {
    key = "flamingojoker",
    atlas = "turtlejokers",
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
            "with at most 2 scoring{C:attention} suits",
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
                    message = localize("k_upgrade_ex"),
                    colour = G.C.ATTENTION
                }
            else
                card.ability.extra.mult = 0
                return {
                    message = localize("k_reset"),
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
    atlas = "turtlejokers",
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
        if context.pre_discard and not context.blueprint and not context.hook then
            local hand, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            if hand ~= "High Card" and hand ~= "Pair" and hand ~= "Two Pair" and hand ~= "Three of a Kind" then
                card.ability.extra.chips = card.ability.extra.chips + 10
                return {
                    message = localize("k_upgrade_ex")
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
SMODS.Joker {
    key = "kangaroojoker",
    atlas = "turtlejokers",
    pos = {x = 8, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Kangaroo",
        text = {
            "Add the chip value of",
            "all cards {C:attention}held in",
            "{C:attention}hand{} to chips",
        }
    },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            for i = 1, #G.hand.cards do
                if context.other_card.debuff then
                    return {
                        message = localize("k_debuffed"),
                        colour = G.C.RED
                    }
                else
                    local chip_amount = context.other_card:get_chip_bonus()
                    return {
                        chips = chip_amount
                    }
                end
            end
        end
    end,
}
--Spider
SMODS.Joker {
    key = "spiderjoker",
    atlas = "turtlejokers",
    pos = {x = 9, y = 1},
    rarity = 1,
    blueprint_compat = true,
    cost = 3,
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
                ease_hands_played(card.ability.extra.hand_mod)
            elseif card.ability.extra.config_pick == 4 and not context.blueprint then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.discard_mod
                ease_discard(card.ability.extra.discard_mod)
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
                return {
                    message = localize("k_plus_tarot")
                }
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
                return {
                    message = localize("k_plus_planet")
                }
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
                return {
                    message = localize("k_plus_spectral")
                }
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

    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.config_pick == 3 then
                G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand_mod
                ease_hands_played(-card.ability.extra.hand_mod)
        elseif card.ability.extra.config_pick == 4 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discard_mod
                ease_discard(-card.ability.extra.discard_mod)
        elseif card.ability.extra.config_pick == 6 then
                G.hand:change_size(-card.ability.extra.hand_size_mod)
        end
    end
}
--Dodo
SMODS.Joker {
    key = "dodojoker",
    atlas = "turtlejokers",
    pos = {x = 0, y = 2},
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 1, xmult_gain = 0.1 }},
    loc_txt = {
        name = "Dodo",
        text = {
            "When Blind is selected,",
            "this Joker gains {X:mult,C:white}X#2#{} Mult",
            "for each held {C:attention}Sell Joker{}",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local selljoker_flag = false
            for i = 1, #G.jokers.cards do
                if (G.jokers.cards[i].config.center.pools or {})["sell"] then
                    selljoker_flag = true
                    card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
                end
            end
            if selljoker_flag == true then
                return {
                    message = localize("k_upgrade_ex")
                }
            end
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}
--Badger
SMODS.Joker {
    key = "badgerjoker",
    atlas = "turtlejokers",
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
        and context.full_hand[1].suit == context.full_hand[2].suit and not context.blueprint then
            SMODS.destroy_cards(context.full_hand[1])
            return {
                message = localize("k_sapjokers_destroyed")
            }
        end
    end,
}
--Dolphin
SMODS.Joker {
    key = "dolphinjoker",
    atlas = "turtlejokers",
    pos = {x = 2, y = 2},
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { scored_mult = 5, final_mult = -15 }},
    loc_txt = {
        name = "Dolphin",
        text = {
            "{C:mult}#2#{} Mult, but played",
            "cards give {C:mult}+#1#{} Mult",
            "when scored",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.scored_mult, card.ability.extra.final_mult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.final_mult
            }
        end
        if context.individual and context.cardarea == G.play then
            return {
                mult = card.ability.extra.scored_mult
            }
        end
    end,
}
--Giraffe
SMODS.Joker {
    key = "giraffejoker",
    atlas = "turtlejokers",
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
            "{C:attention}joker{} slot",
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
                message = localize("k_upgrade_ex")
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
    atlas = "turtlejokers",
    pos = {x = 4, y = 2},
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 1 }},
    loc_txt = {
        name = "Elephant",
        text = {
            "This Joker gains {X:mult,C:white}X0.5{} Mult",
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
                message = localize("k_upgrade_ex")
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
SMODS.Joker {
    key = "cameljoker",
    atlas = "turtlejokers",
    pos = {x = 5, y = 2},
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { repetitions = 1 }},
    loc_txt = {
        name = "Camel",
        text = {
            "Retrigger each scored card",
            "once for each played",
            "{C:attention}unscored{} card",
            "after the first",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions }}
    end,

    calculate = function(self, card, context)
        if context.before then
            card.ability.extra.repetitions = (#context.full_hand - #context.scoring_hand - 1)
        end
        if context.repetition and context.cardarea == G.play then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end,
}
--Rabbit
SMODS.Joker {
    key = "rabbitjoker",
    atlas = "turtlejokers",
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
                message = localize("k_val_up"),
                colour = G.C.MONEY
            }
        end
    end,
}
--Ox
SMODS.Joker {
    key = "oxjoker",
    atlas = "turtlejokers",
    pos = {x = 7, y = 2},
    rarity = 2,
    blueprint_compat = false,
    cost = 3,
    discovered = true,
    config = { extra = { bankrupt_at = 10 }},
    loc_txt = {
        name = "Ox",
        text = {
            "Go up to {C:red}-$#1#{}",
            "in debt, set money to",
            "{C:attention}zero{} when blind is",
            "selected",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.bankrupt_at }}
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.bankrupt_at
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.bankrupt_at
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            G.GAME.dollars = 0
            return {
                message = localize("k_sapjokers_set_to_zero"),
                colour = G.C.MONEY
            }
        end
    end,
}
--Dog
SMODS.Joker {
    key = "dogjoker",
    atlas = "turtlejokers",
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
                message = localize("k_sapjokers_plus_card"),
                colour = G.C.EDITION,
            }
        end
    end
}
--Sheep
SMODS.Joker {
    key = "sheepjoker",
    atlas = "turtlejokers",
    pos = {x = 9, y = 2},
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { tags = 1 }},
    loc_txt = {
        name = "Sheep",
        text = {
            "Skipping a {C:attention}Blind{} gives",
            "a {C:tarot}Charm Tag{} and a",
            "random {C:tarot}Tarot{} card",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.tags }}
    end,

    calculate = function(self, card, context)
        if context.skip_blind then
            add_tag(Tag("tag_charm"))
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
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
                return {
                    message = localize("k_plus_tarot"),
                    colour = G.C.TAROT
                }
            end
        end
    end,
}
--Skunk
SMODS.Joker {
    key = "skunkjoker",
    atlas = "turtlejokers",
    pos = {x = 0, y = 3},
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
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
                return {
                    message = localize("k_sapjokers_score_reduced")
                }
            end
        end
    end,
}
--Hippo
SMODS.Joker {
    key = "hippojoker",
    atlas = "turtlejokers",
    pos = {x = 1, y = 3},
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { tags = 1 }},
    loc_txt = {
        name = "Hippo",
        text = {
            "When {C:attention}Blind{} is selected,",
            "{X:attention,C:white}X1.5{} Blind Requirements and",
            "gain a random {C:attention}Tag{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.tags }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            G.GAME.blind.chips = G.GAME.blind.chips * 1.5
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            local tag_pool = get_current_pool('Tag')
            local selected_tag = pseudorandom_element(tag_pool, 'sapjokers_seed')
            local i = 1
            while selected_tag == 'UNAVAILABLE' do
                i = i + 1
                selected_tag = pseudorandom_element(tag_pool, 'sapjokers_seed'..i)
            end
            add_tag(Tag(selected_tag, false, 'Small'))
            return {
                tags = card.ability.extra.tags,
                message = localize("k_sapjokers_plus_tag")
            }
        end
    end,
}
--Bison
SMODS.Joker {
    key = "bisonjoker",
    atlas = "turtlejokers",
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
                message = localize("k_upgrade_ex")
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
    atlas = "turtlejokers",
    pos = {x = 3, y = 3},
    rarity = 2,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = {extra = { xmult = 3 }},
    loc_txt = {
        name = "Blowfish",
        text = {
            "{X:mult,C:white}X#1#{} Mult, reduce poker",
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
                message = localize("k_sapjokers_level_down"),
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
    atlas = "turtlejokers",
    pos = {x = 4, y = 3},
    rarity = 2,
    blueprint_compat = false,
    cost = 4,
    discovered = true,
    config = { extra = { discard_mod = 4, hand_mod = -2 }},
    loc_txt = {
        name = "Turtle",
        text = {
            "{C:red}+#1#{} discards,",
            "{C:blue}#2#{} hands per round",
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
    atlas = "turtlejokers",
    pos = {x = 5, y = 3},
    rarity = 2,
    blueprint_compat = false,
    cost = 7,
    discovered = true,
    config = { extra = { dollars = 2 }},
    loc_txt = {
        name = "Squirrel",
        text = {
            "Earn {C:money}$#1#{} at the end",
            "of round for each {C:spectral}Spectral",
            "card used this run",
            "{C:inactive}(Currently {}{C:money}$#2#{}{C:inactive})",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.dollars * ( G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.spectral or 0 ) }}
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == "Spectral" then
            return {
                message = localize("k_upgrade_ex"),
                colour = G.C.MONEY
            }
        end
    end,
--Penguin
SMODS.Joker {
    key = "penguinjoker",
    atlas = "turtlejokers",
    pos = {x = 6, y = 3},
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { chips = 25 }},
    loc_txt = {
        name = "Penguin",
        text = {
            "This joker has {C:chips}+#1#{} Chips",
            "for each {C:attention}Straight Flush{}",
            "played this game",
            "{C:inactive}(Currently {}{C:chips}+#2# {C:inactive}Chips)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chips * ( G.GAME.hands["Straight Flush"].played or 0 ) }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips * (G.GAME.hands["Straight Flush"].played)
            }
        end
    end,
}
--Deer
SMODS.Joker {
    key = "deerjoker",
    atlas = "turtlejokers",
    pos = {x = 7, y = 3},
    rarity = 2,
    blueprint_compat = false,
    cost = 5,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Deer",
        text = {
            "If played hand has",
            "only {C:attention}1{} card, turn it",
            "into your most common {C:suits}suit",
        }
    },

    calculate = function(self, card, context)
        if context.before and not context.blueprint and #context.full_hand == 1 then
            local hearts_count = 0
            local spades_count = 0
            local clubs_count = 0
            local diamonds_count = 0
            for _, playing_card in pairs(G.playing_cards) do
                if playing_card.base.suit == "Hearts" then
                    hearts_count = hearts_count + 1
                elseif playing_card.base.suit == "Spades" then
                    spades_count = spades_count + 1
                elseif playing_card.base.suit == "Clubs" then
                    clubs_count = clubs_count + 1
                else
                    diamonds_count = diamonds_count + 1
                end
            end
            local suit_counts = {hearts_count, spades_count, clubs_count, diamonds_count}
            local suits = {"Hearts", "Spades", "Clubs", "Diamonds"}
            local highest = suit_counts[1]
            local most_common_suit = suits[1]
            for i = 2, 4 do
                if suit_counts[i] > highest then
                    most_common_suit = suits[i]
                end
            end
            assert(SMODS.change_base(context.full_hand[1], most_common_suit))
            return {
                extra = {
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                play_sound("generic1", 0.9 + math.random() * 0.1, 0.8)
                                return true
                            end
                        }))
                    end
                }
            }
        end
    end,
}
--Whale
SMODS.Joker {
    key = "whalejoker",
    atlas = "turtlejokers",
    pos = {x = 8, y = 3},
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Whale",
        text = {
            "When Blind is selected,",
            "create a random",
            "{C:attention}Sell{} joker",
            "{C:inactive}(Must have room){}",
        }
    },

    calculate = function(self, card, context)
        if context.setting_blind then
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
                    return {
                        message = localize("k_plus_joker"),
                        colour = G.C.ATTENTION
                    }
            end
        end
    end,
}

--Parrot
SMODS.Joker {
    key = "parrotjoker",
    atlas = "turtlejokers",
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
end
}, true)

SMODS.Joker:take_ownership("mail", {
    name = "Mail-In Rebate",
                text = {
                    "Earn {C:money}$#1#{} for each",
                    "discarded {C:attention}#2#{}, rank",
                    "changes every round",
                },
    config = { extra = { dollars = 5 }},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, localize((G.GAME.current_round.sapjokers_mail_card or {}).rank or "Ace", "ranks")}}
    end,
    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff then
            if G.GAME.current_round.sapjokers_mail_card.id == 2 or G.GAME.current_round.sapjokers_mail_card.id == 4 or G.GAME.current_round.sapjokers_mail_card.id == 6
            or G.GAME.current_round.sapjokers_mail_card.id == 8 then
                if next(SMODS.find_card("j_sapjokers_parrotjoker")) then
                    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                    return {
                        dollars = card.ability.extra.dollars,
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.GAME.dollar_buffer = 0
                                    return true
                                end
                            }))
                        end
                    }
                else
                    if context.other_card:get_id() == G.GAME.current_round.sapjokers_mail_card.id then
                        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                        return {
                            dollars = card.ability.extra.dollars,
                            func = function()
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        G.GAME.dollar_buffer = 0
                                        return true
                                    end
                                }))
                            end
                        }
                    end
                end

            elseif context.other_card:get_id() == G.GAME.current_round.sapjokers_mail_card.id then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
                return {
                    dollars = card.ability.extra.dollars,
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                G.GAME.dollar_buffer = 0
                                return true
                            end
                        }))
                    end
                }
            end
        end
    return nil, true
    end
}, true)

local function reset_sapjokers_mail_rank()
    G.GAME.current_round.sapjokers_mail_card = { rank = 'Ace' }
    local valid_mail_cards = {}
    for _, playing_card in ipairs(G.playing_cards) do
        if not SMODS.has_no_rank(playing_card) then
            valid_mail_cards[#valid_mail_cards + 1] = playing_card
        end
    end
    local mail_card = pseudorandom_element(valid_mail_cards, 'sapjokers_mail' .. G.GAME.round_resets.ante)
    if mail_card then
        G.GAME.current_round.sapjokers_mail_card.rank = mail_card.base.value
        G.GAME.current_round.sapjokers_mail_card.id = mail_card.base.id
    end
end

SMODS.Joker:take_ownership("8_ball", {
    key = "8_ball",
    config = { extra = { odds = 4 }},
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'sapjokers_8ball')
        return { vars = { numerator, denominator }}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
        #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            if (next(SMODS.find_card("j_sapjokers_parrotjoker")) or context.other_card:get_id() == 8) and SMODS.pseudorandom_probability(card, 'sapjokers_8ball', 1, card.ability.extra.odds) then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                return {
                    extra = {
                        message = localize('k_plus_tarot'),
                        message_card = card,
                        func = function()
                            G.E_MANAGER:add_event(Event({
                                func = (function()
                                    SMODS.add_card {
                                        set = "Tarot",
                                        key_append = "sapjokers_8_ball"
                                    }
                                    G.GAME.consumeable_buffer = 0
                                    return true
                                end
                            )}))
                        end
                    },
                }
            end
        end

        return nil, true
    end
}, true)

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
    end
}, true)

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
        end
}, true)

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
        end
}, true)

SMODS.Joker:take_ownership("even_steven", {
    config = { extra = { mult = 4}},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
                ((context.other_card:get_id() <= 10 and 
                context.other_card:get_id() >= 0 and
                context.other_card:get_id()%2 == 0) or next(SMODS.find_card("j_sapjokers_parrotjoker"))) then
                    return {
                        mult = card.ability.extra.mult,
                        card = card
                    }
            end
        end
}, true)

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
        end
}, true)

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
        end
}, true)


--Scorpion
SMODS.Joker {
    key = "scorpionjoker",
    atlas = "turtlejokers",
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
                message = localize("k_active_ex")
            }
        end
        if context.before and not context.blueprint and context.scoring_name ~= "High Card" then
            card.is_active = false
            return {
                message = localize("k_sapjokers_inactive")
            }
        end
        if not context.blueprint and context.end_of_round and context.game_over and card.is_active == true then
            play_sound("tarot1")
            card:start_dissolve()
            return {
                message = localize("k_saved_ex"),
                saved = "k_sapjokers_scorpion_saved",
                colour = G.C.RED
            }
        end
    end,
}
--Croc
SMODS.Joker {
    key = "crocjoker",
    atlas = "turtlejokers",
    pos = {x = 1, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 2.5 }},
    loc_txt = {
        name = "Crocodile",
        text = {
            "{X:mult,C:white}X#1#{} Mult if hand",
            "is played with an",
            "empty {C:attention}joker{} slot"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main and #G.jokers.cards < G.jokers.config.card_limit then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}
--Rhino
SMODS.Joker {
    key = "rhinojoker",
    atlas = "turtlejokers",
    pos = {x = 2, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { chips = 0, chips_gain = 3, chips_loss = 0 }},
    loc_txt = {
        name = "Rhino",
        text = {
            "{C:chips}+#2#{} Chips when any",
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
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_gain
            return {
                message = localize {
                    type = "variable",
                    key = "a_chips",
                    vars = {card.ability.extra.chips_gain},
                },
            }
        end
        if context.before and not context.blueprint then
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
    atlas = "turtlejokers",
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
            "{C:attention}hand{} grant {C:money}$#1#{} at",
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
SMODS.Joker {
    key = "armadillojoker",
    atlas = "turtlejokers",
    pos = {x = 4, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { mult = 0, mult_change = 3 }},
    loc_txt = {
        name = "Armadillo",
        text = {
            "Before hand is played,",
            "add or subtract {C:mult}#2#{}",
            "Mult, then flip between",
            "{C:attention}positive {}and {C:attention}negative{} Mult",
            "{C:inactive}(Currently{} {C:mult}#1#{} {C:inactive}Mult)"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_change }}
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if card.ability.extra.mult >= 0 then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_change
            else
                card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.mult_change
            end
            card.ability.extra.mult = card.ability.extra.mult * -1
            return {
                message = localize("k_sapjokers_flipped"),
                colour = G.C.MULT
            }
        end

        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}
--Cow
SMODS.Joker {
    key = "cowjoker",
    atlas = "turtlejokers",
    pos = {x = 5, y = 4},
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 6,
    discovered = true,
    config = { extra = { cow_rounds = 0, total_rounds = 1 }},
    pools = {sell = true},
    loc_txt = {
        name = "Cow",
        text = {
            "In {C:attention}1{} round,",
            "Sell this {C:attention}Joker{} to",
            "gain a random",
            "{C:spectral}Spectral{} card",
            "{C:inactive}(Must have room){}",
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cow_rounds, card.ability.extra.total_rounds }}
    end,

    calculate = function(self, card, context)
        if context.selling_self and (card.ability.extra.cow_rounds >= card.ability.extra.total_rounds) and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) and not context.blueprint then
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
            return {
                message = localize("k_plus_spectral"),
                colour = G.C.SPECTRAL
            }
        end
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            card.ability.extra.cow_rounds = card.ability.extra.cow_rounds + 1
            if card.ability.extra.cow_rounds >= card.ability.extra.total_rounds then
                local eval = function(card) return not card.REMOVED end
                juice_card_until(card, eval, true)
                return {
                    message = localize("k_active_ex")
                }
            end
        end
    end,
}
--Seal
SMODS.Joker {
    key = "sealjoker",
    atlas = "turtlejokers",
    pos = {x = 6, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { sell_cost = 2 }},
    loc_txt = {
        name = "Seal",
        text = {
            "When a {C:attention}Sell{} Joker is",
            "sold, add its sell value",
            "to this card's sell value",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_cost }}
    end,

    calculate = function(self, card, context)
        if context.selling_card and (context.card.config.center.pools or {})["sell"] then
            card.ability.extra_value = card.ability.extra_value + context.card.sell_cost
            card:set_cost()
            return {
                message = localize("k_val_up"),
                colour = G.C.MONEY
            }
        end
    end,
}
--Rooster
SMODS.Joker {
    key = "roosterjoker",
    atlas = "turtlejokers",
    pos = {x = 7, y = 4},
    rarity = 3,
    blueprint_compat = false,
    cost = 5,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Rooster",
        text = {
            "When Blind is selected,",
            "destroy a random {C:attention}consumable{}",
            "and create a {C:tarot}Fool{}",
            "in its place",
        }
    },

    calculate = function(self, card, context)
        if context.setting_blind and #G.consumeables.cards > 0 and not context.blueprint then
            local consumable = pseudorandom_element(G.consumeables.cards, "roosterjoker")
            SMODS.destroy_cards(consumable)
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                SMODS.add_card{
                    key = "c_fool"
                }
            end
            G.GAME.consumeable_buffer = 0
            return {
                message = localize("k_sapjokers_plus_fool")
            }
        end
    end,
}
--Shark
SMODS.Joker {
    key = "sharkjoker",
    atlas = "turtlejokers",
    pos = {x = 8, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 3 }},
    loc_txt = {
        name = "Shark",
        text = {
            "{X:mult,C:white}X#1#{} Mult if full",
            "deck has{C:attention} < 42{} or",
            "{C:attention}> 67{} total cards",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if #G.playing_cards < 42 or #G.playing_cards > 67 then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end,
}
--Turkey
SMODS.Joker {
    key = "turkeyjoker",
    atlas = "turtlejokers",
    pos = {x = 9, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { sell_count = 0 }},
    loc_txt = {
        name = "Turkey",
        text = {
            "After selling 4 {C:attention}Jokers{},",
            "Upgrade your most played",
            "{C:attention}poker hand{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_count }}
    end,

    calculate = function(self, card, context)
        if context.selling_card and context.card.ability.set == "Joker" and not context.selling_self then
            if not context.blueprint then
                if card.ability.extra.sell_count == 4 then
                    card.ability.extra.sell_count = 0
                end
                card.ability.extra.sell_count = card.ability.extra.sell_count + 1
            end
            if card.ability.extra.sell_count == 4 then
                local _hand, _played = "High Card", -1
                for hand_key, hand in pairs(G.GAME.hands) do
                    if hand.played > _played then
                        _played = hand.played
                        _hand = hand_key
                    end
                end
                local most_played = _hand
                return {
                    level_up = true,
                    level_up_hand = most_played
                }
            end
                return {
                    message = card.ability.extra.sell_count .. "/4",
                    colour = G.C.PLANET
                }
            end
    end,
}
--Leopard
SMODS.Joker {
    key = "leopardjoker",
    atlas = "turtlejokers",
    pos = {x = 0, y = 5},
    rarity = 3,
    blueprint_compat = false,
    cost = 7,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Leopard",
        text = {
            "If first played hand is a single",
            "{C:attention}#1#{} of {V:1}#2#{},",
            "give it a random {C:attention}Seal",
            "and {C:attention}Edition",
            "{s:0.8}Card changes every round",
        }
    },
    loc_vars = function(self, info_queue, card)
        local leopard_card = G.GAME.current_round.sapjokers_leopard_card or { rank = "Ace", suit = "Spades" }
        return { vars = { localize(leopard_card.rank, "ranks"), localize(leopard_card.suit, "suits_plural"), colours = { G.C.SUITS[leopard_card.suit]}}}
    end,
    
    calculate = function(self, card, context)
        if context.before and not context.blueprint and G.GAME.current_round.hands_played == 0 and #context.full_hand == 1 and 
        context.full_hand[1]:get_id() == G.GAME.current_round.sapjokers_leopard_card.id and 
        context.full_hand[1]:is_suit(G.GAME.current_round.sapjokers_leopard_card.suit) then
            context.full_hand[1]:set_seal(SMODS.poll_seal({ guaranteed = true }))
            local edition = poll_edition("test", 1, true, true, {"e_foil", "e_holo", "e_polychrome"})
            context.full_hand[1]:set_edition(edition, true, true)
        end
    end,
}

local function reset_sapjokers_leopard_rank()
    G.GAME.current_round.sapjokers_leopard_card = { rank = 'Ace', suit = "Spades" }
    local valid_leopard_cards = {}
    for _, playing_card in ipairs(G.playing_cards) do
        if not SMODS.has_no_rank(playing_card) and not SMODS.has_no_suit(playing_card) then
            valid_leopard_cards[#valid_leopard_cards + 1] = playing_card
        end
    end
    local leopard_card = pseudorandom_element(valid_leopard_cards, 'sapjokers_leopardjoker' .. G.GAME.round_resets.ante)
    if leopard_card then
        G.GAME.current_round.sapjokers_leopard_card.rank = leopard_card.base.value
        G.GAME.current_round.sapjokers_leopard_card.suit = leopard_card.base.suit
        G.GAME.current_round.sapjokers_leopard_card.id = leopard_card.base.id
    end
end
--Boar
SMODS.Joker {
    key = "boarjoker",
    atlas = "turtlejokers",
    pos = {x = 1, y = 5},
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 4 }},
    loc_txt = {
        name = "Boar",
        text = {
            "If first played hand",
            "contains {C:attention}5{} cards, all",
            "cards {C:attention}held in hand{}",
            "gain {C:mult}+#1#{} Mult permanently",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.before and #context.full_hand == 5 and G.GAME.current_round.hands_played == 0 then
            for i = 1, #G.hand.cards do
                G.hand.cards[i].ability.perma_mult = (G.hand.cards[i].ability.perma_mult or 0) + card.ability.extra.mult
            end
            return {
                message = localize("k_upgrade_ex")
            }
        end
    end,
}
--Tiger
SMODS.Joker {
    key = "tigerjoker",
    atlas = "turtlejokers",
    pos = {x = 2, y = 5},
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 8,
    discovered = true,
    config = { extra = { tags = 1 }},
    pools = {sell = true},
    loc_txt = {
        name = "Tiger",
        text = {
            "When this is sold,",
            "gain a {C:attention}Rare Tag",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.tags }}
    end,

    calculate = function(self, card, context)
        if context.selling_self then
            add_tag(Tag("tag_rare"))
            return {
                message = localize("k_sapjokers_plus_tag")
            }
        end
    end,
}
--Wolverine
SMODS.Joker {
    key = "wolverinejoker",
    atlas = "turtlejokers",
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
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions, localize("Straight Flush", "poker_hands") }}
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and next(context.poker_hands["Straight Flush"]) then
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
    atlas = "turtlejokers",
    pos = {x = 4, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { chips = 200, consumableslots = 1 }},
    loc_txt = {
        name = "Gorilla",
        text = {
            "{C:chips}+#1#{} Chips,",
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
    atlas = "turtlejokers",
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
            "{C:inactive}(Currently #2#/2)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.creates, card.ability.extra.reroll_count}}
    end,
    calculate = function(self, card, context)
        if context.reroll_shop then
            if not context.blueprint then
                if card.ability.extra.reroll_count == 2 then
                    card.ability.extra.reroll_count = 0
                end
                card.ability.extra.reroll_count = card.ability.extra.reroll_count + 1
            end
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
                    return {
                        message = localize("k_plus_joker"),
                        colour = G.C.ATTENTION
                    }
                end
                
            else
                return {
                    message = card.ability.extra.reroll_count .. "/2",
                    colour = G.C.ATTENTION
                }
            end
        end
    end
}
--Mammoth
SMODS.Joker {
    key = "mammothjoker",
    atlas = "turtlejokers",
    pos = {x = 6, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 40, jokerslots = 1 }},
    loc_txt = {
        name = "Mammoth",
        text = {
            "{C:mult}+#1#{} Mult,",
            "-1{C:attention} Joker {}Slot",
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.mult, center.ability.extra.jokerslots }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.jokerslots
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.jokerslots
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
    atlas = "turtlejokers",
    pos = {x = 7, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { tags = 3 }},
    loc_txt = {
        name = "Cat",
        text = {
            "When {C:attention}Blind{} is",
            "Skipped, create #1#",
            "{C:attention}Double Tags",
        }
    },

    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.tags }}
    end,

    calculate = function(self, card, context)
        if context.skip_blind then
            for i = 1, card.ability.extra.tags do
                add_tag(Tag("tag_double"))
            end
            return {
                message = localize("k_sapjokers_plus_tag_cat")
            }
        end
    end
}
--Snake
SMODS.Joker {
    key = "snakejoker",
    atlas = "turtlejokers",
    pos = {x = 8, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { xmult = 0.05 }},
    loc_txt = {
        name = "Snake",
        text = {
            "Played cards give {X:mult,C:white}X#2#{}",
            "Mult when scored, increased",
            "by {C:mult}#1#{} for each {C:attention}Straight{}",
            "{C:attention}Flush{} played this game",
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, 1 + card.ability.extra.xmult * (G.GAME.hands["Straight Flush"].played or 0) }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            return {
                xmult = 1 + card.ability.extra.xmult * (G.GAME.hands["Straight Flush"].played)
            }
        end
    end,
}
--Fly
SMODS.Joker {
    key = "flyjoker",
    atlas = "turtlejokers",
    pos = {x = 9, y = 5},
    rarity = 3,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { repetitions = 1 }},
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

function SMODS.current_mod.reset_game_globals(run_start)
    reset_sapjokers_mail_rank()
    reset_sapjokers_leopard_rank()
end