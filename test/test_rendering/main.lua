bf = require("breezefield")

function love.load()
    world = bf.newWorld()
    coll1 = world:newCollider('Circle', {200, 200, 20})

    coll1:setSensor(true)
    coll2 = world:newCollider('Circle', {200, 200, 30})
    function coll2:draw()
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle('fill', 200, 200, 30)
    end
    coll1:setDrawOrder(1)
    coll2:setDrawOrder(0)
end

function love.update(dt)

end

function love.draw()
    world:draw()
end