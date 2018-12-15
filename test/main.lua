bf = require("breezefield")

-- TODO split into multiple test scripts
function love.load()
   world = bf.newWorld(0, 90.81, true)
   ground = bf.Collider.new(world, "Polygon",
				    {0, 550, 650, 550 , 650, 650, 0, 650})
   ground:setType("static")

   ball = bf.Collider.new(world, "Circle", 325, 325, 20)
      
   ball:setRestitution(0.8)
   block1 = bf.Collider.new(world, "Polygon", {150, 375, 250, 375,
					       250, 425, 150, 425})
   little_ball.new(
      love.math.random(love.graphics.getWidth()), 0)

   function ball:postSolve(other)
      if other == block1 then
	 -- creating Collder.new should never be called inside a callback
	 -- a limitation of (box2d)
	 -- instead, return a function to be called during update()
	 return spawn_random_ball
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
  elseif love.keyboard.isDown("down") then
     ball:applyForce(0, 600)
   end
end


function love.draw()
   world:draw()
end



little_ball = {}
little_ball.__index = little_ball
setmetatable(little_ball, bf.Collider)

function spawn_random_ball()
   little_ball.new(love.math.random(love.graphics.getWidth()), 0)
end

function little_ball.new(x, y)
   local n = bf.Collider.new(world, 'Circle', x, y, 5)
   setmetatable(n, little_ball)
   return n
end
