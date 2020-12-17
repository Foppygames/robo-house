-- Robo House - modules/images.lua
-- 2020 Foppygames

local images = {}

images.IMAGE_PLAYER_WALK_LEFT = "player_walk_left"
images.IMAGE_PLAYER_WALK_RIGHT = "player_walk_right"

local list = {}

function images.init() 
    list[images.IMAGE_PLAYER_WALK_RIGHT] = {image = love.graphics.newImage("images/player_walk_right.png")}
    list[images.IMAGE_PLAYER_WALK_LEFT] = {image = love.graphics.newImage("images/player_walk_left.png")}

    for key, _ in pairs(list) do
        list[key]["w"] = list[key]["image"]:getWidth()
        list[key]["h"] = list[key]["image"]:getHeight()
    end
end

function images.get(key)
    return list[key]
end

return images