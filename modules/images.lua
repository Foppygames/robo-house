-- Robo House - modules/images.lua
-- 2020 Foppygames

local images = {}

images.IMAGE_LIFE_ICON = "life_icon"

images.IMAGE_PLAYER_WALK_LEFT_1 = "player_walk_left_1"
images.IMAGE_PLAYER_WALK_RIGHT_1 = "player_walk_right_1"
images.IMAGE_PLAYER_WALK_LEFT_2 = "player_walk_left_2"
images.IMAGE_PLAYER_WALK_RIGHT_2 = "player_walk_right_2"
images.IMAGE_ROBOT_WALK_LEFT_1 = "robot_walk_left_1"
images.IMAGE_ROBOT_WALK_RIGHT_1 = "robot_walk_right_1"
images.IMAGE_PLAYER_EXPLOSION_1 = "player_explosion_1"
images.IMAGE_PLAYER_EXPLOSION_2 = "player_explosion_2"
images.IMAGE_PLAYER_EXPLOSION_3 = "player_explosion_3"
images.IMAGE_PLAYER_JUMP_LEFT = "player_jump_left"
images.IMAGE_PLAYER_JUMP_RIGHT = "player_jump_right"

local list = {}

function images.init() 
    list[images.IMAGE_LIFE_ICON] = {image = love.graphics.newImage("images/life_icon.png")}

    list[images.IMAGE_PLAYER_WALK_RIGHT_1] = {image = love.graphics.newImage("images/player_walk_right.png")}
    list[images.IMAGE_PLAYER_WALK_RIGHT_2] = {image = love.graphics.newImage("images/player_walk_right_2.png")}
    list[images.IMAGE_PLAYER_WALK_LEFT_1] = {image = love.graphics.newImage("images/player_walk_left.png")}
    list[images.IMAGE_PLAYER_WALK_LEFT_2] = {image = love.graphics.newImage("images/player_walk_left_2.png")}
    list[images.IMAGE_ROBOT_WALK_RIGHT_1] = {image = love.graphics.newImage("images/robot_walk_right_1.png")}
    list[images.IMAGE_ROBOT_WALK_LEFT_1] = {image = love.graphics.newImage("images/robot_walk_left_1.png")}
    list[images.IMAGE_PLAYER_EXPLOSION_1] = {image = love.graphics.newImage("images/player_explosion_1.png")}
    list[images.IMAGE_PLAYER_EXPLOSION_2] = {image = love.graphics.newImage("images/player_explosion_2.png")}
    list[images.IMAGE_PLAYER_EXPLOSION_3] = {image = love.graphics.newImage("images/player_explosion_3.png")}
    list[images.IMAGE_PLAYER_JUMP_LEFT] = {image = love.graphics.newImage("images/player_jump_left.png")}
    list[images.IMAGE_PLAYER_JUMP_RIGHT] = {image = love.graphics.newImage("images/player_jump_right.png")}
    
    for key, _ in pairs(list) do
        list[key]["w"] = list[key]["image"]:getWidth()
        list[key]["h"] = list[key]["image"]:getHeight()
    end
end

function images.get(key)
    return list[key]
end

return images