-- Robo House - main.lua
-- 2020 Foppygames

local aspect = require("modules.aspect")
local entities = require("modules.entities")
local floors = require("modules.floors")
local utils = require("modules.utils")

local BACKGROUND_COLOR = utils.getColorFromRgb(0,135,81)
local STATE_TITLE = 1
local STATE_ACTION = 2
local STATE_GAME_OVER = 3

local state

--[[ Todo:
- LATER: title screen, next level screen, game over screen
- player can walk (arrow keys left and right)
- there are ladders
- player can climb ladders (arrow keys up and down while on a ladder)
- player can jump (space bar OR: z?)
- robots can walk
- robots can go bad
- LATER: cats can walk
- LATER: player can pick up and drop cats (arrow keys up and down while not on a ladder OR: x?)
- robots can break down and go evil
- LATER: evil robots can hurt cats
- evil robots can hurt player
- LATER: spikes on floors can hurt player
- player can repair robots by jumping over them
- hurting means losing a life
- losing a life but lives remaining means reset level
- losing a life and none remaining means game over
- keep track of time of day
- reaching end of day means next level
- sound
- music
- gamepad controls
]]

function love.load()
    aspect.init(false)
    love.graphics.setBackgroundColor(BACKGROUND_COLOR)
    switchToState(STATE_ACTION)
end

function switchToState(new)
    if state == STATE_ACTION then
        entities.reset()
    end
    state = new
    if state == STATE_ACTION then
        entities.add(entities.TYPE_PLAYER,1,0.1)
    end
end

function love.update(dt)
    entities.update(dt)
end

function love.keypressed(key)
    if state == STATE_ACTION then
        if key == "escape" then
            love.event.quit()
        elseif key == "space" then
            entities.setInput("jump")
        end

    end
end

function love.draw()
    aspect.apply()
    love.graphics.clear(BACKGROUND_COLOR)
    floors.draw()
    entities.draw()
    aspect.letterbox()
end