SMODS.current_mod.optional_features = {
    post_trigger = true,
    retrigger_joker = true,
}

--Looked at JoyousSpring a LOT for this, shoutout to nh6574

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

    if G.GAME.selected_back.effect.center.key == "b_sapjokers_puppydeck" then
        SuperAutoJokers.toy_card_area.T.x = G.consumeables.T.x + 2.25
    else
        SuperAutoJokers.toy_card_area.T.x = G.consumeables.T.x + 2.75
    end
    if next(SMODS.find_mod("Multiplayer")) then
        SuperAutoJokers.toy_card_area.T.y = G.consumeables.T.y + 5.75
    else
        SuperAutoJokers.toy_card_area.T.y = G.consumeables.T.y + 3
    end
end

--Toy consumable type

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

SMODS.Atlas {
    key = "toys",
    path = "Toys.png",
    px = 71,
    py = 95,
}

--Pool for all Puppy Pack jokers
SMODS.ObjectType({
    key = "puppyjokers",
    default = "j_sapjokers_beaverjoker",
    cards = {},
    inject = function(self)
SMODS.ObjectType.inject(self)
    end,
})

SMODS.ObjectType({
    key = "puppyjokers_rare",
    default = "j_sapjokers_anglerfishjoker",
    cards = {},
    inject = function(self)
SMODS.ObjectType.inject(self)
    end,
})

--Puppy Deck

SMODS.Back {
    key = "puppydeck",
    atlas = "backs",
    pos = {x = 1, y = 0},
    unlocked = true,
    discovered = true,
    config = { extra = { toy_slots = 1 }},
    loc_txt = {
        name = "Puppy Deck",
        text = {
            "+#1# {C:attention}Toy slot{}, create",
            "a random {C:attention}Toy{} when",
            "redeeming a {C:attention}Voucher",
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = { self.config.extra.toy_slots }}
    end,

    apply = function(self, back)
        SuperAutoJokers.toy_card_area.config.card_limit = SuperAutoJokers.toy_card_area.config.card_limit + self.config.extra.toy_slots
        SuperAutoJokers.toy_card_area.T.w = SuperAutoJokers.toy_card_area.T.w * 1.5
    end,

    calculate = function(self, back, context)
        if context.buying_card and context.card.ability.set == "Voucher" and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card {
                        set = "toy",
                        area = SuperAutoJokers.toy_card_area
                    }
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,


}

--This is all needed so that Mandrill can trigger toys' destroy effects

local remove_from_deck_ref = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
    if self.added_to_deck and SuperAutoJokers.toy_card_area and not from_debuff and self.ability.set == "toy" then
        if self.ability.name == "c_sapjokers_balloon" then
            SMODS.calculate_context({ activate_balloon = true })
            ease_dollars(self.ability.extra.dollars)
        end

        if self.ability.name == "c_sapjokers_radio" then
            SMODS.calculate_context({ activate_radio = true })
            pseudoshuffle(G.playing_cards)
            for i = 1, 5 do
                G.playing_cards[i].ability.perma_bonus = G.playing_cards[i].ability.perma_bonus + self.ability.extra.bonus_chips
            end
        end

        if self.ability.name == "c_sapjokers_melonhelmet" then
            SMODS.calculate_context({ activate_melon_helmet = true })
            local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
            local edition_card = pseudorandom_element(editionless_jokers, "c_sapjokers_melonhelmet")
            local edition = poll_edition ("c_sapjokers_melonhelmet", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
            if edition_card ~= nil then
                edition_card:set_edition(edition, true)
            end

            local editionless_cards = SMODS.Edition:get_edition_cards(G.deck, true)
            local other_edition_card = pseudorandom_element(editionless_cards, "c_sapjokers_melonhelmet")
            local other_edition = poll_edition ("c_sapjokers_melonhelmet", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
            if other_edition_card ~= nil then
                other_edition_card:set_edition(other_edition, true)
            end
        end

        if self.ability.name == "c_sapjokers_ovenmitts" then
            SMODS.calculate_context({ activate_oven_mitts = true })
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
            SMODS.calculate_context({ activate_cash_register = true })
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i].sell_cost = G.jokers.cards[i].sell_cost + self.ability.extra.sell_cost_increase
            end
        end

        if self.ability.name == "c_sapjokers_flashlight" then
            SMODS.calculate_context({ activate_flashlight = true })
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
            SMODS.calculate_context({ activate_tv = true })
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].edition and G.jokers.cards[i].edition.key == "e_foil" then
                    G.jokers.cards[i]:set_edition("e_holo")
                elseif G.jokers.cards[i].edition and G.jokers.cards[i].edition.key == "e_holo" then
                    G.jokers.cards[i]:set_edition("e_polychrome")
                end
            end
            for _, playing_card in ipairs(G.playing_cards) do
                if playing_card.edition and playing_card.edition.key == "e_foil" then
                    playing_card:set_edition("e_holo")
                elseif playing_card.edition and playing_card.edition.key == "e_holo" then
                    playing_card:set_edition("e_polychrome")
                end
            end
        end
    end

    local ret = remove_from_deck_ref(self, from_debuff)
    return ret
end

--Logic to allow some jokers to remove their own debuffs

local can_calculate_ref = Card.can_calculate
function Card:can_calculate(ignore_debuff, ignore_sliced)
    local ret = can_calculate_ref(self, ignore_debuff, ignore_sliced)
    if self.config.center.key == "j_sapjokers_owljoker" and self.debuff == true then
        return true
    end
    return ret
end

local debuff_card_ref = SMODS.debuff_card
function SMODS:debuff_card(card, debuff, source)
    local ret = debuff_card_ref(self, card, debuff, source)
    if self.debuff == true and self.ability.set == "Joker" then
        SMODS.calculate_context({joker_debuffed = true, cards = { self }})
        if self.config.center.key == "j_sapjokers_owljoker" then
            SMODS.calculate_context({owl_joker_debuffed = true, cards = { self }})
        end
    end
    if self.debuff == false and self.ability.set == "Joker" and debuff ~= "sapjokers_ignorecontext" then
        SMODS.calculate_context({joker_undebuffed = true, cards = { self }})
    end
    return ret
end

--Toys


SMODS.Consumable {
    key = "stick",
    set = "toy",
    atlas = "toys",
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
            SMODS.calculate_context({ toy_repetition = true, card = {card} })
            return {
                mult = card.ability.extra.mult
            }
        end

        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            return {
                mult = card.ability.extra.mult,
                extra = {
                    message = localize("k_again_ex")
                }
            }
        end
        
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
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
                SMODS.calculate_context({ toy_repetition = true, card = {card} })
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
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
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
    pos = {x = 3, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2, hand_count = 0, active = false } },
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
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.hand_count, card.ability.extra.active }}
    end,

    calculate = function(self, card, context)
        local eval = function()
            return card.ability.extra.active
        end
        if context.joker_main then
            card.ability.extra.hand_count = card.ability.extra.hand_count + 1
            if card.ability.extra.hand_count == 3 then
                card.ability.extra.active = false
                card.ability.extra.hand_count = 0
                SMODS.destroy_cards(context.scoring_hand[#context.scoring_hand])
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                if card.ability.extra.hand_count == 2 then
                    card.ability.extra.active = true
                    juice_card_until(card, eval, true)
                end
                return {
                    message = card.ability.extra.hand_count .. "/3",
                }
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
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
            SMODS.calculate_context({ toy_repetition = true, card = {card} })
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end

        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            card.ability.extra.repetitions = card.ability.extra.repetitions + 1
        end

        if context.after then
            card.ability.extra.repetitions = 1
        end
    end,
}

SMODS.Consumable {
    key = "melonhelmet",
    set = "toy",
    atlas = "toys",
    pos = {x = 5, y = 0},
    discovered = true,
    config = { extra = { rounds_left = 2 } },
    can_use = false,
    loc_txt = {
        name = "Melon Helmet",
        text = {
            "When destroyed, give a",
            "random {C:attention}Joker{} and {C:attention}playing{}",
            "{C:attention}card{} {C:dark_edition}Foil{}, {C:dark_edition}Holographic{}",
            "or {C:dark_edition}Polychrome{}",
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
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
    pos = {x = 6, y = 0},
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
            foamsword_strengthen = function()
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
            foamsword_strengthen()
            SMODS.calculate_context({ toy_repetition = true })
        end

        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            foamsword_strengthen()
        end

        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
    pos = {x = 7, y = 0},
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
                SMODS.calculate_context({ toy_repetition = true })
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end

        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            return {
                message = localize("k_again_ex"),
                extra = {    
                    mult = card.ability.extra.mult
                },
            }
        end
    end,
}

SMODS.Consumable {
    key = "ovenmitts",
    set = "toy",
    atlas = "toys",
    pos = {x = 8, y = 0},
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
                SMODS.calculate_context({ toy_repetition = true })
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
    pos = {x = 9, y = 0},
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
            SMODS.calculate_context({ toy_repetition = true })
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end

        --Something weird is happening here, need to look into it
        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}

SMODS.Consumable {
    key = "cashregister",
    set = "toy",
    atlas = "toys",
    pos = {x = 0, y = 1},
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
                SMODS.calculate_context({ toy_repetition = true })
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
    pos = {x = 1, y = 1},
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
                SMODS.calculate_context({ toy_repetition = true })
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
    pos = {x = 2, y = 1},
    discovered = true,
    config = { extra = { rounds_left = 2 }},
    can_use = false,
    loc_txt = {
        name = "Stinky Sock",
        text = {
            "When held, {C:attention}Small Blinds{}",
            "and {C:attention}Big Blinds{} have",
            "their requirements halved",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            SMODS.calculate_context({ toy_repetition = true })
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
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
                return {
                    message = localize("k_sapjokers_destroyed"),
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end

        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            if G.GAME.blind:get_type() ~= "Boss" then
                G.GAME.blind.chips = G.GAME.blind.chips / 2
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                return {
                    message = localize("k_sapjokers_score_reduced"),
                    extra = {
                        message = localize("k_again_ex")
                    }
                }
            end
        end
    end,
}

SMODS.Consumable {
    key = "camera",
    set = "toy",
    atlas = "toys",
    pos = {x = 3, y = 1},
    discovered = true,
    config = { extra = { rounds_left = 2, xmult = 3, hand_size = 1 }},
    can_use = false,
    loc_txt = {
        name = "Camera",
        text = {
            "When held, {X:mult,C:white}X#2#{} Mult",
            "and {C:attention}-#3#{} Hand Size",
            "{C:red,s:0.8}Destroyed in #1# round(s)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_left, card.ability.extra.xmult, card.ability.extra.hand_size }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.hand_size)
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            SMODS.calculate_context({ toy_repetition = true })
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                G.hand:change_size(card.ability.extra.hand_size)
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
                return {
                    message = localize("k_sapjokers_destroyed"),
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end

        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            return {
                xmult = card.ability.extra.xmult,
                extra = {
                    message = localize("k_again_ex")
                }
            }
        end
    end,
}

SMODS.Consumable {
    key = "tv",
    set = "toy",
    atlas = "toys",
    pos = {x = 4, y = 1},
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
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
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
    atlas = "toys",
    pos = {x = 5, y = 1},
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
            SMODS.calculate_context({ toy_repetition = true })
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.after then
            SMODS.debuff_card(card, true, "c_sapjokers_peanutjar_undebuff")
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
                return {
                    message = localize("k_sapjokers_destroyed")
                }
        end

        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            return {
                xmult = card.ability.extra.xmult,
                extra = {
                    message = localize("k_again_ex")
                }
            }
        end
    end,
}

SMODS.Consumable {
    key = "airpalmtree",
    set = "toy",
    atlas = "toys",
    pos = {x = 6, y = 1},
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
            SMODS.calculate_context({ toy_repetition = true })
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.end_of_round and context.game_over == false and context.main_eval then
            card.ability.extra.rounds_left = card.ability.extra.rounds_left - 1
            if card.ability.extra.rounds_left == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end

        if context.chameleon_repeat and card == SuperAutoJokers.toy_card_area.cards[1] then
            return {
                xmult = card.ability.extra.xmult,
                extra = {
                    message = localize("k_again_ex")
                }
            }
        end
    end,
}

--Jokers

SMODS.Atlas {
    key = "puppyjokers",
    path = "PuppyJokers.png",
    px = 71,
    py = 95,
}

--Duck
SMODS.Joker {
    key = "duck2joker",
    atlas = "puppyjokers",
    pos = {x = 0, y = 0},
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 2,
    discovered = true,
    config = { extra = { duck_rounds = 0, total_rounds = 2 }},
    pools = {sell = true, turtlejokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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
        info_queue[#info_queue + 1] = G.P_CENTERS.c_death
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
    key = "beaver2joker",
    atlas = "puppyjokers",
    pos = {x = 1, y = 0},
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 2,
    discovered = true,
    config = {},
    pools = {sell = true, puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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

--Moth
SMODS.Joker {
    key = "mothjoker",
    atlas = "puppyjokers",
    pos = { x = 2, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 7 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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
--Bluebird
SMODS.Joker {
    key = "bluebirdjoker",
    atlas = "puppyjokers",
    pos = { x = 3, y = 0 },
    rarity = 1,
    blueprint_compat = false,
    cost = 5,
    discovered = true,
    config = { extra = { perma_mult = 3 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Bluebird",
        text = {
            "At the end of round,",
            "give a random card in {C:attention}hand{}",
            "{C:mult}+#1#{} Mult permanently",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.perma_mult }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.game_over and context.main_eval then
            local upgrade_card = pseudorandom_element(G.hand.cards, "j_sapjokers_bluebirdjoker")
            upgrade_card.ability.perma_mult = (upgrade_card.ability.perma_mult or 0) + card.ability.extra.perma_mult
            return {
                message = localize("k_upgrade_ex")
            }
        end
    end,
}
--Chinchilla
SMODS.Joker {
    key = "chinchillajoker",
    atlas = "puppyjokers",
    pos = { x = 4, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = {},
    pools = {puppyjokers = true, sell = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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
SMODS.Joker {
    key = "beetlejoker",
    atlas = "puppyjokers",
    pos = { x = 5, y = 0 },
    rarity = 1,
    blueprint_compat = false,
    cost = 4,
    discovered = true,
    config = {},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Beetle",
        text = {
            "When bought, this",
            "{C:attention}Joker{} gains {C:dark_edition}Foil{}",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_foil
    end,
    
    add_to_deck = function(self, card, from_debuff)
        card:set_edition("e_foil", true, true)
    end,

    calculate = function(self, card, context)
        if context.buying_self then
            return {
                message = localize("k_sapjokers_foil"),
                colour = G.C.DARK_EDITION
            }
        end
    end,
}
--Ladybug
SMODS.Joker {
    key = "ladybugjoker",
    atlas = "puppyjokers",
    pos = { x = 6, y = 0 },
    rarity = 1,
    blueprint_compat = false,
    cost = 3,
    discovered = true,
    config = { extra = { rounds = 2 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Ladybug",
        text = {
            "In #1# rounds, give {C:dark_edition}Holographic{}",
            "to the Joker to the {C:attention}right,",
            "then debuff this"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_holo
        return { vars = { card.ability.extra.rounds }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and context.main_eval and not context.game_over then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds == 0 then
                local joker_pos
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then
                        joker_pos = i
                        break
                    end
                end
                if G.jokers.cards[joker_pos + 1] ~= nil then
                    G.jokers.cards[joker_pos + 1]:set_edition("e_holo", true)
                end
                SMODS.debuff_card(card, true, "j_sapjokers_ladybugjoker")
                return {
                    message = localize("k_sapjokers_debuffed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end
    end,
}
--Chipmunk
SMODS.Joker {
    key = "chipmunkjoker",
    atlas = "puppyjokers",
    pos = { x = 7, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 3,
    discovered = true,
    config = {},
    pools = {puppyjokers = true, sell = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Chipmunk",
        text = {
            "Sell this {C:attention}Joker{} to",
            "swap the {C:dark_edition}Editions{} of",
            "adjacent Jokers",
            "{C:inactive}(Cannot swap Negative){}",
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
        if context.selling_self then
            if G.jokers.cards[joker_pos - 1] and G.jokers.cards[joker_pos - 1].edition then
                left_edition = G.jokers.cards[joker_pos - 1].edition.key
            else
                left_edition = nil
            end
            if G.jokers.cards[joker_pos + 1] and G.jokers.cards[joker_pos + 1].edition then
                right_edition = G.jokers.cards[joker_pos + 1].edition.key
            else
                right_edition = nil
            end
            if left_edition ~= "e_negative" and right_edition ~= "e_negative" and G.jokers.cards[joker_pos - 1] ~= nil and G.jokers.cards[joker_pos + 1] ~= nil then
                G.jokers.cards[joker_pos - 1]:set_edition(right_edition, true)
                G.jokers.cards[joker_pos + 1]:set_edition(left_edition, true)
                return {
                    message = localize("k_sapjokers_swapped")
                }
            end
        end
    end,
}
--Gecko
SMODS.Joker {
    key = "geckojoker",
    atlas = "puppyjokers",
    pos = { x = 8, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 3,
    discovered = true,
    config = { extra = { mult = 15 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Gecko",
        text = {
            "{C:mult}+#1#{} Mult if you",
            "have an active {C:attention}Toy",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if #SuperAutoJokers.toy_card_area.cards > 0 then
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
    end,
}
--Ferret
SMODS.Joker {
    key = "ferretjoker",
    atlas = "puppyjokers",
    pos = { x = 9, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 3,
    discovered = true,
    config = {},
    pools = {sell = true, puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Ferret",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 1 {C:attention}Toy",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_stick
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_balloon
        return {
        }
    end,

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
    atlas = "puppyjokers",
    pos = { x = 0, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { odds = 3 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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
        if context.playing_card_added and not context.blueprint and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then
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
SMODS.Joker {
    key = "goldfishjoker",
    atlas = "puppyjokers",
    pos = { x = 1, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 0, mult_gain = 2, count = 5, current = 0 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Gold Fish",
        text = {
            "After earning {C:money}money{} #3#",
            "times, this Joker gains",
            "{C:mult}+#2#{} Mult permanently",
            "{C:inactive}(Currently {}{C:mult}+#1#{}{C:inactive} Mult, #4#/#3#)"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain, card.ability.extra.count, card.ability.extra.current }}
    end,

    calculate = function(self, card, context)
        if context.money_altered and not context.blueprint and context.amount > 0 then
            card.ability.extra.current = card.ability.extra.current + 1
            if card.ability.extra.current == card.ability.extra.count then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                card.ability.extra.current = 0
                return {
                    message = localize("k_upgrade_ex")
                }
            else
                return {
                    message = card.ability.extra.current .. "/" .. card.ability.extra.count,
                    colour = G.C.IMPORTANT
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
--Robin
SMODS.Joker {
    key = "robinjoker",
    atlas = "puppyjokers",
    pos = { x = 2, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = {},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Robin",
        text = {
            "At the start of the",
            "Blind, create a {C:dark_edition}Foil{} {C:attention}Joker{}",
            "and {C:attention}Debuff{} it",
            "{C:inactive}(Must have room)",
        }
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS["j_joker"]
        info_queue[#info_queue+1] = G.P_CENTERS.e_foil
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                local added_card
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        added_card = SMODS.add_card {
                            key = "j_joker",
                        }
                        G.GAME.joker_buffer = 0
                        added_card:set_edition("e_foil", true)
                        return true
                    end
                }))
                delay(0.5)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        SMODS.debuff_card(added_card, true, "j_sapjokers_robinjoker")
                        return true
                    end
                }))
                return {
                    message = localize("k_plus_joker"),
                    colour = G.C.IMPORTANT,
                    extra = {message = localize("k_sapjokers_debuffed")}
                }
            end
        end
    end,
}
--Bat
SMODS.Joker {
    key = "batjoker",
    atlas = "puppyjokers",
    pos = { x = 3, y = 1 },
    rarity = 1,
    blueprint_compat = false,
    cost = 5,
    discovered = true,
    config = { extra = { mult = -5, dollars = 6 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Bat",
        text = {
            "{C:mult}#1# {}Mult, earn {C:money}$#2#",
            "at end of round",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.dollars }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.dollars
    end,
}
--Dromedary
SMODS.Joker {
    key = "dromedaryjoker",
    atlas = "puppyjokers",
    pos = { x = 4, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 1 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Dromedary",
        text = {
            "The first three cards {C:attention}held{}",
            "{C:attention}in hand{} give {C:mult}+#1#{} Mult",
            "for each card held in hand",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and (context.other_card == G.hand.cards[1] or context.other_card == G.hand.cards[2] or context.other_card == G.hand.cards[3]) then
            return {
                mult = card.ability.extra.mult * #G.hand.cards
            }
        end
    end,
}
--Shrimp
SMODS.Joker {
    key = "shrimpjoker",
    atlas = "puppyjokers",
    pos = { x = 5, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { chips = 0, chip_gain = 3 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Shrimp",
        text = {
            "{C:chips}+#2#{} Chips per {C:attention}dollar{}",
            "spent in shop, resets when",
            "{C:attention}entering{} a shop",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain }}
    end,

    calculate = function(self, card, context)
        if context.starting_shop and not context.blueprint then
            card.ability.extra.chips = 0
            return {
                message = localize("k_reset")
            }
        end

        if context.money_altered and context.amount < 0 and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + (card.ability.extra.chip_gain * context.amount * -1)
            return {
                message = localize{
                    type = "variable",
                    key = "a_chips",
                    vars = {card.ability.extra.chip_gain * context.amount * -1}
                },
                colour = G.C.CHIPS
            }
        end

        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
}
--Sturgeon
SMODS.Joker {
    key = "belugasturgeonjoker",
    atlas = "puppyjokers",
    pos = { x = 6, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = {},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Beluga Sturgeon",
        text = {
            "When {C:attention}Boss Blind{} is",
            "selected, add a random",
            "{C:dark_edition}Editioned{} card to deck",
        }
    },

    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind:get_type() == "Boss" then
            local added_card = SMODS.add_card { 
                set = "Base",
                edition = pseudorandom_element({"e_foil", "e_holo", "e_polychrome"}, "j_sapjokers_belugasturgeonjoker"),
                area = G.deck
            }
            SMODS.calculate_context({playing_card_added = true, cards = { added_card }})
            return {
                message = localize("k_sapjokers_plus_card")
            }
        end
    end,
}
--Tabby Cat
SMODS.Joker {
    key = "tabbycatjoker",
    atlas = "puppyjokers",
    pos = { x = 7, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 0, mult_gain = 10 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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
    atlas = "puppyjokers",
    pos = { x = 8, y = 1 },
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = { extra = { mandrill_rounds = 0, total_rounds = 3 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Mandrill",
        text = {
            "After {C:attention}#2#{} rounds, give a",
            "Joker a random {C:dark_edition}Edition{},",
            "then destroy this and",
            "all held {C:attention}Toys",
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
                        SMODS.calculate_context({ toy_destroyed = true, card_name = card.config.center.key })
                    end
                end
                SMODS.destroy_cards(card, nil, nil, true)
                local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
                for k, v in pairs(editionless_jokers) do
                    if v == card then
                        table.remove(editionless_jokers, k)
                    end
                end
                local edition_card = pseudorandom_element(editionless_jokers, "j_sapjokers_mandrilljoker")
                local edition = poll_edition ("j_sapjokers_mandrilljoker", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
                if edition_card ~= nil then
                    edition_card:set_edition(edition, true)
                    return {
                        message = localize("k_sapjokers_destroyed")
                    }
                else
                    return {
                        message = localize("k_sapjokers_no_targets")
                    }
                end
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
    atlas = "puppyjokers",
    pos = { x = 9, y = 1 },
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 4,
    discovered = true,
    config = {},
    pools = {sell = true, puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Lemur",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 2 {C:attention}Toy",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_radio
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_tennisball
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_plasticsaw
        return {
        }
    end,

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
SMODS.Joker {
    key = "toucanjoker",
    atlas = "puppyjokers",
    pos = { x = 0, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = {},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Toucan",
        text = {
            "At the start of the",
            "round, transfer this Joker's",
            "{C:dark_edition}edition{} to a random card",
            "{C:attention}held in hand{}, or gain",
            "a random {C:dark_edition}Edition{}"
        }
    },
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            if card.edition then
                local edition = card.edition.key
                local edition_card = pseudorandom_element(G.hand.cards, "j_sapjokers_toucanjoker")
                edition_card:set_edition(edition, true)
                card:set_edition(nil, true)
                return {
                    message = localize("k_sapjokers_transferred")
                }
            else
                local edition = poll_edition("j_sapjokers_toucanjoker", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
                card:set_edition(edition, true)
            end
        end
    end,
}
--Hare
SMODS.Joker {
    key = "harejoker",
    atlas = "puppyjokers",
    pos = { x = 1, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { chips = 120, debuff_rounds = 4 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Hare",
        text = {
            "{C:chips}+#1#{} Chips,",
            "Debuffed after {C:attention}#2#{} rounds"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.debuff_rounds }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end

        if context.end_of_round and not context.game_over and context.main_eval and not context.blueprint then
            card.ability.extra.debuff_rounds = card.ability.extra.debuff_rounds - 1
            if card.ability.extra.debuff_rounds == 0 then
                SMODS.debuff_card(card, true, "j_sapjokers_harejoker")
                return {
                    message = localize("k_sapjokers_debuffed")
                }
            else
                return {
                    message = localize("k_sapjokers_minus_round")
                }
            end
        end
    end,
}
--Hoopoe Bird
SMODS.Joker {
    key = "hoopoebirdjoker",
    atlas = "puppyjokers",
    pos = { x = 2, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { required_money = 25 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Hoopoe Bird",
        text = {
            "Gain a {C:tarot}Wheel of Fortune{}",
            "if hand is played",
            "with at least {C:money}$#1#{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS["c_wheel_of_fortune"]
        return { vars = { card.ability.extra.required_money }}
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.dollars >= card.ability.extra.required_money and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card {
                        set = "Tarot",
                        key = "c_wheel_of_fortune"
                    }
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
            return {
                message = localize("k_sapjokers_plus_wheel")
            }
        end
    end,
}
--Tropical Fish
SMODS.Joker {
    key = "tropicalfishjoker",
    atlas = "puppyjokers",
    pos = { x = 3, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { chips = 0, chips_gain = 7 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Tropical Fish",
        text = {
            "When beating a {C:attention}Blind{},",
            "{C:chips}+#2#{} Chips for each",
            "hand remaining",
            "{C:inactive}(Currently{}{C:chips} +#1#{}{C:inactive} Chips)",
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chips_gain }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.game_over and context.main_eval then
            card.ability.extra.chips = card.ability.extra.chips + (card.ability.extra.chips_gain * G.GAME.current_round.hands_left)
            return {
                message = localize {
                    type = "variable",
                    key = "a_chips",
                    vars = {card.ability.extra.chips_gain * G.GAME.current_round.hands_left}
                }
            }
        end

        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
}
--Hatching Chick
SMODS.Joker {
    key = "hatchingchickjoker",
    atlas = "puppyjokers",
    pos = { x = 4, y = 2 },
    rarity = 2,
    blueprint_compat = false,
    cost = 4,
    discovered = true,
    config = { extra = { hands = 4, hand_loss = 1 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Hatching Chick",
        text = {
            "{C:blue}+#1#{} hands,",
            "reduces by {C:red}#2#",
            "each round",
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands, card.ability.extra.hand_loss }}
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.game_over and context.main_eval then
            card.ability.extra.hands = card.ability.extra.hands - card.ability.extra.hand_loss
            G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand_loss
            if card.ability.extra.hands == 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_fainted"),
                    colour = G.C.MULT
                }
            else
                return {
                    message = localize("k_sapjokers_minus_hand")
                }
            end
        end
    end,
}
--Owl
SMODS.Joker {
    key = "owljoker",
    atlas = "puppyjokers",
    pos = { x = 5, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    cost = 4,
    discovered = true,
    config = { extra = { mult = 0, mult_gain = 5 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Owl",
        text = {
            "This cannot be {C:attention}Debuffed{},",
            "when any Joker is {C:attention}Debuffed",
            "this Joker gains {C:mult}+#2#{} Mult",
            "{C:inactive}(Currently{}{C:mult} +#1#{}{C:inactive} Mult)",
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain }}
    end,

    calculate = function(self, card, context)
        if context.owl_joker_debuffed then    
            SMODS.debuff_card(card, false, "j_sapjokers_general_undebuff")
            return {
                message = localize("k_sapjokers_undebuffed"),
            }
        end

        if context.joker_debuffed then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = localize {
                    type = "variable",
                    key = "a_mult",
                    vars = {card.ability.extra.mult_gain}
                }
            }
        end

        if context.joker_main and card.debuff == false then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
}
--Mole
SMODS.Joker {
    key = "molejoker",
    atlas = "puppyjokers",
    pos = { x = 6, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { mult = 25 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Mole",
        text = {
            "{C:mult}+#1#{} Mult, Debuffed",
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
SMODS.Joker {
    key = "flyingsquirreljoker",
    atlas = "puppyjokers",
    pos = { x = 7, y = 2 },
    rarity = 2,
    blueprint_compat = false,
    cost = 6,
    discovered = true,
    config = {},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Flying Squirrel",
        text = {
            "When a {C:attention}Toy{} is",
            "destroyed, replace it with a",
            "random Tier 1-2 {C:attention}Toy{}",
        }
    },

    calculate = function(self, card, context)
        if context.toy_destroyed and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer - 2 < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card ({
                        key = pseudorandom_element({
                            "c_sapjokers_balloon", "c_sapjokers_stick", "c_sapjokers_balloon",
                            "c_sapjokers_radio", "c_sapjokers_plasticsaw"}, "j_sapjokers_flyingsquirreljoker"),
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}
--Pangolin
SMODS.Joker {
    key = "pangolinjoker",
    atlas = "puppyjokers",
    pos = { x = 8, y = 2 },
    rarity = 2,
    blueprint_compat = false,
    cost = 5,
    discovered = true,
    config = { extra = { dollars = 7 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Pangolin",
        text = {
            "if you have a {C:attention}Toy{},",
            "earn {C:money}$#1#{} at end of round",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars }}
    end,

    calc_dollar_bonus = function(self, card)
        if #SuperAutoJokers.toy_card_area.cards > 0 then
            return card.ability.extra.dollars
        end
    end,
}
--Gharial
SMODS.Joker {
    key = "gharialjoker",
    atlas = "puppyjokers",
    pos = { x = 9, y = 2 },
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 5,
    discovered = true,
    config = {},
    pools = {sell = true, puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Gharial",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 3 {C:attention}Toy",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_melonhelmet
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_foamsword
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_toygun
        return {
        }
    end,

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
    atlas = "puppyjokers",
    pos = { x = 0, y = 3 },
    rarity = 2,
    blueprint_compat = false,
    cost = 5,
    discovered = true,
    config = { extra = { sell_cost_increase = 4 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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
                SMODS.debuff_card(G.jokers.cards[microbe_pos + 1], true, "j_sapjokers_general_undebuff")
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
SMODS.Joker {
    key = "lobsterjoker",
    atlas = "puppyjokers",
    pos = { x = 1, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { perma_mult = 1 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Lobster",
        text = {
            "When hand is played,",
            "Cards {C:attention}held in hand{}",
            "gain {C:mult}+#1#{} Mult",
            "permanently",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.perma_mult }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + card.ability.extra.perma_mult
            return {
                message = localize("k_upgrade_ex"),
                colour = G.C.MULT
            }
        end
    end,
}
--Buffalo
SMODS.Joker {
    key = "buffalojoker",
    atlas = "puppyjokers",
    pos = { x = 2, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 1, xmult_gain = 0.1 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Buffalo",
        text = {
            "This Joker gains {X:mult,C:white}X#2#{} Mult for",
            "each card {C:attention}discarded{}, resets",
            "at end of round",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain }}
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            return {
                message = localize {
                    type = "variable",
                    key = "a_xmult",
                    vars = {card.ability.extra.xmult_gain}
                }
            }
        end

        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end

        if context.end_of_round and context.main_eval and not context.blueprint and not context.game_over then
            card.ability.extra.xmult = 1
            return {
                message = localize("k_reset")
            }
        end
    end,
}
--Llama
SMODS.Joker {
    key = "llamajoker",
    atlas = "puppyjokers",
    pos = { x = 3, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { repetitions = 1 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Llama",
        text = {
            "If played hand contains",
            "exactly {C:attention}four{} cards,",
            "retrigger the first three",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.repetitions }}
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and #context.full_hand == 4 and context.other_card ~= context.full_hand[4] then
            return {
                repetitions = card.ability.extra.repetitions
            }
        end
    end,
}
--Caterpillar
SMODS.Joker {
    key = "caterpillarjoker",
    atlas = "puppyjokers",
    pos = { x = 4, y = 3 },
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = false,
    cost = 5,
    discovered = true,
    config = { extra = { caterpillar_rounds = 2, rounds_played = 0 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Caterpillar",
        text = {
            "After {C:attention}#1#{} rounds,",
            "this Joker is destroyed to",
            "create a {C:attention}Rare{} Joker",
            "{C:inactive}(Currently #2#/#1#){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.caterpillar_rounds, card.ability.extra.rounds_played }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.game_over and not context.blueprint then
            card.ability.extra.rounds_played = card.ability.extra.rounds_played + 1
            if card.ability.extra.rounds_played == card.ability.extra.caterpillar_rounds then
                SMODS.destroy_cards(card, nil, nil, true)
                SMODS.add_card {
                    set = "Joker",
                    rarity = 3
                }
                return {
                    message = localize("k_sapjokers_transformed")
                }
            else
                return {
                    message = card.ability.extra.rounds_played .. "/" .. card.ability.extra.caterpillar_rounds 
                }
            end
        end
    end,
}
--Doberman
SMODS.Joker {
    key = "dobermanjoker",
    atlas = "puppyjokers",
    pos = { x = 5, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { xmult = 1.5 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Doberman",
        text = {
            "If you own no {C:attention}Rare{}",
            "{C:attention}Jokers,{} played cards give",
            "{X:mult,C:white}X#1#{} Mult when scored",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local rare_check = true
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].config.center.rarity == 3 then
                    rare_check = false
                end
            end

            if rare_check == true then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end,
}
--Tahr
SMODS.Joker {
    key = "tahrjoker",
    atlas = "puppyjokers",
    pos = { x = 6, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = {},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Tahr",
        text = {
            "If played hand is a",
            "{C:attention}Straight Flush{}, give {C:dark_edition}Foil",
            "{C:dark_edition}Holographic{} or {C:dark_edition}Polychrome{} edition",
            "to a random {C:attention}Joker",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_foil
        info_queue[#info_queue+1] = G.P_CENTERS.e_holo
        info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
    end,

    calculate = function(self, card, context)
        if context.after and next(context.poker_hands["Straight Flush"]) then
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.4,
                func = function()
                    local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
                    local edition_card = pseudorandom_element(editionless_jokers, "j_sapjokers_tahrjoker")
                    local edition = poll_edition ("j_sapjokers_tahrjoker", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
                    edition_card:set_edition(edition, true)
                    play_sound("tarot2", 1, 0.4)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end,
}
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
    atlas = "puppyjokers",
    pos = { x = 7, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = {},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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
        if context.given_edition and not context.blueprint and (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then
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
SMODS.Joker {
    key = "chameleonjoker",
    atlas = "puppyjokers",
    pos = { x = 8, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { balloon_dollars = 5, radio_chips = 25, ovenmitts_levels = 3,
                         cashregister_sell_increase = 3, default_mult = 15 }},
    pools = {puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Chameleon",
        text = {
            "Copies the ability of",
            "the current {C:attention}Toy,",
            "or gives {C:mult}+#5#{} Mult",
            "{C:inactive}(Copies the leftmost if",
            "{C:inactive}there are multiple)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.balloon_dollars, card.ability.extra.radio_chips, card.ability.extra.ovenmitts_levels,
                          card.ability.extra.cashregister_sell_increase, card.ability.extra.default_mult }}
    end,
    calculate = function(self, card, context)
        if context.toy_repetition then
            SMODS.calculate_context({chameleon_repeat = true, card = {card}})
        end

        if context.activate_balloon then
            return {
                dollars = card.ability.extra.balloon_dollars
            }
        end
        
        if context.activate_radio then
            pseudoshuffle(G.playing_cards)
            for i = 1, 5 do
                G.playing_cards[i].ability.perma_bonus = G.playing_cards[i].ability.perma_bonus + card.ability.extra.radio_chips
                return {
                    message = localize("k_again_ex")
                }
            end
        end

        if context.activate_melon_helmet then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
                    local edition_card = pseudorandom_element(editionless_jokers, "c_sapjokers_melonhelmet")
                    local edition = poll_edition ("c_sapjokers_melonhelmet", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
                    if edition_card ~= nil then
                        edition_card:set_edition(edition, true)
                    end

                    local editionless_cards = SMODS.Edition:get_edition_cards(G.deck, true)
                    local other_edition_card = pseudorandom_element(editionless_cards, "c_sapjokers_melonhelmet")
                    local other_edition = poll_edition ("c_sapjokers_melonhelmet", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
                    if other_edition_card ~= nil then
                        other_edition_card:set_edition(other_edition, true)
                    end
                    return true
                end)
            }))
            return {
                message = localize("k_again_ex")
            }
        end

        if context.activate_oven_mitts then
            local _hand, _played = "High Card", -1
            for hand_key, hand in pairs(G.GAME.hands) do
                if hand.played > _played then
                    _played = hand.played
                    _hand = hand_key
                end
            end
            local most_played = _hand
            SMODS.smart_level_up_hand(card, most_played, false, card.ability.extra.ovenmitts_levels)
        end

        if context.activate_cash_register then
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i].sell_cost = G.jokers.cards[i].sell_cost + card.ability.extra.cashregister_sell_increase
            end
            return {
                message = localize("k_again_ex")
            }
        end

        if context.activate_flashlight then
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
                return {
                    message = localize("k_again_ex")
                }
            end
        end

        if context.activate_tv then
            G.E_MANAGER:add_event(Event({
                trigger = "before",
                delay = 0.0,
                func = (function()
                    for i = 1, #G.jokers.cards do
                        if G.jokers.cards[i].edition and G.jokers.cards[i].edition.key == "e_foil" then
                            G.jokers.cards[i]:set_edition("e_holo")
                        elseif G.jokers.cards[i].edition and G.jokers.cards[i].edition.key == "e_holo" then
                            G.jokers.cards[i]:set_edition("e_polychrome")
                        end
                    end
                    for _, playing_card in ipairs(G.playing_cards) do
                        if playing_card.edition and playing_card.edition.key == "e_foil" then
                            playing_card:set_edition("e_holo")
                        elseif playing_card.edition and playing_card.edition.key == "e_holo" then
                            playing_card:set_edition("e_polychrome")
                        end
                    end
                return true
            end)}))
            return {
                message = localize("k_again_ex")
            }
        end

        if context.joker_main and #SuperAutoJokers.toy_card_area.cards == 0 then
            return {
                mult = card.ability.extra.default_mult
            }
        end
    end,
}
--Puppy
SMODS.Joker {
    key = "puppyjoker",
    atlas = "puppyjokers",
    pos = { x = 9, y = 3 },
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 6,
    discovered = true,
    config = {},
    pools = {sell = true, puppyjokers = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Puppy",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 4 {C:attention}Toy",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_ovenmitts
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_toiletpaper
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_cashregister
        return {
        }
    end,

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
SMODS.Joker {
    key = "stonefishjoker",
    atlas = "puppyjokers",
    pos = { x = 0, y = 4 },
    rarity = 3,
    blueprint_compat = false,
    cost = 6,
    discovered = true,
    config = { extra = { rounds = 0, xmult = 2, total_rounds = 4 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Stonefish",
        text = {
            "{C:attention}Halves{} all blind",
            "requirements and gives",
            "{C:white,X:mult}X#2#{} Mult, debuffed",
            "in {C:attention}#3#{} rounds",
            "{C:inactive}(Currently #1#/#3#){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds, card.ability.extra.xmult, card.ability.extra.total_rounds }}
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            G.GAME.blind.chips = G.GAME.blind.chips / 2
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            return {
                message = localize("k_sapjokers_score_reduced")
            }
        end

        if context.joker_main then
            return {
                xmult = card.ability.extra.xmult
            }
        end

        if context.end_of_round and not context.blueprint and context.main_eval and not context.game_over then
            card.ability.extra.rounds = card.ability.extra.rounds + 1
            if card.ability.extra.rounds == card.ability.extra.total_rounds then
                SMODS.debuff_card(card, true, "j_sapjokers_stonefishjoker_undebuff")
                return {
                    message = localize("k_sapjokers_debuffed"),
                    colour = G.C.MULT
                }
            else
                return {
                    message = card.ability.extra.rounds .. "/" .. card.ability.extra.total_rounds 
                }
            end
        end
    end,
}
--Goat
SMODS.Joker {
    key = "goatjoker",
    atlas = "puppyjokers",
    pos = { x = 1, y = 4 },
    rarity = 3,
    blueprint_compat = false,
    cost = 7,
    discovered = true,
    config = { extra = { free_cards = 5 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Goat",
        text = {
            "The next {C:attention}#1#{} shop",
            "purchases give their",
            "money back",
            "{C:inactive}(Debuffed when this reaches zero)"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.free_cards }}
    end,

    calculate = function(self, card, context)
        if context.buying_card and not context.buying_self and context.card ~= card then
            card.ability.extra.free_cards = card.ability.extra.free_cards - 1
            if card.ability.extra.free_cards == 0 then
                SMODS.debuff_card(card, true, "sapjokers_goatjoker_undebuff")
                return {
                    dollars = context.card.cost,
                    message = localize("k_sapjokers_debuffed")
                }
            else
                return {
                    dollars = context.card.cost
                }
            end
        end

        if context.open_booster then
            card.ability.extra.free_cards = card.ability.extra.free_cards - 1
            if card.ability.extra.free_cards == 0 then
                SMODS.debuff_card(card, true, "sapjokers_goatjoker_undebuff")
                return {
                    dollars = SMODS.OPENED_BOOSTER.cost,
                    message = localize("k_sapjokers_debuffed")
                }
            else
                return {
                    dollars = SMODS.OPENED_BOOSTER.cost
                }
            end
        end
    end,
}
--Chicken
SMODS.Joker {
    key = "chickenjoker",
    atlas = "puppyjokers",
    pos = { x = 2, y = 4 },
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { xmult = 1, xmult_gain = 0.3, xmult_hyperscale = 0.1 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Chicken",
        text = {
            "When a {C:attention}voucher{} is redeemed,",
            "this Joker gains {C:white,X:mult}X#2#{} Mult",
            "and this number is",
            "increased by {C:attention}#3#",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain, card.ability.extra.xmult_hyperscale }}
    end,

    calculate = function(self, card, context)
        if context.buying_card and context.card.ability.set == "Voucher" then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
            card.ability.extra.xmult_gain = card.ability.extra.xmult_gain + card.ability.extra.xmult_hyperscale
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
--Orchid Mantis
SMODS.Joker {
    key = "orchidmantisjoker",
    atlas = "puppyjokers",
    pos = { x = 3, y = 4 },
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = {},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Orchid Mantis",
        text = {
            "When a {C:attention}Booster Pack{} is",
            "opened, destroy a random",
            "{C:attention}Joker{} and create a random",
            "{C:spectral}Spectral{} card",
            "{C:inactive}(Must have room){}",
        }
    },

    calculate = function(self, card, context)
        if context.open_booster then
            local destroy_targets = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card and not SMODS.is_eternal(G.jokers.cards[i], card) and not G.jokers.cards[i].getting_sliced then
                    destroy_targets[#destroy_targets + 1] = G.jokers.cards[i]
                end
            end
            local to_destroy = pseudorandom_element(destroy_targets, "j_sapjokers_orchidmantisjoker")
            if to_destroy ~= nil then
                to_destroy.getting_sliced = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        (context.blueprint_card or card):juice_up(0.8, 0.8)
                        to_destroy:start_dissolve({ G.C.ORCHIDMANTIS_PINK }, nil, 1.6)
                        return true
                    end
                }))
            end

            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        SMODS.add_card {
                            set = "Spectral"
                        }
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                }))
                return {
                    message = localize("k_plus_spectral")
                }
            end
        end
    end,
}
--Eagle
SMODS.Joker {
    key = "eaglejoker",
    atlas = "puppyjokers",
    pos = { x = 4, y = 4 },
    rarity = 3,
    blueprint_compat = false,
    cost = 6,
    discovered = true,
    config = { extra = { hand_size_mod = 5, card_discards = 2 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Eagle",
        text = {
            "{C:attention}+#1#{} hand size,",
            "discard {C:attention}#2#{} random cards when",
            "hand is played"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hand_size_mod, card.ability.extra.card_discards }}
    end,

    calculate = function(self, card, context)
        if context.press_play then
            --Basically just the Hook boss blind
            G.E_MANAGER:add_event(Event({
                func = function()
                    local any_selected = nil
                    local _cards = {}
                    for _, playing_card in ipairs(G.hand.cards) do
                        _cards[#_cards + 1] = playing_card
                    end
                    for i = 1, card.ability.extra.card_discards do
                        if G.hand.cards[i] then
                            local selected_card, card_index = pseudorandom_element(_cards, "j_sapjokers_eaglejoker")
                            for i = 1, #G.hand.highlighted do
                                if G.hand.highlighted[i] == selected_card then
                                    G.hand:remove_from_highlighted(G.hand.highlighted[i], true)
                                    break
                                end
                            end
                            G.hand:add_to_highlighted(selected_card, true)
                            table.remove(_cards, card_index)
                            any_selected = true
                            play_sound('card1', 1)
                        end
                    end
                    if any_selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
                    return true
                end
            }))
            delay(0.7)
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = (function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.06 * G.SETTINGS.GAMESPEED,
                        blockable = false,
                        blocking = false,
                        func = function()
                            play_sound('tarot2', 0.76, 0.4); return true
                        end
                    }))
                    play_sound('tarot2', 1, 0.4)
                    return true
                end)
            }))
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.hand_size_mod)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.hand_size_mod)
    end,
}
--Panther
SMODS.Joker {
    key = "pantherjoker",
    atlas = "puppyjokers",
    pos = { x = 5, y = 4 },
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { chips = 50, mult = 10, xmult = 1.5 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Panther",
        text = {
            "Editions on Jokers",
            "trigger two",
            "additional times",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult, card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.other_joker and context.other_joker.edition ~= nil then
            if context.other_joker.edition.key == "e_foil" then
                return {
                    chips = card.ability.extra.chips,
                    message_card = other_card
                }
            end
            if context.other_joker.edition.key == "e_holo" then
                return {
                    mult = card.ability.extra.mult,
                    message_card = other_card
                }
            end
            if context.other_joker.edition.key == "e_polychrome" then
                return {
                    xmult = card.ability.extra.xmult,
                    message_card = other_card
                }
            end
        end

        if context.retrigger_joker_check and context.other_card == card then
            return {
                repetitions = 1
            }
        end
    end,
}

--Axolotl
SMODS.Joker {
    key = "axolotljoker",
    atlas = "puppyjokers",
    pos = { x = 6, y = 4 },
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 3 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Axolotl",
        text = {
            "{X:mult,C:white}X#1#{} Mult if you",
            "own at least one",
            "{C:attention}Debuffed{} Joker"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local debuff_check = false
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].debuff then
                    debuff_check = true
                    break
                end
            end

            if debuff_check == true then
                return {
                    xmult = card.ability.extra.xmult
                }
            end
        end
    end,
}
--Snapping Turtle
SMODS.Joker {
    key = "snappingturtlejoker",
    atlas = "puppyjokers",
    pos = { x = 7, y = 4 },
    rarity = 3,
    blueprint_compat = false,
    cost = 6,
    discovered = true,
    config = {},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Snapping Turtle",
        text = {
            "When {C:attention}Blind{} is selected,",
            "replace all {C:attention}Debuffs{} on",
            "Jokers with random {C:dark_edition}Editions"
        }
    },

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].debuff then
                    SMODS.debuff_card(G.jokers.cards[i], "prevent_debuff", "j_sapjokers_snappingturtlejoker")
                    SMODS.debuff_card(G.jokers.cards[i], "reset", "sapjokers_ignorecontext")
                    local edition = poll_edition ("j_sapjokesr+snappingturtlejoker", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
                    G.jokers.cards[i]:set_edition(edition, true)
                end
            end
        end
    end,
}
--Mosasaurus
SMODS.Joker {
    key = "mosasaurusjoker",
    atlas = "puppyjokers",
    pos = { x = 8, y = 4 },
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = {},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Mosasaurus",
        text = {
            "When a {C:attention}Toy{} is",
            "destroyed, gain a new",
            "copy of it"
        }
    },

    calculate = function(self, card, context)
        if context.toy_destroyed and (#SuperAutoJokers.toy_card_area.cards + G.GAME.consumeable_buffer - 2 < SuperAutoJokers.toy_card_area.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    SMODS.add_card ({
                        key = context.card_name,
                        area = SuperAutoJokers.toy_card_area
                    })
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
        end
    end,
}
--Stingray
SMODS.Joker {
    key = "stingrayjoker",
    atlas = "puppyjokers",
    pos = { x = 9, y = 4 },
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 7,
    discovered = true,
    config = {},
    pools = {sell = true, puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Sting Ray",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 5 {C:attention}Toy",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_flashlight
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_stinkysock
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_camera
        return {
        }
    end,

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
--Dragon
SMODS.Joker {
    key = "dragon2joker",
    atlas = "puppyjokers",
    pos = { x = 0, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    cost = 7,
    discovered = true,
    config = { extra = { reroll_count = 0, rerolls_needed = 2 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Dragon",
        text = {
            "After {C:attention}#2#{} Shop Rerolls,",
            "Give a random {C:attention}Joker{} or {C:attention}playing{}",
            "{C:attention}card{} a random {C:dark_edition}Edition",
            "{C:inactive}(Currently #1#/#2#)",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.reroll_count, card.ability.extra.rerolls_needed }}
    end,

    calculate = function(self, card, context)
        if context.reroll_shop then
            if not context.blueprint then
                if card.ability.extra.reroll_count == card.ability.extra.rerolls_needed then
                    card.ability.extra.reroll_count = 0
                end
                card.ability.extra.reroll_count = card.ability.extra.reroll_count + 1
            end
            if card.ability.extra.reroll_count == card.ability.extra.rerolls_needed then
                local areas = {G.jokers, G.deck}
                for k, v in pairs(areas) do
                    local editionless_cards = SMODS.Edition:get_edition_cards(v, true)
                    if #editionless_cards == 0 then
                        table.remove(areas, k)
                    end
                end

                if #areas ~= 0 then
                    local chosen_area = pseudorandom_element(areas, "j_sapjokers_dragon2joker")
                    local editionless_cards = SMODS.Edition:get_edition_cards(chosen_area, true)
                    local edition_card = pseudorandom_element(editionless_cards, "j_sapjokers_dragon2joker")
                    local edition = poll_edition ("j_sapjokers_dragon2joker", 1, true, true, {"e_polychrome", "e_holo", "e_foil"})
                    if edition_card ~= nil then
                        edition_card:set_edition(edition, true)
                    else
                        return {
                            message = localize("k_sapjokers_no_targets")
                        }
                    end
                else
                    return {
                        message = localize("k_sapjokers_no_targets")
                    }
                end 
            else
                return {
                    message = card.ability.extra.reroll_count .. "/" .. card.ability.extra.rerolls_needed,
                    colour = G.C.IMPORTANT
                }
            end
        end
    end,
}
--Mantis Shrimp
SMODS.Joker {
    key = "mantisshrimpjoker",
    atlas = "puppyjokers",
    pos = { x = 1, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    config = { extra = { xmult = 4 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Mantis Shrimp",
        text = {
            "{X:mult,C:white}X#1#{} Mult on {C:attention}first{}",
            "{C:attention}hand{} of round"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_played == 0 then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}
--Lionfish
SMODS.Joker {
    key = "lionfishjoker",
    atlas = "puppyjokers",
    pos = { x = 2, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    cost = 6,
    discovered = true,
    config = { extra = { xmult = 1, xmult_gain = 0.3 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Lionfish",
        text = {
            "This Joker gains {X:mult,C:white}X#2#{} Mult",
            "when a Joker is {C:attention}Debuffed{}",
            "or has its debuff {C:attention}removed{}",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain }}
    end,

    calculate = function(self, card, context)
        if context.joker_debuffed or context.joker_undebuffed then
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
    end,
}
--Tyrannosaurus
SMODS.Joker {
    key = "tyrannosaurusjoker",
    atlas = "puppyjokers",
    pos = { x = 3, y = 5 },
    rarity = 3,
    blueprint_compat = false,
    cost = 7,
    discovered = true,
    config = { extra = { end_of_round_payout = 12 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
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
SMODS.Joker {
    key = "octopusjoker",
    atlas = "puppyjokers",
    pos = { x = 4, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    cost = 8,
    discovered = true,
    config = { extra = { xmult = 1, xmult_per_card = 0.08, count = 0 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Octopus",
        text = {
            "This Joker has {X:mult,C:white}X#2#{} Mult for",
            "each {C:attention}Enhancement{}, {C:attention}Edition{} or {C:attention}Seal{}",
            "in full deck",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult){}",
        }
    },

    loc_vars = function(self, info_queue, card)
        calc_octopus_xmult = function()
            card.ability.extra.count = 0
            if G.playing_cards then
                for _, playing_card in pairs(G.playing_cards) do
                    if next(SMODS.get_enhancements(playing_card)) then
                        card.ability.extra.count = card.ability.extra.count + 1
                    end

                    if playing_card.seal then
                        card.ability.extra.count = card.ability.extra.count + 1
                    end

                    if playing_card.edition then
                        card.ability.extra.count = card.ability.extra.count + 1
                    end
                end
                return card.ability.extra.count
            else
                return 0
            end
        end

        local count = calc_octopus_xmult()
        return { vars = { card.ability.extra.xmult + card.ability.extra.xmult_per_card * count, card.ability.extra.xmult_per_card}}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local count = calc_octopus_xmult()
            return {
                xmult = card.ability.extra.xmult + card.ability.extra.xmult_per_card * count
            }
        end
    end,
}
--Anglerfish
SMODS.Joker {
    key = "anglerfishjoker",
    atlas = "puppyjokers",
    pos = { x = 5, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 7,
    discovered = true,
    config = {},
    pools = {sell = true, puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Anglerfish",
        text = {
            "When sold, create a random",
            "{C:attention}Rare{} Joker from a",
            "pack other than this one"
        }
    },

    calculate = function(self, card, context)
        if context.selling_self then
            if #G.jokers.cards + G.GAME.joker_buffer - 1 < G.jokers.config.card_limit then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        SMODS.add_card {
                            set = pseudorandom_element({"turtlejokers_rare"}, "j_sapjokers_anglerfishjoker")
                        }
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
                return {
                    message = localize("k_plus_joker")
                }
            end
        end
    end,
}
--Sauropod
SMODS.Joker {
    key = "sauropodjoker",
    atlas = "puppyjokers",
    pos = { x = 6, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    cost = 8,
    discovered = true,
    config = { extra = { xmult = 1.75 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Sauropod",
        text = {
            "Played cards with an",
            "{C:dark_edition}Edition{} give {X:mult,C:white}X#1#{} Mult",
            "when scored",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult }}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card.edition then
            return {
                xmult = card.ability.extra.xmult
            }
        end
    end,
}
--Elephant Seal
SMODS.Joker {
    key = "elephantsealjoker",
    atlas = "puppyjokers",
    pos = { x = 7, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 8,
    discovered = true,
    config = { extra = { xmult = 5, xmult_loss = 0.5 }},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Elephant Seal",
        text = {
            "{X:mult,C:white}X#1#{} Mult, -{X:mult,C:white}X#2#{} Mult",
            "when a {C:attention}consumable{} card",
            "is used",
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_loss }}
    end,

    calculate = function(self, card, context)
        if context.using_consumeable then
            card.ability.extra.xmult = card.ability.extra.xmult - card.ability.extra.xmult_loss
            if card.ability.extra.xmult <= 1 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize("k_sapjokers_destroyed")
                }
            else
                return {
                    message = localize {
                        type = "variable",
                        key = "a_xmult_minus",
                        vars = {card.ability.extra.xmult_loss}
                    }
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
--Puma

SMODS.Joker {
    key = "pumajoker",
    atlas = "puppyjokers",
    pos = { x = 8, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    cost = 9,
    discovered = true,
    config = {},
    pools = {puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Puma",
        text = {
            "If you have a {C:attention}Toy{},",
            "copies the abilities of",
            "adjacent Jokers",
            "{C:inactive}(Must be compatible){}",
        }
    },
    calculate = function(self, card, context)
        if #SuperAutoJokers.toy_card_area.cards > 0 then
            local index
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    index = i
                    break
                end
            end

            local left = SMODS.blueprint_effect(card, G.jokers.cards[index - 1], context)
            local right = SMODS.blueprint_effect(card, G.jokers.cards[index + 1], context)
            return SMODS.merge_effects { left or {}, right or {} }
        end
    end,
}
--Mongoose
SMODS.Joker {
    key = "mongoosejoker",
    atlas = "puppyjokers",
    pos = { x = 9, y = 5 },
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = false,
    cost = 8,
    discovered = true,
    config = {},
    pools = {sell = true, puppyjokers = true, puppyjokers_rare = true},
    in_pool = function(self)
        return SuperAutoJokers.config["puppy_pack"]
    end,
    loc_txt = {
        name = "Mongoose",
        text = {
            "Sell this joker to",
            "gain a random",
            "tier 6 {C:attention}Toy",
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_tv
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_peanutjar
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sapjokers_airpalmtree
        return {
        }
    end,

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