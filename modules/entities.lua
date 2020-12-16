-- Robo House - modules/entities.lua
-- 2020 Foppygames

local entities = {}

local floors = require("modules.floors")

entities.TYPE_PLAYER = 1
entities.TYPE_ROBOT = 2

local list = {}

local input = {
    jump = false
}

function entities.reset()
    list = {}
end

function entities.add(type,floor,xFraction)
    local x, y = floors.getLocation(floor,xFraction)
    if type == entities.TYPE_PLAYER then
        entity = {
            x = x,
            y = y,
            w = 16,
            h = 16,
            input = {
                left = false,
                right = false
            },
            move = {
                dx = 0,
                dy = 0,
                maxDx = 50,
                accX = 50*10 -- meaning, top speed of 50 is reached in 0.1 second
            }
        }
    elseif type == entities.TYPE_ROBOT then
        entity = {
            x = x,
            y = y,
            w = 16,
            h = 16,
            ai = {
                left = false,
                right = false
            },
            move = {
                dx = 0,
                dy = 0,
                maxDx = 5,
                accX = 5
            }
        }
    end
    table.insert(list,entity)
end

function entities.setInput(key)
    input[key] = true
end

local function _input(entity)
    if love.keyboard.isDown("left") then
        entity.input.left = true
        entity.input.right = false
    elseif love.keyboard.isDown("right") then
        entity.input.left = false
        entity.input.right = true
    else
        entity.input.left = false
        entity.input.right = false
    end
end

local function ai(entity)
    -- ...
end

local function move(entity,dt)
    local left = false
    local right = false
    if entity.input ~= nil then
        left = entity.input.left
        right = entity.input.right
    end
    if entity.ai ~= nil then
        left = entity.ai.left
        right = entity.ai.right
    end
    if left then
        entity.move.dx = entity.move.dx - entity.move.accX*dt
        if entity.move.dx < -entity.move.maxDx then
            entity.move.dx = -entity.move.maxDx
        end
    elseif right then
        entity.move.dx = entity.move.dx + entity.move.accX*dt
        if entity.move.dx > entity.move.maxDx then
            entity.move.dx = entity.move.maxDx
        end
    else
        if entity.move.dx > 0 then
            entity.move.dx = entity.move.dx - entity.move.accX*dt
            if entity.move.dx < 0 then
                entity.move.dx = 0
            end
        elseif entity.move.dx < 0 then
            entity.move.dx = entity.move.dx + entity.move.accX*dt
            if entity.move.dx > 0 then
                entity.move.dx = 0
            end
        end
    end
    entity.x = entity.x + entity.move.dx*dt
    entity.y = entity.y + entity.move.dy*dt
end

function entities.update(dt)
    for i = 1, #list do
        local entity = list[i]
        
        if entity.input ~= nil then
            _input(entity)
        end
        if entity.ai ~= nil then
            ai(entity)
        end
        if entity.move ~= nil then
            move(entity,dt)
        end
    end

    -- reset input
    input = {
        jump = false
    }
end

function entities.draw()
    love.graphics.setColor(1,0,0)
    for i = 1, #list do
        local entity = list[i]
        love.graphics.rectangle("fill",entity.x-entity.w/2,entity.y-entity.h,entity.w,entity.h)
    end
end

return entities