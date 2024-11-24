local bf = require "breezefield"

local world = bf.newWorld(0,100,true)

world:addCollisionClass("GroundA")
world:addCollisionClass("GroundB")
world:addCollisionClass("GroundC")

world:addCollisionClass("CircleA", {
    ignores = "All",
    except = {"GroundA"}
})

world:addCollisionClass("CircleB", {
    ignores = "All",
    except = {"GroundB"}
})

world:addCollisionClass("CircleC", {
    ignores = "All",
    except = {"GroundC"}
})


local groundA, groundB, groundC
local circleA, circleB, circleC

function love.load()
    local w_width = love.graphics.getWidth()
    local w_height = love.graphics.getHeight()
    groundA = world:newCollider("Rectangle", {w_width/2, 50, w_width, 5})
    groundB = world:newCollider("Rectangle", {w_width/2, 100, w_width, 5})
    groundC = world:newCollider("Rectangle", {w_width/2, 150, w_width, 5})
    groundA:setCollisionClass("GroundA")
    groundB:setCollisionClass("GroundB")
    groundC:setCollisionClass("GroundC")

    groundA:setType("static")
    groundB:setType("static")
    groundC:setType("static")

    circleA = world:newCollider("Circle", {100, 10, 10})
    circleA:setCollisionClass("CircleA")

    circleB = world:newCollider("Circle", {200, 10, 10})
    circleB:setCollisionClass("CircleB")

    circleA = world:newCollider("Circle", {300, 10, 10})
    circleA:setCollisionClass("CircleC")
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    world:draw()
end
