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
--Rat
--Hedgehog
--Peacock
--Flamingo
--Worm
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
    config = { extra = {mult = 0,}},
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
--Seal
--Rooster
--Shark
--Turkey
--Leopard
--Boar
--Tiger
--Wolverine
--Gorilla
--Dragon
--Mammoth
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
--Fly
