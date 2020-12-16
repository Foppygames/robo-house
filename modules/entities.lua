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

function entities.add(type,floor,floorXFraction)
    local x, y = floors.getLocation(floor,floorXFraction)
    if type == entities.TYPE_PLAYER then
        entity = {
            x = x,
            y = y,
            w = 16,
            h = 16,
            input = {
                left = false,
                right = false,
                jump = false
            },
            move = {
                dx = 0,
                dy = 0,
                oldY = 0,
                maxDx = 90,
                accX = 1000,
                landed = false
            },
            jump = {
                power = 150
            },
            fall = {
                gravity = 5
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
                right = false,
                jump = false
            },
            move = {
                dx = 0,
                dy = 0,
                oldY = 0,
                appliedDy = 0,
                maxDx = 50,
                accX = 500,
                landed = false
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
    entity.input.jump = input.jump
end

local function ai(entity)
    -- ...
end

local function getInput(entity,key)
    if entity.input ~= nil then
        return entity.input[key]
    end
    if entity.ai ~= nil then
        return entity.ai[key]
    end
    return false
end

local function loseMomentum(entity,dt)
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

local function move(entity,dt)
    entity.move.oldY = entity.y
    local left = getInput(entity,"left")
    local right = getInput(entity,"right")
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
        loseMomentum(entity,dt)
    end
    entity.x = entity.x + entity.move.dx*dt
    entity.y = entity.y + entity.move.dy*dt
end

local function jump(entity)
    if getInput(entity,"jump") then
        if entity.move ~= nil then
            if entity.move.landed then
                entity.move.dy = -entity.jump.power
                entity.move.landed = false
            end
        end
    end
end

local function fall(entity,dt)
    if entity.move ~= nil then
        entity.move.dy = entity.move.dy + entity.fall.gravity
    end
end

local function land(entity)
    if entity.move ~= nil then
        -- entity is moving down
        if entity.move.dy > 0 then
            local landed, y = floors.land(entity.x,entity.w,entity.move.oldY,entity.y)
            entity.move.landed = landed
            if landed then
                entity.y = y
                entity.move.dy = 0
            end
        end
    end
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
        if entity.jump ~= nil then
            jump(entity)
        end
        if entity.fall ~= nil then
            fall(entity,dt)
        end
        if entity.move ~= nil then
            move(entity,dt)
            land(entity)
        end   
    end

    -- reset input
    input = {
        jump = false
    }
end

function entities.draw()
    love.graphics.setColor(1,1,1)
    for i = 1, #list do
        local entity = list[i]
        love.graphics.rectangle("fill",entity.x-entity.w/2,entity.y-entity.h,entity.w,entity.h)
    end
end

return entities