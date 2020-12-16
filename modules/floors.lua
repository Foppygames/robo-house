-- Robo House - modules/floors.lua
-- 2020 Foppygames

local floors = {}

local aspect = require("modules.aspect")
local utils = require("modules.utils")

local FLOOR_COUNT = 3
local FLOOR_Y_START = utils.round(aspect.GAME_HEIGHT*0.9)
local FLOOR_Y_STEP = utils.round(FLOOR_Y_START / FLOOR_COUNT)
local FLOOR_HEIGHT = 6
local FLOOR_WIDTH = utils.round(aspect.GAME_WIDTH * 0.9)
local FLOOR_X = utils.round((aspect.GAME_WIDTH - FLOOR_WIDTH) / 2)
local FLOOR_COLOR = utils.getColorFromRgb(255,163,0)

function floors.draw()
    love.graphics.setColor(FLOOR_COLOR)
    for i = 1, FLOOR_COUNT do
        love.graphics.rectangle("fill",FLOOR_X,FLOOR_Y_START-(i-1)*FLOOR_Y_STEP,FLOOR_WIDTH,FLOOR_HEIGHT)
    end
end

function floors.getLocation(floor,xFraction)
    if floor > FLOOR_COUNT then
        return 0, 0
    end
    local y = FLOOR_Y_START - (floor-1) * FLOOR_Y_STEP
    local x = utils.round(FLOOR_X + xFraction * FLOOR_WIDTH)
    return x, y
end

return floors