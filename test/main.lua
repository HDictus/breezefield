bf = require("breezefield")

-- TODO split into multiple test scripts
function love.load()
   world = bf.newWorld(0, 90.81, true)
   world.ballstospawn = 0
   ground = bf.Collider.new(world, "Polygon",
				    {0, 550, 650, 550 , 650, 650, 0, 650})
   ground:setType("static")

   ball = bf.Collider.new(world, "Circle", 325, 325, 20)
      
   ball:setRestitution(1.0)
   block1 = bf.Collider.new(world, "Polygon", {150, 375, 250, 375,
					       250, 425, 150, 425})
   little_ball.new(
      love.math.random(love.graphics.getWidth()), 0)
   
   function ball:collide(other)
      if other == block1 then
	 world.ballstospawn = world.ballstospawn + 1
      end
   end

end

function love.update(dt)
   world:update(dt)
   if love.keyboard.isDown("right") then
    ball:applyForce(400, 0)
  elseif love.keyboard.isDown("left") then
    ball:applyForce(-400, 0)
  elseif love.keyboard.isDown("up") then
    ball:setPosition(325, 325)
    ball:setLinearVelocity(0, 0) 
   end
   while world.ballstospawn > 0 do
      little_ball.new(love.math.random(love.graphics.getWidth()))
      world.ballstospawn = world.ballstospawn - 1
   end
   
end


function love.draw()
   world:draw()
end

-- TODO demonstrate collisionn handling
-- TODO demonstrate collision classes
function love.mousepressed()
   local x, y
   x, y = love.mouse.getPosition()
   colls = world:queryCircleArea(x, y, 15)
   for _, collider in ipairs(colls) do
      if collider == ball then
	 collider:applyLinearImpulse(0, -400)
      end
   end
end

little_ball = {}
setmetatable(little_ball, bf.Collider)

function little_ball.new(...)
   bf.Collider.new(world, 'Circle', ..., 5)
end

