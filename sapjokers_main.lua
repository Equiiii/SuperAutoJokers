SuperAutoJokers = {}
SuperAutoJokers.config = SMODS.current_mod.config

assert(SMODS.load_file("content/turtlejokers.lua"))()
assert(SMODS.load_file("content/puppyjokers.lua"))()
assert(SMODS.load_file("content/hidden.lua"))()
assert(SMODS.load_file("settings.lua"))()

if JokerDisplay then
    assert(SMODS.load_file("compat/joker_display.lua"))()
end