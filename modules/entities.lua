-- Robo House - modules/entities.lua
-- 2020 Foppygames

local entities = {}

local aspect = require("modules.aspect")
local floors = require("modules.floors")
local images = require("modules.images")
local ladders = require("modules.ladders")
local utils = require("modules.utils")

entities.TYPE_PLAYER = 1
entities.TYPE_ROBOT = 2

local list = {}

local input = {
    jump = false,
    resetKeyDownNeeded = false
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
                },
                jump = {
                    left = {
                        images.get(images.IMAGE_PLAYER_JUMP_LEFT)
                    },
                    right = {
                        images.get(images.IMAGE_PLAYER_JUMP_RIGHT)
                    },
                    time = 0.2
                },
                explosion = {
                    both = {
                        images.get(images.IMAGE_PLAYER_EXPLOSION_1),
                        images.get(images.IMAGE_PLAYER_EXPLOSION_2),
                        images.get(images.IMAGE_PLAYER_EXPLOSION_3)
                    },
                    time = 0.06
                }
            },
            collide = {
                type = entities.TYPE_PLAYER,
                w = 12,
                h = 16
            },
            die = {
                dying = false,
                draw = "explosion",
                clock = 0,
                time = 3
            },
            delete = {
                delete = false
            }
        }
    elseif type == entities.TYPE_ROBOT then
        entity = {
            x = x,
            y = y,
            w = 20,
            h = 24,
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
            },
            collide = {
                type = entities.TYPE_ROBOT,
                w = 18,
                h = 24
            },
            button = {
                hit = false,
                h = 8
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
        if input.resetKeyDownNeeded then
            if not love.keyboard.isDown("down") then
                input.resetKeyDownNeeded = false
            end
        end
        entity.action.left = love.keyboard.isDown("left")
        entity.action.right = love.keyboard.isDown("right")
        entity.action.up = love.keyboard.isDown("up")
        entity.action.down = love.keyboard.isDown("down") and not input.resetKeyDownNeeded
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
    if entity.x <= entity.w/2 then
        entity.x = entity.w/2
    end
    if entity.x >= aspect.GAME_WIDTH-entity.w/2 then
        entity.x = aspect.GAME_WIDTH-entity.w/2
    end
end

local function jump(entity)
    if getAction(entity,"jump") then
        if entity.move ~= nil and entity.move.landed then
            entity.move.dy = -entity.jump.power
            entity.move.landed = false

            -- switch to animation used for jumping
            if entity.draw.jump ~= nil then
                if entity.draw.current ~= entity.draw.jump then
                    entity.draw.current = entity.draw.jump
                    entity.draw.frame = 1
                    entity.draw.clock = 0
                end
            end
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
                            input.resetKeyDownNeeded = true
                        end
                    end
                end
            end
            entity.move.landed = landed
            if landed then
                entity.y = y
                entity.move.dy = 0

                -- switch to animation used for walking
                if entity.draw.landed ~= nil then
                    if entity.draw.current ~= entity.draw.landed then
                        entity.draw.current = entity.draw.landed
                        entity.draw.frame = 1
                        entity.draw.clock = 0
                    end
                end
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
                entity.move.dy = 0
                entity.climb.climbing = true
                entity.climb.floor = floor
                entity.move.landed = false

                -- switch to animation used for climbing
                if entity.draw.landed ~= nil then
                    if entity.draw.current ~= entity.draw.landed then
                        entity.draw.current = entity.draw.landed
                        entity.draw.frame = 1
                        entity.draw.clock = 0
                    end
                end
            end
        end
    end
end

local function die(entity,dt)
    if entity.die.dying then
        entity.die.clock = entity.die.clock + dt
        if entity.die.clock >= entity.die.time then
            if entity.delete ~= nil then
                entity.delete.delete = true
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
            entity.draw.dir = entity.draw.newDir
        end
    end    
end

local function collidePlayerRobot(player,robot)
    local diffX = math.abs(robot.x-player.x)
    if diffX > (player.collide.w/2+robot.collide.w/2) then
        return
    end
    if player.y > robot.y+player.collide.h then
        return
    end
    if player.y < robot.y-robot.collide.h then
        return
    end
    local playerHit = false
    if robot.button ~= nil then
        if player.y <= robot.y-robot.h+robot.button.h then
            robot.button.hit = true
            if player.move ~= nil then
                if player.move.dy > 0 then
                    player.y = robot.y-robot.h
                    player.move.dy = -player.move.dy
                elseif player.move.dx > 0 then
                    player.x = robot.x-robot.w/2-player.w/2
                    player.move.dx = -player.move.dx*1.5
                else
                    player.x = robot.x+robot.w/2+player.w/2
                    player.move.dx = -player.move.dx*1.5
                end
            end
        else
            playerHit = true
        end
    else
        playerHit = true
    end
    if playerHit then
        if player.die ~= nil then
            player.die.dying = true

            -- remove player components
            player.move = nil
            player.jump = nil
            player.fall = nil
            player.climb = nil
            player.collide = nil

            -- remove components for non-player entities
            for i = 1, #list do
                local entity = list[i]
                if entity.ai ~= nil then
                    entity.move = nil
                    entity.collide = nil
                end
            end

            if player.draw[player.die.draw] ~= nil then
                player.draw.current = player.draw[player.die.draw]
                player.draw.dir = "both"
                player.draw.newDir = "both"
                player.draw.frame = 1
            end
        end
    end
end

local function collide(entity,other)
    if entity.collide.type == entities.TYPE_PLAYER then
        if other.collide.type == entities.TYPE_ROBOT then
            collidePlayerRobot(entity,other)
        end
    elseif other.collide.type == entities.TYPE_PLAYER then
        if entity.collide.type == entities.TYPE_ROBOT then
            collidePlayerRobot(other,entity)
        end
    end
end

local function collisions()
    for i = 1, #list do
        local entity = list[i]
        -- entity can collide
        if entity.collide ~= nil then
            -- check all entities below this one in list
            for j = i+1, #list do
                local other = list[j]
                -- other can collide
                if other.collide ~= nil then
                    -- same type cannot collide
                    if entity.collide.type ~=  other.collide.type then
                        collide(entity,other)

                        -- entity no longer colliding
                        if entity.collide == nil then
                            -- skip rest of others
                            break
                        end
                    end
                end
            end
        end
    end
end

-- returns true if player deleted
local function deletion()
    local playerDeleted = false
    for i = #list, 1, -1 do
        if list[i].delete ~= nil and list[i].delete.delete then
            if list[i].ai == nil then
                playerDeleted = true
            end
            table.remove(list,i)
        end
    end
    return playerDeleted
end

-- returns whether game continues
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
        if entity.die ~= nil then
            die(entity,dt)
        end
        if entity.draw ~= nil then
            draw(entity,dt)
        end   
    end

    collisions()
    local continue = not deletion()

    -- reset input
    input = {
        jump = false
    }

    return continue
end

function entities.draw()
    love.graphics.setColor(1,1,1)
    for i = 1, #list do
        local entity = list[i]
        if entity.draw ~= nil then
            if entity.draw.current ~= nil then
                local sprite = entity.draw.current[entity.draw.dir][entity.draw.frame]
                local x = entity.x-sprite.w/2
                local y = entity.y-sprite.h
                if entity.die ~= nil and entity.die.dying then
                    x = x + math.random(-1,1)
                    y = y + math.random(-1,1)
                end
                love.graphics.draw(sprite.image,x,y)
            end
        end
    end
end

return entities