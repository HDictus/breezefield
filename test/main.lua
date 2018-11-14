bf = require("breezefield")

function love.load()
   world = bf.newWorld(0, 90.81, true)
   objects = {}

   objects.ground = bf.Collider.new(world, "Polygon",
				    {0, 550, 650, 550 , 650, 650, 0, 650})
   objects.ground:setType("static")
   objects.ball = bf.Collider.new(world, "Circle", 325, 325, 20)
   objects.ball:setRestitution(1.0)
   objects.block1 = bf.Collider.new(world, "Polygon", {150, 375, 250, 375,
						       250, 425, 150, 425})
end

function love.update(dt)
   world:update(dt)
   if love.keyboard.isDown("right") then 
    objects.ball:applyForce(400, 0)
  elseif love.keyboard.isDown("left") then 
    objects.ball:applyForce(-400, 0)
  elseif love.keyboard.isDown("up") then 
    objects.ball:setPosition(325, 325)
    objects.ball:setLinearVelocity(0, 0) 
  end
end


function love.draw()
   world:draw()
end

-- TODO demonstrate querying
-- TODO demonstrate collisionn handling
function love.mousepressed()
   
end
