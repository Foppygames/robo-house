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
local titleAngle = 0

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
	love.graphics.setDefaultFilter("nearest","nearest")
	love.graphics.setLineStyle("rough")
    love.graphics.setFont(love.graphics.newFont("Retroville_NC.ttf",10))
    love.graphics.setBackgroundColor(BACKGROUND_COLOR)

    aspect.init(false)
    images.init()
    ladders.init()
    switchToState(STATE_TITLE)
end

function switchToState(new)
    if state == STATE_ACTION then
        entities.reset()
    end
    state = new
    if state == STATE_TITLE then
        titleAngle = 0
    elseif state == STATE_ACTION then
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
    if state == STATE_TITLE then
        titleAngle = titleAngle + 12 * dt
        if titleAngle >= 360 then
            titleAngle = titleAngle - 360
        end
    end
    if state == STATE_ACTION then
        if not entities.update(dt) then
            switchToState(STATE_TITLE)
        end
    end
end

function love.keypressed(key)
    if state == STATE_TITLE then
        if key == "escape" then
            love.event.quit()
        elseif key == "space" then
            switchToState(STATE_ACTION)
        end
    end
    if state == STATE_ACTION then
        if key == "escape" then
            switchToState(STATE_TITLE)
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

function drawTitleScreen()
    love.graphics.push()
    love.graphics.scale(2,2)
    love.graphics.setColor(utils.getColorFromRgb(255,163,0))
    for i = 1, string.len(GAME_TITLE) do
        local angle = titleAngle + i * 12
        if angle >= 360 then
            angle = angle - 360
        end
        love.graphics.print(string.sub(GAME_TITLE,i,i),30 + i * 10 - math.cos(math.rad(angle)*5),6-math.sin(math.rad(angle)*20))
	end
    love.graphics.pop()
    love.graphics.setColor(utils.getColorFromRgb(255,236,39))
    love.graphics.printf("For the #Redefine2021 gamejam!",0,60,aspect.GAME_WIDTH,"center")	
    
    love.graphics.setColor(utils.getColorFromRgb(41,173,255))
    love.graphics.printf("Controls: arrow keys and space",0,90,aspect.GAME_WIDTH,"center")	
    love.graphics.printf("PRESS SPACE TO START",0,110,aspect.GAME_WIDTH,"center")	
    love.graphics.setColor(utils.getColorFromRgb(131,118,156))
    love.graphics.printf("Press Esc to quit",0,130,aspect.GAME_WIDTH,"center")	

    love.graphics.setColor(utils.getColorFromRgb(255,241,232))
    love.graphics.printf("Code & gfx by Robbert Prins",0,aspect.GAME_HEIGHT-40,aspect.GAME_WIDTH,"center")	
    love.graphics.setColor(utils.getColorFromRgb(255,236,39))
    love.graphics.printf("Foppygames 2020",0,aspect.GAME_HEIGHT-20,aspect.GAME_WIDTH,"center")	
end

function love.draw()
    aspect.apply()
    love.graphics.clear(BACKGROUND_COLOR)

    if state == STATE_TITLE then
        drawTitleScreen()
    end

    if state == STATE_ACTION then
        --drawOnScreenInfo()
        floors.draw()
        ladders.draw()
        entities.draw()
    end

    aspect.letterbox()
end