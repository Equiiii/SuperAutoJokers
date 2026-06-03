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
        local text, _, _ = JokerDisplay.evaluate_hand(hand)
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
                if not SMODS.has_any_suit(hand[_]) then
                    if hand[_]:is_suit('Hearts', true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif hand[_]:is_suit('Diamonds', true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif hand[_]:is_suit('Spades', true) and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif hand[_]:is_suit('Clubs', true) and suits["Clubs"] == 0 then
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