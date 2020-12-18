-- Robo House - modules/images.lua
-- 2020 Foppygames

local images = {}

images.IMAGE_PLAYER_WALK_LEFT_1 = "player_walk_left_1"
images.IMAGE_PLAYER_WALK_RIGHT_1 = "player_walk_right_1"
images.IMAGE_PLAYER_WALK_LEFT_2 = "player_walk_left_2"
images.IMAGE_PLAYER_WALK_RIGHT_2 = "player_walk_right_2"
images.IMAGE_ROBOT_WALK_LEFT_1 = "robot_walk_left_1"
images.IMAGE_ROBOT_WALK_RIGHT_1 = "robot_walk_right_1"

local list = {}

function images.init() 
    list[images.IMAGE_PLAYER_WALK_RIGHT_1] = {image = love.graphics.newImage("images/player_walk_right.png")}
    list[images.IMAGE_PLAYER_WALK_RIGHT_2] = {image = love.graphics.newImage("images/player_walk_right_2.png")}
    list[images.IMAGE_PLAYER_WALK_LEFT_1] = {image = love.graphics.newImage("images/player_walk_left.png")}
    list[images.IMAGE_PLAYER_WALK_LEFT_2] = {image = love.graphics.newImage("images/player_walk_left_2.png")}
    list[images.IMAGE_ROBOT_WALK_RIGHT_1] = {image = love.graphics.newImage("images/robot_walk_right_1.png")}
    list[images.IMAGE_ROBOT_WALK_LEFT_1] = {image = love.graphics.newImage("images/robot_walk_left_1.png")}

    for key, _ in pairs(list) do
        list[key]["w"] = list[key]["image"]:getWidth()
        list[key]["h"] = list[key]["image"]:getHeight()
    end
end

function images.get(key)
    return list[key]
end

return images