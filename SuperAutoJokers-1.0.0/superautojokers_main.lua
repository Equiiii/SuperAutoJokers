-- Test Joker
SMODS.Joker {
    key = "joker",
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
--Beaver
SMODS.Joker {
    key = "beaverjoker",
    pos = {x = 1, y = 0},
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = {},
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
            if context.other_card:get_id() ==  4 then
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
--Cricket
--Horse
--Snail
--Crab
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
--Hedgehog
--Peacock
--Flamingo
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
--Dodo
--Badger
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
            "{C:inactive}(Currently {C:red}+#1#{}{C:inactive} Mult){}",
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
--Ox
--Dog
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
--Turtle
--Squirrel
--Penguin
--Deer
--Whale
--Parrot
--Scorpion
--Croc
--Rhino
--Monkey
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
    config = {extra = {cow_rounds = 0, total_rounds = 1}},
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
        name = "Mammoth",
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
--Dragon
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
            "+{C:mult}40{} Mult,",
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
