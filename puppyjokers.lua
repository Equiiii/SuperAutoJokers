SMODS.current_mod.optional_features = {
    post_trigger = true
}

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

--This is all needed so that Mandrill can trigger toys' destroy effects

local remove_from_deck_ref = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
    if self.added_to_deck and SuperAutoJokers.toy_card_area and not from_debuff and self.ability.set == "toy" then
        if self.ability.name == "c_sapjokers_balloon" then
            ease_dollars(self.ability.extra.dollars)
        end

        if self.ability.name == "c_sapjokers_radio" then
            pseudoshuffle(G.playing_cards)
            for i = 1, 5 do
                G.playing_cards[i].ability.perma_bonus = G.playing_cards[i].ability.perma_bonus + self.ability.extra.bonus_chips
            end
        end

        if self.ability.name == "c_sapjokers_melonhelmet" then
            local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
            local edition_card = pseudorandom_element(editionless_jokers, "c_sapjokers_melonhelmet")
            local edition = poll_edition ("c_sapjokers_melonhelmet", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
            edition_card:set_edition(edition, true)
        end

        if self.ability.name == "c_sapjokers_ovenmitts" then
            local _hand, _played = "High Card", -1
            for hand_key, hand in pairs(G.GAME.hands) do
                if hand.played > _played then
                    _played = hand.played
                    _hand = hand_key
                end
            end
            local most_played = _hand
            SMODS.smart_level_up_hand(self, most_played, false, self.ability.extra.levels)
        end

        if self.ability.name == "c_sapjokers_cashregister" then
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i].sell_cost = G.jokers.cards[i].sell_cost + self.ability.extra.sell_cost_increase
            end
        end

        if self.ability.name == "c_sapjokers_flashlight" then
            if (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.0,
                    func = (function()
                        local card = create_card("Spectral", G.consumeables, nil, nil, nil, nil, nil)
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                    return true
                end)}))
            end
        end

        if self.ability.name == "c_sapjokers_tv" then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].edition and G.jokers.cards[i].edition.key == "e_foil" then
                    print("holo")
                    G.jokers.cards[i]:set_edition("e_holo")
                elseif G.jokers.cards[i].edition and G.jokers.cards[i].edition.key == "e_holo" then
                    print("poly")
                    G.jokers.cards[i]:set_edition("e_polychrome")
                end
            end
        end
    end
    return remove_from_deck_ref
end


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
            "{C:red,s:0.8}Destroyed in #1# round(s)",
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
            "{C:red,s:0.8}Destroyed in #1# round(s)",
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
            "{C:red,s:0.8}Destroyed in #1# round(s)",
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
    pos = {x = 3, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2, hand_count = 0 } },
    can_use = false,
    loc_txt = {
        name = "Tennis Ball",
        text = {
            "When held, the last scored",
            "card of every third",
            "hand is destroyed",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
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
            "{C:red,s:0.8}Destroyed in #1# round(s)",
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

SMODS.Consumable {
    key = "melonhelmet",
    set = "toy",
    pos = {x = 5, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2 } },
    can_use = false,
    loc_txt = {
        name = "Melon Helmet",
        text = {
            "When destroyed, give a",
            "random Joker {C:dark_edition}Foil{},",
            "{C:dark_edition}Holographic{} or {C:dark_edition}Polychrome",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left }}
    end,

    calculate = function(self, card, context)
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
    key = "foamsword",
    set = "toy",
    pos = {x = 0, y = 1},
    discovered = true,
    config = { extra = { rounds_left = 2 }},
    can_use = false,
    loc_txt = {
        name = "Foam Sword",
        text = {
            "When held, the lowest",
            "rank in played hands gets",
            "increased by one rank",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left }}
    end,

    calculate = function(self, card, context)
        if context.after then
            local strength_cards = {}
            local min_rank = 14
            for i = 1, #context.full_hand do
                local current_rank = context.full_hand[i]:get_id()
                if current_rank < min_rank then
                    min_rank = current_rank
                    strength_cards = {}
                    table.insert(strength_cards, i)
                elseif current_rank == min_rank then
                    table.insert(strength_cards, i)
                end
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('tarot1')
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
            for k, v in pairs(strength_cards) do
                local percent = 1.15 - (k - 0.999) / (#strength_cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        context.full_hand[v]:flip()
                        play_sound('card1', percent)
                        context.full_hand[v]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
            delay(0.2)
            for k, v in pairs(strength_cards) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        assert(SMODS.modify_rank(context.full_hand[v], 1))
                        return true
                    end
                }))
            end
            for k, v in pairs(strength_cards) do
                local percent = 0.85 + (k - 0.999) / (#strength_cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        context.full_hand[v]:flip()
                        play_sound('tarot2', percent, 0.6)
                        context.full_hand[v]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
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
    key = "toygun",
    set = "toy",
    pos = {x = 1, y = 1},
    discovered = true,
    config = { extra = { rounds_left = 2, mult = 4 }},
    can_use = false,
    loc_txt = {
        name = "Toy Gun",
        text = {
            "When held, cards in a",
            "{C:attention}five-card hand{} give",
            "{C:mult}+#2#{} Mult when scored",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if #context.scoring_hand == 5 then
                return {
                    mult = card.ability.extra.mult
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
    key = "ovenmitts",
    set = "toy",
    pos = {x = 6, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2, levels = 3 }},
    can_use = false,
    loc_txt = {
        name = "Oven Mitts",
        text = {
            "When destroyed, level up",
            "your most played poker hand",
            "by #2# levels",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.levels }}
    end,

    calculate = function(self, card, context)
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
    key = "toiletpaper",
    set = "toy",
    pos = {x = 6, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2, xmult = 1.5}},
    can_use = false,
    loc_txt = {
        name = "Toilet Paper",
        text = {
            "When held, the card(s) with",
            "the {C:attention}highest rank{} gives",
            "{X:mult,C:white}X#2#{} Mult when scored",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.xmult}}
    end,

    calculate = function(self, card, context)
        if context.before then
            max_rank = 0
            for i = 1, #context.full_hand do
                local current_rank = context.full_hand[i]:get_id()
                if current_rank > max_rank then
                    max_rank = current_rank
                end
            end
        end
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == max_rank then
            return {
                xmult = card.ability.extra.xmult
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
    key = "cashregister",
    set = "toy",
    pos = {x = 6, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2, sell_cost_increase = 3 }},
    can_use = false,
    loc_txt = {
        name = "Cash Register",
        text = {
            "When destroyed, increase the",
            "sell value of all jokers",
            "by {C:money}$#2#",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.sell_cost_increase }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_destroyed"),
                    extra = {message = localize("k_val_up")}
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
    key = "flashlight",
    set = "toy",
    pos = {x = 6, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2 }},
    can_use = false,
    loc_txt = {
        name = "Flashlight",
        text = {
            "When destroyed, create a",
            "random {C:spectral}Spectral{} card",
            "{C:inactive}(Must have room){}",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
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
    key = "stinkysock",
    set = "toy",
    pos = {x = 6, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2 }},
    can_use = false,
    loc_txt = {
        name = "Stinky Sock",
        text = {
            "When held, {C:attention}Small Blinds{}",
            "and {C:attention}Big Blinds{} have",
            "their requirements halved",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            if G.GAME.blind:get_type() ~= "Boss" then
                G.GAME.blind.chips = G.GAME.blind.chips / 2
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                return {
                    message = localize("k_sapjokers_score_reduced")
                }
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
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
    key = "camera",
    set = "toy",
    pos = {x = 6, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2, mult = 30, hand_size = 1 }},
    can_use = false,
    loc_txt = {
        name = "Camera",
        text = {
            "When held, {C:mult}+#2#{} Mult",
            "and {C:attention}-#3#{} Hand Size",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.mult, card.ability.extra.hand_size }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.hand_size)
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
                G.hand:change_size(card.ability.extra.hand_size)
                SMODS.destroy_cards(card, nil, nil, true)
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
    key = "tv",
    set = "toy",
    pos = {x = 5, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2 }},
    can_use = false,
    loc_txt = {
        name = "Television",
        text = {
            "When destroyed, ALL {C:dark_edition}Foil{}",
            "and {C:dark_edition}Holographic{} cards get",
            "their editions upgraded",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left }}
    end,

    calculate = function(self, card, context)
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
    key = "peanutjar",
    set = "toy",
    pos = {x = 6, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2, xmult = 20 }},
    can_use = false,
    loc_txt = {
        name = "Peanut Jar",
        text = {
            "When held, score {X:mult,C:white}X#2#{}",
            "Mult next hand, then",
            "debuff this",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.after then
            SMODS.debuff_card(card, true, "c_sapjokers_peanutjar_undebuff")
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_destroyed")
                }
        end   
    end,
}

SMODS.Consumable {
    key = "airpalmtree",
    set = "toy",
    pos = {x = 5, y = 2},
    discovered = true,
    config = { extra = { rounds_left = 2, xmult = 1, xmult_gain = 0.3 }},
    can_use = false,
    loc_txt = {
        name = "Air Palm Tree",
        text = {
            "When held, gain {X:mult,C:white}X#3#{}",
            "Mult for each",
            "hand played",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{}{C:inactive} Mult){}",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.xmult, card.ability.extra.xmult_gain }}
    end,

    calculate = function(self, card, context)
        if context.before then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            return {
                message = localize("k_upgrade_ex")
            }
        end
        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
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

--Moth
SMODS.Joker {
    key = "mothjoker",
    pos = { x = 0, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 7 }},
    loc_txt = {
        name = "Moth",
        text = {
            "First played card",
            "gives {C:mult}+#1# {}Mult",
            "when scored",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}
--Chinchilla
SMODS.Joker {
    key = "chinchillajoker",
    pos = { x = 1, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Chinchilla",
        text = {
            "Sell this {C:attention}Joker{} to",
            "create a Chinchilla",
            "which gets {C:attention}debuffed",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self and #G.jokers.cards + G.GAME.joker_buffer - 1 < G.jokers.config.card_limit then
            G.GAME.joker_buffer = G.GAME.joker_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.0,
                func = (function()
                    local card = create_card("Chinchilla",G.jokers, nil, nil, nil, nil, "j_sapjokers_chinchillajoker")
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    G.GAME.joker_buffer = 0
                    SMODS.debuff_card(card, true, "j_sapjokers_chinchillajoker")
                return true
                end)}))
        end
    end
}
--Beetle
--Ladybug
--Chipmunk
SMODS.Joker {
    key = "chipmunkjoker",
    pos = { x = 4, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Chipmunk",
        text = {
            "Sell this {C:attention}Joker{} to",
            "copy its {C:dark_edition}edition{} to",
            "the Joker to the left",
        }
    },

    calculate = function(self, card, context)
        local joker_pos
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                joker_pos = i
                break
            end
        end
        if context.selling_self and card.edition ~= nil then
            G.jokers.cards[joker_pos-1]:set_edition(card.edition, true, true)
        end
    end,
}
--Gecko
--Ferret
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
                        key = pseudorandom_element({"c_sapjokers_balloon", "c_sapjokers_stick"}, "j_sapjokers_ferretjoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}
--Bilby
SMODS.Joker {
    key = "bilbyjoker",
    pos = { x = 0, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { odds = 3 }},
    loc_txt = {
        name = "Bilby",
        text = {
            "When a card is {C:attention}added{}",
            "to the deck, {C:green}#1# in{}",
            "{C:green}#2#{} chance to create",
            "a {C:tarot}Tarot {}card",
            "{C:inactive}(Must have room){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { (2 * (G.GAME.probabilities.normal or 1)), card.ability.extra.odds }}
    end,

    calculate = function(self, card, context)
        if context.playing_card_added and not context.blueprint then
            if pseudorandom("j_sapjokers_bilbyjoker") < (2 * G.GAME.probabilities.normal) / card.ability.extra.odds then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    delay = 0.0,
                    func = (function()
                        local card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, nil)
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
--Gold Fish
--Robin
--Bat
--Dromedary
--Shrimp
--Sturgeon
--Tabby Cat
SMODS.Joker {
    key = "tabbycatjoker",
    pos = { x = 7, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 0, mult_gain = 8 }},
    loc_txt = {
        name = "Tabby Cat",
        text = {
            "When this Joker gains an",
            "{C:dark_edition}Edition{}, remove it and",
            "gain {C:mult}+#2#{} Mult",
            "{C:inactive}(Currently {}{C:mult}+#1#{}{C:inactive} Mult)"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain }}
    end,

    calculate = function(self, card, context)
        if context.given_edition and not context.blueprint then
            if card.edition then
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.0,
                    func = (function()
                        card:set_edition(nil, true)
                        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                    return true
                    end)}))
                return {
                    message = localize("k_upgrade_ex")
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
--Mandrill
SMODS.Joker {
    key = "mandrilljoker",
    pos = { x = 8, y = 1 },
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = { extra = { mandrill_rounds = 0, total_rounds = 3 }},
    loc_txt = {
        name = "Mandrill",
        text = {
            "After {C:attention}#2#{} rounds,",
            "destroy this and all",
            "held {C:attention}Toys",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mandrill_rounds, card.ability.extra.total_rounds }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            card.ability.extra.mandrill_rounds = card.ability.extra.mandrill_rounds + 1
            if card.ability.extra.mandrill_rounds >= card.ability.extra.total_rounds then
                if #SuperAutoJokers.toy_card_area.cards ~= 0 then
                    for i = 1, #SuperAutoJokers.toy_card_area.cards do
                        SMODS.destroy_cards(SuperAutoJokers.toy_card_area.cards[i], nil, nil, true)
                    end
                end
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = (card.ability.extra.mandrill_rounds .. "/" .. card.ability.extra.total_rounds),
                    colour = G.C.FILTER
                }
            end
        end
    end
}
--Lemur
SMODS.Joker {
    key = "lemurjoker",
    pos = { x = 9, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 4,
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
                        key = pseudorandom_element({"c_sapjokers_radio", "c_sapjokers_plasticsaw", "c_sapjokers_tennisball"}, "j_sapjokers_lemurjoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}
--Toucan
--Hare
--Hoopoe Bird
--Tropical Fish
--Owl
--Mole
SMODS.Joker {
    key = "molejoker",
    pos = { x = 6, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 25 }},
    loc_txt = {
        name = "Mole",
        text = {
            "{C:mult}+#1#{} Mult, debuffed",
            "every other hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            SMODS.debuff_card(card, true, "j_sapjokers_molejoker_undebuff")
            return {
                mult = card.ability.extra.mult,
                extra = {message = localize("k_sapjokers_debuffed")}
            }
        end
    end,
}
--Flying Squirrel
--Pangolin
--Gharial
SMODS.Joker {
    key = "gharialjoker",
    pos = { x = 9, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 5,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Gharial",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 3 {C:attention}Toy",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card ({
                        key = pseudorandom_element({"c_sapjokers_melonhelmet", "c_sapjokers_foamsword", "c_sapjokers_toygun"}, "j_sapjokers_gharialjoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}
--Microbe
SMODS.Joker {
    key = "microbejoker",
    pos = { x = 0, y = 3 },
    rarity = 2,
    blueprint_compat = false,
    cost = 5,
    discovered = true,
    config = { extra = { sell_cost_increase = 3 }},
    loc_txt = {
        name = "Microbe",
        text = {
            "At the end of round,",
            "{C:attention}Debuff{} the Joker to the",
            "right and increase its",
            "sell value by {C:money}$#1#{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_cost_increase }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            local microbe_pos
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    microbe_pos = i
                    break
                end
            end
            if microbe_pos and G.jokers.cards[microbe_pos + 1] then
                SMODS.debuff_card(G.jokers.cards[microbe_pos + 1], true, "j_sapjokers_microbejoker_undebuff")
                G.jokers.cards[microbe_pos + 1].sell_cost = G.jokers.cards[microbe_pos + 1].sell_cost + card.ability.extra.sell_cost_increase
                return {
                    message = localize("k_sapjokers_debuffed"),
                    extra = { message = localize("k_val_up") }
                }
            end
        end
    end,
}
--Lobster
--Buffalo
--Llama
--Caterpillar
--Doberman
--Tahr
--Whale Shark

local card_set_edition_ref = Card.set_edition
function Card:set_edition(edition, immediate, silent, delay)

    card_set_edition_ref(self, edition, immediate, silent, delay)
    if self.ability.name == "j_sapjokers_whalesharkjoker" or self.ability.name == "j_sapjokers_tabbycatjoker" then
        SMODS.calculate_context({ given_edition = true }) 
    end
end

SMODS.Joker {
    key = "whalesharkjoker",
    pos = { x = 7, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Whale Shark",
        text = {
            "When this Joker gains an",
            "{C:dark_edition}Edition{}, remove it and",
            "gain a random {C:spectral}Spectral{} card",
            "{C:inactive}(Must have room){}",
        }
    },

    calculate = function(self, card, context)
        if context.given_edition and not context.blueprint then
            if card.edition then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.0,
                    func = (function()
                        card:set_edition(nil, true)
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
        end
    end,
}
--Chameleon
--Puppy
SMODS.Joker {
    key = "puppyjoker",
    pos = { x = 9, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 6,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Puppy",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 4 {C:attention}Toy",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card ({
                        key = pseudorandom_element({"c_sapjokers_ovenmitts", "c_sapjokers_toiletpaper", "c_sapjokers_cashregister"}, "j_sapjokers_puppyjoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}
--Stonefish
--Goat
--Chicken
--Orchid Mantis
--Eagle
--Panther
SMODS.Joker {
    key = "pantherjoker",
    pos = {x = 5, y = 4},
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { chips = 50, mult = 10, xmult = 1.5 }},
    loc_txt = {
        name = "Panther",
        text = {
            "Editions on jokers",
            "trigger an",
            "additional time",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult, card.ability.extra.mult }}
    end,
}

--[[local calc_edition_ref = Card.calculate_edition
function Card:calculate_edition(context)
    local panther_count = #SMODS.find_card("j_sapjokers_pantherjoker")
    for i = 1, panther_count + 1 do
        print("panther")
        calc_edition_ref(self, context)
    end
end]]
--Axolotl
--Snapping Turtle
--Mosasaurus
--Stingray
SMODS.Joker {
    key = "stingrayjoker",
    pos = { x = 9, y = 4 },
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 7,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Sting Ray",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 5 {C:attention}Toy",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card ({
                        key = pseudorandom_element({"c_sapjokers_flashlight", "c_sapjokers_stinkysock", "c_sapjokers_camera"}, "j_sapjokers_puppyjoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}
--Mantis Shrimp
--Lionfish, needs more testing once other debuffing jokers are implemented
SMODS.Joker {
    key = "lionfishjoker",
    pos = { x = 1, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 1, xmult_gain = 0.1 }},
    loc_txt = {
        name = "Lionfish",
        text = {
            "This Joker gains {X:mult,C:white}X#2#{} Mult",
            "when a {C:attention}Debuffed{}",
            "Joker triggers",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain }}
    end,

    calculate = function(self, card, context)
        if context.post_trigger then
            local other_ret = context.other_ret.jokers or {}
            if other_ret.debuff then
                return {
                    message = localize {
                        type = "variable",
                        key = "a_xmult",
                        vars = card.ability.extra.xmult_gain
                    }
                }
            end
        end
    end,
}
--Tyrannosaurus
SMODS.Joker {
    key = "tyrannosaurusjoker",
    pos = { x = 3, y = 5 },
    rarity = 3,
    blueprint_compat = false,
    cost = 7,
    discovered = true,
    config = { extra = { end_of_round_payout = 12 }},
    loc_txt = {
        name = "Tyrannosaurus",
        text = {
            "Earn {C:money}$#1#{} at end",
            "of round if you own a",
            "rare {C:attention}Joker{} other than",
            "this one",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.end_of_round_payout }}
    end,

    calc_dollar_bonus = function(self, card)
        local has_other_rare = false
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.rarity == 3 and G.jokers.cards[i] ~= card then
                has_other_rare = true
            end
        end
        if has_other_rare == true then
            return card.ability.extra.end_of_round_payout
        end
    end,
}
--Octopus
--Anglerfish
--Sauropod
--Elephant Seal
--Puma
--Mongoose
SMODS.Joker {
    key = "mongoosejoker",
    pos = { x = 9, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 8,
    discovered = true,
    config = {},
    pools = {sell = true},
    loc_txt = {
        name = "Mongoose",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 6 {C:attention}Toy",
        }
    },

    calculate = function(self, card, context)
        if context.selling_self and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card ({
                        key = pseudorandom_element({"c_sapjokers_tv", "c_sapjokers_peanutjar", "c_sapjokers_airpalmtree"}, "j_sapjokers_mongoosejoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}

peanutjar_rounds = 0

mole_hands = 0

local calculate_context_ref = SMODS.calculate_context
SMODS.calculate_context = function(context, return_table)

    if context.after then
        for k, v in ipairs(G.jokers.cards) do
            if v.ability.debuff_sources and next(v.ability.debuff_sources) and v.ability.debuff_sources["j_sapjokers_molejoker_undebuff"] then
                mole_hands = mole_hands + 1
                if mole_hands == 2 then
                    v:juice_up()
                    SMODS.debuff_card(v, false, "j_sapjokers_molejoker_undebuff")
                    mole_hands = 0
                end
            end
        end
    end
    
    if context.end_of_round then
        for k, v in ipairs(SuperAutoJokers.toy_card_area.cards) do
            if v.ability.debuff_sources and next(v.ability.debuff_sources) and v.ability.debuff_sources["c_sapjokers_peanutjar_undebuff"] then
                peanutjar_rounds = peanutjar_rounds + 1
                if peanutjar_rounds == 2 then
                    v:juice_up()
                    SMODS.debuff_card(v, false, "c_sapjokers_peanutjar_undebuff")
                    peanutjar_rounds = 0
                end
            end
        end
    end

    local ret = calculate_context_ref(context, return_table)
    return ret
end