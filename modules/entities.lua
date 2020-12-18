-- Robo House - modules/entities.lua
-- 2020 Foppygames

local entities = {}

local floors = require("modules.floors")
local images = require("modules.images")
local ladders = require("modules.ladders")

entities.TYPE_PLAYER = 1
entities.TYPE_ROBOT = 2

local list = {}
local resetKeyDownNeeded = false

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
            action = {
                left = false,
                right = false,
                jump = false,
                up = false,
                down = false
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
            },
            climb = {
                climbing = false,
                floor = nil,
                maxDx = 90,
                accX = 1000, 
                maxDy = 90,
                accY = 1000
            },
            draw = {
                dir = "right",
                newDir = "right",
                current = nil,
                frame = 1,
                clock = 0,
                default = "landed",
                landed = {
                    left = {
                        images.get(images.IMAGE_PLAYER_WALK_LEFT_1),
                        images.get(images.IMAGE_PLAYER_WALK_LEFT_2)
                    },
                    right = {
                        images.get(images.IMAGE_PLAYER_WALK_RIGHT_1),
                        images.get(images.IMAGE_PLAYER_WALK_RIGHT_2)
                    },
                    time = 0.2
                }
            }
        }
    elseif type == entities.TYPE_ROBOT then
        entity = {
            x = x,
            y = y,
            w = 20,
            h = 32,
            action = {
                left = false,
                right = false,
                jump = false,
                up = false,
                down = false
            },
            ai = {
                dir = "right",
                turnFloorFraction = 0.95
            },
            move = {
                dx = 0,
                dy = 0,
                oldY = 0,
                appliedDy = 0,
                maxDx = 20,
                accX = 40,
                landed = false
            },
            draw = {
                dir = "right",
                newDir = "right",
                current = nil,
                frame = 1,
                clock = 0,
                default = "landed",
                landed = {
                    left = {
                        images.get(images.IMAGE_ROBOT_WALK_LEFT_1)
                    },
                    right = {
                        images.get(images.IMAGE_ROBOT_WALK_RIGHT_1)
                    },
                    time = 0.2
                }
            }
        }
    end

    -- select initial image
    if entity.draw ~= nil then
        entity.draw.current = entity.draw[entity.draw.default]
    end

    -- change robot direction per floor
    if type == entities.TYPE_ROBOT and floor % 2 ~= 0 then
        entity.ai.dir = "left"
        entity.draw.dir = "left"
        entity.draw.newDir = "left"
    end

    table.insert(list,entity)
end

function entities.setInput(key)
    input[key] = true
end

local function action(entity)
    if entity.ai ~= nil then  
        entity.action.left = (entity.ai.dir == "left")
        entity.action.right = (entity.ai.dir == "right")
    else
        if resetKeyDownNeeded then
            if not love.keyboard.isDown("down") then
                resetKeyDownNeeded = false
            end
        end
        entity.action.left = love.keyboard.isDown("left")
        entity.action.right = love.keyboard.isDown("right")
        entity.action.up = love.keyboard.isDown("up")
        entity.action.down = love.keyboard.isDown("down") and not resetKeyDownNeeded
        entity.action.jump = input.jump
    end
end

local function ai(entity)
    local fraction = floors.getFraction(entity.x)
    if entity.ai.dir == "left" then
        if fraction <= (1 - entity.ai.turnFloorFraction) then
            entity.ai.dir = "right"
        end
    elseif entity.ai.dir == "right" then
        if fraction >= entity.ai.turnFloorFraction then
            entity.ai.dir = "left"
        end
    end
end

local function getAction(entity,type)
    if entity.action ~= nil then
        return entity.action[type]
    end
    return false
end

local function loseHorMomentum(entity,dt)
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
    local left = getAction(entity,"left")
    local right = getAction(entity,"right")
    if left then
        entity.move.dx = entity.move.dx - entity.move.accX*dt
        if entity.move.dx < -entity.move.maxDx then
            entity.move.dx = -entity.move.maxDx
        end
        if entity.draw ~= nil then
            entity.draw.newDir = "left"
        end
    elseif right then
        entity.move.dx = entity.move.dx + entity.move.accX*dt
        if entity.move.dx > entity.move.maxDx then
            entity.move.dx = entity.move.maxDx
        end
        if entity.draw ~= nil then
            entity.draw.newDir = "right"
        end
    else
        -- during climbing there is no momentum
        if entity.climb ~= nil and entity.climb.climbing then
            entity.move.dx = 0
        else
            loseHorMomentum(entity,dt)
        end
    end
    if entity.climb ~= nil and entity.climb.climbing then
        local up = getAction(entity,"up")
        local down = getAction(entity,"down")
        if up then
            entity.move.dy = entity.move.dy - entity.climb.accX*dt
            if entity.move.dy < -entity.climb.maxDy then
                entity.move.dy = -entity.climb.maxDy
            end
        elseif down then
            entity.move.dy = entity.move.dy + entity.climb.accX*dt
            if entity.move.dy > entity.climb.maxDy then
                entity.move.dy = entity.climb.maxDy
            end
        else
            -- during climbing there is no momentum
            entity.move.dy = 0
        end
    end
    entity.x = entity.x + entity.move.dx*dt
    entity.y = entity.y + entity.move.dy*dt
end

local function jump(entity)
    if getAction(entity,"jump") then
        if entity.move ~= nil and entity.move.landed then
            entity.move.dy = -entity.jump.power
            entity.move.landed = false
        end
    end
end

local function fall(entity,dt)
    if entity.climb ~= nil and entity.climb.climbing then
        return
    end
    if entity.move ~= nil then
        entity.move.dy = entity.move.dy + entity.fall.gravity
    end
end

local function land(entity)
    if entity.move ~= nil then
        -- entity is moving down
        if entity.move.dy > 0 then
            local landed, floor, y = floors.land(entity.x,entity.w,entity.move.oldY,entity.y)
            if landed then
                -- entity is climbing... 
                if entity.climb ~= nil and entity.climb.climbing then
                    -- ...through floor that is not the floor the ladder is standing on
                    if entity.climb.floor ~= floor then
                        landed = false
                    -- ...on to the floor the ladder is standing on
                    else
                        entity.climb.climbing = false

                        -- entity uses keyboard for input
                        if entity.ai == nil then
                            -- key down has to be released to be registered again
                            resetKeyDownNeeded = true
                        end
                    end
                end
            end
            entity.move.landed = landed
            if landed then
                entity.y = y
                entity.move.dy = 0
            end
        end
    end
end

local function climb(entity)
    -- entity is climbing
    if entity.climb.climbing then
        local floor, grab = ladders.grab(entity.x,entity.y,entity.w,entity.h)
        entity.climb.climbing = grab
        entity.climb.floor = floor
    -- entity is not climbing
    else
        if getAction(entity,"up") or getAction(entity,"down") then
            local floor, grab = ladders.grab(entity.x,entity.y,entity.w,entity.h)
            if grab then
                --entity.move.dx = 0
                entity.move.dy = 0
                entity.climb.climbing = true
                entity.climb.floor = floor
                entity.move.landed = false
            end
        end
    end
end

local function draw(entity,dt)
    if entity.draw.current ~= nil then
        -- animate
        entity.draw.clock = entity.draw.clock + dt
        if entity.draw.clock >= entity.draw.current.time then
            entity.draw.frame = entity.draw.frame + 1
            if entity.draw.frame > #entity.draw.current[entity.draw.dir] then
                entity.draw.frame = 1
            end
            entity.draw.clock = entity.draw.clock - entity.draw.current.time
        end

        -- change direction
        if entity.draw.newDir ~= entity.draw.dir then
            -- ...
            entity.draw.dir = entity.draw.newDir
        end
    end    
end

function entities.update(dt)
    for i = 1, #list do
        local entity = list[i]
        
        if entity.ai ~= nil then
            ai(entity)
        end
        if entity.action ~= nil then
            action(entity)
        end
        if entity.jump ~= nil then
            jump(entity)
        end
        if entity.fall ~= nil then
            fall(entity,dt)
        end
        if entity.climb ~= nil then
            climb(entity)
        end
        if entity.move ~= nil then
            move(entity,dt)
            land(entity)
        end
        if entity.draw ~= nil then
            draw(entity,dt)
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
        if entity.draw ~= nil then
            if entity.draw.current ~= nil then
                local sprite = entity.draw.current[entity.draw.dir][entity.draw.frame]
                love.graphics.draw(sprite.image,entity.x-sprite.w/2,entity.y-sprite.h)
            end
        end
    end
end

return entities