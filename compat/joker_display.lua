local jd_def = JokerDisplay.Definitions




jd_def["j_sapjokers_duckjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active" },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.is_active = card.ability.extra.duck_rounds >= card.ability.extra.total_rounds
        card.joker_display_values.active = card.joker_display_values.is_active and 
            localize("jdis_active") or (card.ability.extra.duck_rounds .. "/" .. card.ability.extra.total_rounds)
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour = card.joker_display_values.is_active and G.C.GREEN or
                G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_sapjokers_beaverjoker"] = {

}

jd_def["j_sapjokers_pigeonjoker"] = {

}

jd_def["j_sapjokers_otterjoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        local dollars = 0
        local hand = G.hand.highlighted
        for _, playing_card in pairs(hand) do
            if playing_card.facing and not (playing_card.facing == "back") and not playing_card.debuff and SMODS.has_enhancement(playing_card, "m_gold") then
                dollars = dollars + card.ability.extra.dollars
            end
        end
        card.joker_display_values.dollars = G.GAME.current_round.discards_left > 0 and dollars or 0
    end
}

jd_def["j_sapjokers_pigjoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "sell_cost", retrigger_type = "mult"},
    },
    text_config = { colour = G.C.GOLD },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:get_id() and scoring_card:get_id() == 4 then
                    count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end
        card.joker_display_values.sell_cost = count
        local numerator, denominator = 1, card.ability.extra.odds
        if SMODS then numerator, denominator = SMODS.get_probability_vars(card, numerator, denominator, 'j_sapjokers_pigjoker') end
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_sapjokers_antjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        card.joker_display_values.mult = card.ability.extra.mult * #G.consumeables.cards
    end
}

jd_def["j_sapjokers_mosquitojoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
            end
        end
        card.joker_display_values.mult = count * card.ability.extra.mult
    end
}

jd_def["j_sapjokers_fishjoker"] = {
    text = {
        { text = "+1" },
    },
    text_config = { colour = G.C.SECONDARY_SET.Tarot },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "sell_count" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "fish_sells" },
        { text = ")" },
    },
    reminder_text_config = { scale = 0.35 }
}

jd_def["j_sapjokers_cricketjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "draw_cards" },
    }
}

jd_def["j_sapjokers_horsejoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        local hand = G.hand.highlighted
        local text, _, _ = JokerDisplay.evaluate_hand(hand)
        local play_more_than = 0
        local hand_exists = text ~= "Unknown" and G.GAME.hands and G.GAME.hands[text]
        local _hand, _played
        if hand_exists then
            for _, poker_hand in pairs(G.GAME.hands) do
                if poker_hand.played and poker_hand.played >= play_more_than and poker_hand.visible then
                    play_more_than = poker_hand.played
                end
            end

            if G.GAME.hands[text].played >= play_more_than then
                card.joker_display_values.chips = 0
            else
                card.joker_display_values.chips = card.ability.extra.chips
            end
        else
            card.joker_display_values.chips = card.ability.extra.chips
        end
    end
}

jd_def["j_sapjokers_snailjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
}

jd_def["j_sapjokers_crabjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_swanjoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        card.joker_display_values.dollars = card.ability.extra.dollars * (G.jokers and #G.jokers.cards or 0)
    end
}

jd_def["j_sapjokers_ratjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_hedgehogjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local hmult = 0
        local hand = G.hand.highlighted
        local text, _, _ = JokerDisplay.evaluate_hand(hand)
        local hand_exists = text ~= "Unknown" and G.GAME.hands and G.GAME.hands[text]
        if hand_exists then
            for _, playing_card in pairs(hand) do
                if not next(SMODS.get_enhancements(playing_card)) then
                    hmult = hmult + playing_card:get_chip_bonus()
                end
            end
            card.joker_display_values.mult = math.floor(hmult/2)
        else
            card.joker_display_values.mult = 0
        end
    end
}

jd_def["j_sapjokers_peacockjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card:get_id() == 2 or 
                scoring_card:get_id() == 3 or 
                scoring_card:get_id() == 5 or 
                scoring_card:get_id() == 7 or 
                scoring_card:get_id() == 11 then
                    count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end
        card.joker_display_values.chips = count * card.ability.extra.chips
    end
}

jd_def["j_sapjokers_flamingojoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local hand = G.hand.highlighted
        local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
        local hand_exists = text ~= "Unknown" and G.GAME.hands and G.GAME.hands[text]
        local two_suits = true
        local suits = {
            ["Hearts"] = 0,
            ["Diamonds"] = 0,
            ["Clubs"] = 0,
            ["Spades"] = 0,
        }

        if hand_exists then
            for _, card in pairs(hand) do
                if not SMODS.has_any_suit(scoring_hand[_]) then
                    if scoring_hand[_]:is_suit('Hearts', true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif scoring_hand[_]:is_suit('Diamonds', true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif scoring_hand[_]:is_suit('Spades', true) and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif scoring_hand[_]:is_suit('Clubs', true) and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            if suits["Hearts"] + suits["Diamonds"] + suits["Clubs"] + suits["Spades"] > 2 then
                two_suits = false
            end

            if two_suits == true then
                card.joker_display_values.mult = card.ability.extra.mult + 1
            else
                card.joker_display_values.mult = 0
            end
        else
            card.joker_display_values.mult = card.ability.extra.mult
        end
    end
}

jd_def["j_sapjokers_wormjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
}

jd_def["j_sapjokers_kangaroojoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        local playing_hand = next(G.play.cards)
        local count = 0
        for _, playing_card in ipairs(G.hand.cards) do
            if playing_hand or not playing_card.highlighted then
                if not (playing_card.facing == "back") and not playing_card.debuff then
                    count = count + (JokerDisplay.calculate_card_triggers(playing_card, nil, true) * playing_card:get_chip_bonus())
                end
            end
        end
        card.joker_display_values.chips = count
    end
}

jd_def["j_sapjokers_spiderjoker"] = {
    text = {
        { text = "???" },
    },
}

jd_def["j_sapjokers_dodojoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            }
        }
    },
}

jd_def["j_sapjokers_badgerjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active_text" },
        { text = ")" },
    },
    calc_function = function(card)
        local hand = G.hand.highlighted
        local text, _, _ = JokerDisplay.evaluate_hand(hand)
        local hand_exists = text ~= "Unknown" and G.GAME.hands and G.GAME.hands[text]

        if hand_exists and #hand == 2 and hand[1]:get_id() == hand[2]:get_id() and hand[1].base.suit == hand[2].base.suit then
            card.joker_display_values.is_active = true
        else
            card.joker_display_values.is_active = false
        end

        card.joker_display_values.active_text = localize("jdis_" .. (card.joker_display_values.is_active and "active" or "inactive"))
    end
}

jd_def["j_sapjokers_dolphinjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
        { text = ", " },
        { ref_table = "card.ability.extra", ref_value = "final_mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
            end
        end
        card.joker_display_values.mult = (count * card.ability.extra.scored_mult)
    end
}

jd_def["j_sapjokers_giraffejoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_elephantjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
            }
        }
    },
    calc_function = function(card)
        local playing_hand = next(G.play.cards)
        local count = 0
        for _, playing_card in ipairs(G.hand.cards) do
            if playing_hand or not playing_card.highlighted then
                if not (playing_card.facing == "back") and not playing_card.debuff and SMODS.has_enhancement(playing_card, "m_stone") then
                    count = count + (JokerDisplay.calculate_card_triggers(playing_card, nil, true))
                end
            end
        end
        card.joker_display_values.x_mult = card.ability.extra.xmult ^ count
    end
}

jd_def["j_sapjokers_cameljoker"] = {
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        local first_card = scoring_hand and JokerDisplay.calculate_leftmost_card(scoring_hand)
        local retriggers = math.max((#G.hand.highlighted - #scoring_hand - 1), 0)
        return first_card and playing_card == first_card and retriggers * JokerDisplay.calculate_joker_triggers(joker_card) or 0
    end
}

jd_def["j_sapjokers_rabbitjoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.ability.extra", ref_value = "sell_value" },
    },
    text_config = { colour = G.C.GOLD },
}

jd_def["j_sapjokers_oxjoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        card.joker_display_values.dollars = math.max((G.GAME.dollars * -1), 0)
    end
}

jd_def["j_sapjokers_dogjoker"] = {
}

jd_def["j_sapjokers_sheepjoker"] = {
}

jd_def["j_sapjokers_skunkjoker"] = {
}

jd_def["j_sapjokers_hippojoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "blind_increase", retrigger_type = "exp" },
            },
            border_colour = G.C.IMPORTANT
        }
    },
}

jd_def["j_sapjokers_bisonjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_blowfishjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            },
        }
    },
}

jd_def["j_sapjokers_turtlejoker"] = {
}

jd_def["j_sapjokers_squirreljoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        card.joker_display_values.dollars = card.ability.extra.dollars * ( G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.spectral or 0 )
    end
}

jd_def["j_sapjokers_penguinjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
    calc_function = function(card)
        card.joker_display_values.chips = card.ability.extra.chips * ( G.GAME.hands["Straight Flush"].played or 0 )
        local hand = G.hand.highlighted
        local text, _, _ = JokerDisplay.evaluate_hand(hand)
        local hand_exists = text ~= "Unknown" and G.GAME.hands and G.GAME.hands[text]
        if hand_exists and text == "Straight Flush" then
            card.joker_display_values.chips = card.ability.extra.chips * ( G.GAME.hands["Straight Flush"].played or 0 ) + card.ability.extra.chips
        end
    end
}

jd_def["j_sapjokers_deerjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "most_common_suit" },
        { text = ")" },
    },
    calc_function = function(card)
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
        card.joker_display_values.most_common_suit = localize(most_common_suit, "suits_plural")
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children[2] then
            reminder_text.children[2].config.colour = lighten(G.C.SUITS[card.joker_display_values.most_common_suit], 0.35)
        end
    end
}

jd_def["j_sapjokers_whalejoker"] = {
}

jd_def["j_sapjokers_parrotjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "blueprint_compat", colour = G.C.RED },
        { text = ")" }
    },
    calc_function = function(card)
        local copied_joker, copied_debuff = JokerDisplay.calculate_blueprint_copy(card)
        card.joker_display_values.blueprint_compat = localize('k_incompatible')
        JokerDisplay.copy_display(card, copied_joker, copied_debuff)
    end,
    get_blueprint_joker = function(card)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                return G.jokers.cards[i - 1]
            end
        end
        return nil
    end
}

jd_def["j_sapjokers_scorpionjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active_text" },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.active_text = card.is_active and localize("jdis_active") or localize("jdis_inactive")
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour = card.is_active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_sapjokers_crocjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
            }
        }
    },
    calc_function = function(card)
        if #G.jokers.cards < G.jokers.config.card_limit then
            card.joker_display_values.x_mult = card.ability.extra.xmult
        else
            card.joker_display_values.x_mult = 1
        end
    end
}

jd_def["j_sapjokers_rhinojoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
}

jd_def["j_sapjokers_monkeyjoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        local playing_hand = next(G.play.cards)
        local count = 0
        for _, playing_card in ipairs(G.hand.cards) do
            if playing_hand or not playing_card.highlighted then
                if not (playing_card.facing == "back") and not playing_card.debuff and SMODS.has_enhancement(playing_card, "m_lucky") then
                    count = count + (JokerDisplay.calculate_card_triggers(playing_card, nil, true) * card.ability.extra.dollars)
                end
            end
        end
        card.joker_display_values.dollars = count
    end
}

jd_def["j_sapjokers_armadillojoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_cowjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active" },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.is_active = card.ability.extra.cow_rounds >= card.ability.extra.total_rounds
        card.joker_display_values.active = card.joker_display_values.is_active and 
            localize("jdis_active") or (card.ability.extra.cow_rounds .. "/" .. card.ability.extra.total_rounds)
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour = card.joker_display_values.is_active and G.C.GREEN or
                G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_sapjokers_sealjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            }
        }
    },
}

jd_def["j_sapjokers_roosterjoker"] = {
}

jd_def["j_sapjokers_sharkjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
            }
        }
    },
    calc_function = function(card)
        if #G.playing_cards < 42 or #G.playing_cards > 67 then
            card.joker_display_values.x_mult = card.ability.extra.xmult
        else
            card.joker_display_values.x_mult = 1
        end
    end
}

jd_def["j_sapjokers_turkeyjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "sell_count" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "turkey_sells" },
        { text = ")" },
    },
    reminder_text_config = { scale = 0.35 }
}

jd_def["j_sapjokers_leopardjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "leopard_card", colour = G.C.FILTER },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.leopard_card = localize {
            type = "variable",
            key = "jdis_rank_of_suit",
            vars = {
                localize(G.GAME.current_round.sapjokers_leopard_card.rank, "ranks"),
                localize(G.GAME.current_round.sapjokers_leopard_card.suit, "suits_plural")
            }
        }
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children[2] then
            reminder_text.children[2].config.colour = lighten(G.C.SUITS[G.GAME.current_round.sapjokers_leopard_card.suit], 0.35)
        end
    end
}

jd_def["j_sapjokers_boarjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local hand = G.hand.highlighted
        local text, _, _ = JokerDisplay.evaluate_hand(hand)
        local hand_exists = text ~= "Unknown" and G.GAME.hands and G.GAME.hands[text]
        if hand_exists and #hand == 5 then
            card.joker_display_values.mult = (#G.hand.cards - #hand) * card.ability.extra.mult
        else
            card.joker_display_values.mult = 0
        end
    end
}

jd_def["j_sapjokers_tigerjoker"] = {
}

jd_def["j_sapjokers_wolverinejoker"] = {
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        local text, _, _ = JokerDisplay.evaluate_hand(hand)
        if text == "Straight Flush" then
            return JokerDisplay.in_scoring(playing_card, scoring_hand) and (2 * JokerDisplay.calculate_joker_triggers(joker_card))
        elseif (text == "Flush" or text == "Straight") then
            return JokerDisplay.in_scoring(playing_card, scoring_hand) and (1 * JokerDisplay.calculate_joker_triggers(joker_card))
        else
            return 0
        end
    end    
}

jd_def["j_sapjokers_gorillajoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
}

jd_def["j_sapjokers_dragonjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "reroll_count" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "dragon_rerolls" },
        { text = ")" },
    },
    reminder_text_config = { scale = 0.35 }
}

jd_def["j_sapjokers_mammothjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            }
        }
    },
}

jd_def["j_sapjokers_catjoker"] = {
}

jd_def["j_sapjokers_snakejoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
            end
        end

        if text == "Straight Flush" then
            card.joker_display_values.x_mult = (1 + ((G.GAME.hands["Straight Flush"].played + 1) * 0.05)) ^ count
        else
            card.joker_display_values.x_mult = (1 + (G.GAME.hands["Straight Flush"].played * 0.05)) ^ count
        end
    end
}

jd_def["j_sapjokers_flyjoker"] = {
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        if playing_card ~= scoring_hand[5] then
            return joker_card.ability.extra.repetitions * JokerDisplay.calculate_joker_triggers(joker_card) or 0
        else
            return 0
        end
    end
}

--PUPPY PACK

jd_def["j_sapjokers_duck2joker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active" },
        { text = ")" },
    },
    calc_function = function(card)
        card.joker_display_values.is_active = card.ability.extra.duck_rounds >= card.ability.extra.total_rounds
        card.joker_display_values.active = card.joker_display_values.is_active and 
            localize("jdis_active") or (card.ability.extra.duck_rounds .. "/" .. card.ability.extra.total_rounds)
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour = card.joker_display_values.is_active and G.C.GREEN or
                G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_sapjokers_beaver2joker"] = {
}

jd_def["j_sapjokers_mothjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local first_card = JokerDisplay.calculate_leftmost_card(scoring_hand)
        card.joker_display_values.mult = first_card and (card.ability.extra.mult * JokerDisplay.calculate_card_triggers(first_card, scoring_hand)) or 1
    end
}

jd_def["j_sapjokers_bluebirdjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "perma_mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_chinchillajoker"] = {
}

jd_def["j_sapjokers_beetlejoker"] = {
}

jd_def["j_sapjokers_ladybugjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "rounds" },
        { text = "/2)" },
    },
}

jd_def["j_sapjokers_chipmunkjoker"] = {
}

jd_def["j_sapjokers_geckojoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        if #SuperAutoJokers.toy_card_area.cards > 0 then
            card.joker_display_values.mult = card.ability.extra.mult
        else
            card.joker_display_values.mult = 0
        end
    end
}

jd_def["j_sapjokers_ferretjoker"] = {
}

jd_def["j_sapjokers_bilbyjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "tarot" },
    },
    text_config = { colour = G.C.SECONDARY_SET.Tarot },
    extra = {
        {
            { text = "(" },
            { ref_table = "card.joker_display_values", ref_value = "odds" },
            { text = ")" },
        }
    },
    extra_config = { colour = G.C.GREEN, scale = 0.3 },
    calc_function = function(card)
        card.joker_display_values.tarot = 1
        local numerator, denominator = 2, card.ability.extra.odds
        if SMODS then numerator, denominator = SMODS.get_probability_vars(card, numerator, denominator, 'j_sapjokers_bilbyjoker') end
        card.joker_display_values.odds = localize { type = 'variable', key = "jdis_odds", vars = { numerator, denominator } }
    end
}

jd_def["j_sapjokers_goldfishjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "current" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "count" },
        { text = ")" },
    },
}

jd_def["j_sapjokers_robinjoker"] = {
}

jd_def["j_sapjokers_batjoker"] = {
    text = {
        { ref_table = "card.ability.extra", ref_value = "mult" },
        { text = ", +$", colour = G.C.GOLD },
        { ref_table = "card.ability.extra", ref_value = "dollars", colour = G.C.GOLD },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_dromedaryjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local playing_hand = next(G.play.cards)
        local count = 0
        local first_three_check = 0
        for _, playing_card in ipairs(G.hand.cards) do
            if playing_hand or not playing_card.highlighted then
                if not (playing_card.facing == "back") and not playing_card.debuff and first_three_check < 3 then
                    count = count + (JokerDisplay.calculate_card_triggers(playing_card, nil, true) * card.ability.extra.mult * (#G.hand.cards - #G.hand.highlighted))
                    first_three_check = first_three_check + 1
                end
            end
        end
        card.joker_display_values.mult = count
    end
}

jd_def["j_sapjokers_shrimpjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
}

jd_def["j_sapjokers_belugasturgeonjoker"] = {
}

jd_def["j_sapjokers_tabbycatjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_mandrilljoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "mandrill_rounds" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "total_rounds" },
        { text = ")" },
    },
}

jd_def["j_sapjokers_lemurjoker"] = {
}

jd_def["j_sapjokers_toucanjoker"] = {
}

jd_def["j_sapjokers_harejoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "debuff_rounds" },
        { text = "/4)" },
    },
}

jd_def["j_sapjokers_hoopoebirdjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.SECONDARY_SET.Tarot },
    calc_function = function(card)
        card.joker_display_values.active = to_big(G.GAME.dollars) > to_big(24)
        card.joker_display_values.count = card.joker_display_values.active and 1 or 0
    end
}


jd_def["j_sapjokers_tropicalfishjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips" },
    },
    text_config = { colour = G.C.CHIPS },
}

jd_def["j_sapjokers_hatchingchickjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "hands" },
    },
    text_config = { colour = G.C.CHIPS },
}

jd_def["j_sapjokers_owljoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_molejoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
}

jd_def["j_sapjokers_flyingsquirreljoker"] = {
}

jd_def["j_sapjokers_pangolinjoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        card.joker_display_values.dollars = #SuperAutoJokers.toy_card_area.cards > 0 and card.ability.extra.dollars or 0
    end
}

jd_def["j_sapjokers_gharialjoker"] = {
}

jd_def["j_sapjokers_microbejoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.ability.extra", ref_value = "sell_cost_increase" },
    },
    text_config = { colour = G.C.GOLD },
}

jd_def["j_sapjokers_lobsterjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    calc_function = function(card)
        local playing_hand = next(G.play.cards)
        local count = 0
        for _, playing_card in ipairs(G.hand.cards) do
            if playing_hand or not playing_card.highlighted then
                if not (playing_card.facing == "back") and not playing_card.debuff then
                    count = count + (JokerDisplay.calculate_card_triggers(playing_card, nil, true))
                end
            end
        end
        card.joker_display_values.mult = count
    end
}

jd_def["j_sapjokers_buffalojoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            }
        }
    },
}

jd_def["j_sapjokers_llamajoker"] = {
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand then return 0 end
        local hand = G.hand.highlighted
        if #hand == 4 then
            local rightmost_card = JokerDisplay.calculate_rightmost_card(hand)
            local retriggers = joker_card.ability.extra.repetitions
            return rightmost_card and playing_card ~= rightmost_card and retriggers * JokerDisplay.calculate_joker_triggers(joker_card) or 0
        end
    end
}


jd_def["j_sapjokers_caterpillarjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "rounds_played" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "caterpillar_rounds" },
        { text = ")" },
    },
}

jd_def["j_sapjokers_dobermanjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
            end
        end
        local rare_check = true
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.rarity == 3 then
                rare_check = false
            end
        end

        if rare_check == true then
            card.joker_display_values.x_mult = card.ability.extra.xmult ^ count
        else
            card.joker_display_values.x_mult = 1
        end
    end
}

jd_def["j_sapjokers_tahrjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "count", retrigger_type = "mult" },
    },
    text_config = { colour = G.C.DARK_EDITION },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "localized_text", colour = G.C.ORANGE },
        { text = ")" },
    },
    calc_function = function(card)
        local text, _, _ = JokerDisplay.evaluate_hand()
        local is_straight_flush = text == "Straight Flush"

        card.joker_display_values.localized_text = localize("Straight Flush", "poker_hands")
        card.joker_display_values.count = is_straight_flush and 1 or 0
    end
}

jd_def["j_sapjokers_whalesharkjoker"] = {
}

jd_def["j_sapjokers_chameleonjoker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult" },
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(Copying " },
        { ref_table = "card.joker_display_values", ref_value = "toy_name", colour = G.C.IMPORTANT },
        { text = ")" },
    },
    calc_function = function(card)
        if #SuperAutoJokers.toy_card_area.cards > 0 then
            local copy_target = localize({type = "name_text", set = "toy", key = SuperAutoJokers.toy_card_area.cards[1].config.center.key})
            card.joker_display_values.toy_name = copy_target
            card.joker_display_values.mult = 0
        else
            card.joker_display_values.toy_name = "None"
            card.joker_display_values.mult = card.ability.extra.default_mult
        end
    end
}

jd_def["j_sapjokers_puppyjoker"] = {
}

jd_def["j_sapjokers_stonefishjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "rounds" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "total_rounds" },
        { text = ")" },
    }
}

jd_def["j_sapjokers_goatjoker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "free_cards", colour = G.C.IMPORTANT },
        { text = " Remaining)" },
    }
}

jd_def["j_sapjokers_chickenjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
        { text = ", +" },
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult_gain", retrigger_type = "exp" },
            },
        },
    },
}

jd_def["j_sapjokers_orchidmantisjoker"] = {
}

jd_def["j_sapjokers_eaglejoker"] = {
}

jd_def["j_sapjokers_pantherjoker"] = {
    text = {
        { text = "(+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
        { text = ", +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT },
        { text = ", " },
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "xmult", retrigger_type = "exp" },
            },
        },
        { text = ")" },
    },
    calc_function = function(card)
        local foil_count, holo_count, poly_count = 0, 0, 0
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].edition ~= nil then
                if G.jokers.cards[i].edition.key == "e_foil" then
                    foil_count = foil_count + 1
                elseif G.jokers.cards[i].edition.key == "e_holo" then
                    holo_count = holo_count + 1
                elseif G.jokers.cards[i].edition.key == "e_polychrome" then
                    poly_count = poly_count + 1
                end
            end
        end

        card.joker_display_values.chips = foil_count * card.ability.extra.chips * 2
        card.joker_display_values.mult = holo_count * card.ability.extra.mult * 2
        card.joker_display_values.xmult = poly_count > 0 and ((poly_count * 2) ^ card.ability.extra.xmult) or 1
    end
}

jd_def["j_sapjokers_axolotljoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
            },
        },
    },
    calc_function = function(card)
        local debuff_check = false
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].debuff then
                    debuff_check = true
                    break
                end
            end
        card.joker_display_values.x_mult = debuff_check == true and card.ability.extra.xmult or 1
    end
}

jd_def["j_sapjokers_snappingturtlejoker"] = {
}

jd_def["j_sapjokers_mosasaurusjoker"] = {
}

jd_def["j_sapjokers_stingrayjoker"] = {
}

jd_def["j_sapjokers_dragon2joker"] = {
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "reroll_count" },
        { text = "/" },
        { ref_table = "card.ability.extra", ref_value = "rerolls_needed" },
        { text = ")" },
    },
    reminder_text_config = { scale = 0.35 }
}

jd_def["j_sapjokers_mantisshrimpjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
            },
        },
    },
    calc_function = function(card)
        card.joker_display_values.x_mult = G.GAME.current_round.hands_played == 0 and card.ability.extra.xmult or 1
    end
}

jd_def["j_sapjokers_lionfishjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" },
            }
        }
    }
}

jd_def["j_sapjokers_tyrannosaurusjoker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" },
    },
    text_config = { colour = G.C.GOLD },
    calc_function = function(card)
        local has_other_rare = false
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.rarity == 3 and G.jokers.cards[i] ~= card then
                has_other_rare = true
            end
        end
        card.joker_display_values.dollars = has_other_rare and card.ability.extra.end_of_round_payout or 0
    end
}

jd_def["j_sapjokers_octopusjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" },
            }
        }
    },
    calc_function = function(card)
        local count = calc_octopus_xmult()
        card.joker_display_values.x_mult = card.ability.extra.xmult + card.ability.extra.xmult_per_card * count
    end
}

jd_def["j_sapjokers_anglerfishjoker"] = {
}

jd_def["j_sapjokers_sauropodjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= "Unknown" then
            for _, scoring_card in pairs(scoring_hand) do
                if scoring_card.edition then
                    count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                end
            end
        end

        card.joker_display_values.x_mult = card.ability.extra.xmult ^ count
    end
}

jd_def["j_sapjokers_elephantsealjoker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            }
        }
    }
}

jd_def["j_sapjokers_pumajoker"] = {
    text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "first_copy", colour = G.C.IMPORTANT },
        { text = " + " },
        { ref_table = "card.joker_display_values", ref_value = "second_copy", colour = G.C.IMPORTANT },
        { text = ")" },
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "active" },
        { text = ")" }
    },
    calc_function = function(card)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                if G.jokers.cards[i - 1] and G.jokers.cards[i - 1].config.center.blueprint_compat == false then
                    card.joker_display_values.first_copy = localize("k_incompatible")
                else
                    card.joker_display_values.first_copy = G.jokers.cards[i - 1] ~= nil and localize({type = "name_text", set = "Joker", key = G.jokers.cards[i - 1].config.center.key}) or "None"
                end

                if G.jokers.cards[i + 1] and G.jokers.cards[i + 1].config.center.blueprint_compat == false then
                    card.joker_display_values.second_copy = localize("k_incompatible")
                else
                    card.joker_display_values.second_copy = G.jokers.cards[i + 1] ~= nil and localize({type = "name_text", set = "Joker", key = G.jokers.cards[i + 1].config.center.key}) or "None"
                end
                break
            end
        end

        card.joker_display_values.active = #SuperAutoJokers.toy_card_area.cards > 0 and localize("jdis_active") or localize("jdis_inactive")
    end
}

jd_def["j_sapjokers_mongoosejoker"] = {
}