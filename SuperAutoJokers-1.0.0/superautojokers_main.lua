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
--Each scored 4 has a 1/3 chance to increase this card's sell value by one
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
            "to increase this joker's",
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
    cost = 5,
    discovered = true,
    config = {},
    loc_txt = {
        name = "Skunk",
        text = {
            "Sell this joker to",
            "reduce boss blind's score",
            "requirement by 66%",
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
--Snake
--Fly
