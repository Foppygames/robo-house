-- Robo House - main.lua
-- 2020 Foppygames

local aspect = require("modules.aspect")
local entities = require("modules.entities")
local floors = require("modules.floors")
local images = require("modules.images")
local ladders = require("modules.ladders")
local utils = require("modules.utils")

local GAME_TITLE = "Robo House"
local BACKGROUND_COLOR = utils.getColorFromRgb(0,0,0)
local LIVES = 3

local STATE_TITLE = 1
local STATE_ACTION = 2
local STATE_GAME_OVER = 3

local state
local lives

--[[ Todo:
- LATER: title screen, next level screen, game over screen
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
    love.window.setTitle(GAME_TITLE)
	love.graphics.setDefaultFilter("nearest","nearest",1)
	love.graphics.setLineStyle("rough")
    love.graphics.setFont(love.graphics.newFont("Retroville_NC.ttf",10))
    love.graphics.setBackgroundColor(BACKGROUND_COLOR)

    aspect.init(false)
    images.init()
    ladders.init()
    switchToState(STATE_ACTION)
end

function switchToState(new)
    if state == STATE_ACTION then
        entities.reset()
    end
    state = new
    if state == STATE_ACTION then
        lives = LIVES

        entities.add(entities.TYPE_PLAYER,2,0.2)
        entities.add(entities.TYPE_ROBOT,3,0.3)
        entities.add(entities.TYPE_ROBOT,3,0.7)
        entities.add(entities.TYPE_ROBOT,2,0.3)
        entities.add(entities.TYPE_ROBOT,2,0.7)
        entities.add(entities.TYPE_ROBOT,1,0.3)
        entities.add(entities.TYPE_ROBOT,1,0.7)
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

function drawOnScreenInfo()
    love.graphics.setColor(1,1,1)
    for i = 1, lives do
        love.graphics.draw(images.get(images.IMAGE_LIFE_ICON).image,20+(i-1)*20,aspect.GAME_HEIGHT-14)
    end
end

function love.draw()
    aspect.apply()
    love.graphics.clear(BACKGROUND_COLOR)
    drawOnScreenInfo()
    floors.draw()
    ladders.draw()
    entities.draw()
    aspect.letterbox()
end