local pre_globals = {}
for n, v in pairs(_G) do
   pre_globals[n] = v
end

bf = require("deps.breezefield")

for n, v in pairs(_G) do
   assert(n == 'bf' or pre_globals[n] ~= nil, 'stray global variable: '.. n)
end

-- TODO split into multiple test scripts
function love.load()
   world = bf.newWorld(0, 90.81, true)
   ground = bf.Collider.new(world,
			    "rect", 325, 600, 650, 100)

   ground:setType("static")
   print(ground.collider_type)

   ball = bf.Collider.new(world, "Circle", 325, 325, 20)

   ball:setRestitution(0.8)
   block1 = bf.Collider.new(world, "Polygon", {150, 375, 250, 375,
					       250, 425, 150, 425})
   little_ball.new(
      love.math.random(love.graphics.getWidth()), 0)

   tri = bf.Collider.new(world, "Polygon", {400, 400, 450, 400, 425, 356.7})
   edge = bf.Collider.new(world, 'Edge', 500, 300, 500, 500)
   edge:setType('static')

   chain = bf.Collider.new(world, 'Chain', false, 100, 100, 110, 110, 115, 110, 120, 115, 120, 125, 130, 130)


   function ball:postSolve(other)
      if other == block1 then
	 -- creating Collder.new should never be called inside a callback
	 -- a limitation of (box2d)
	 -- instead, return a function to be called during update()
	 return spawn_random_ball
      end
   end

   function ball:enter(other)
      if other == tri then
	 self:setLinearVelocity(0, -200)
      end
      return
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

-- TODO demonstrate collisionn handling
-- TODO demonstrate collision classes
function love.mousepressed()
   local x, y
   local radius = 30
   x, y = love.mouse.getPosition()
   local colls = world:queryCircleArea(x, y, radius)
   for _, collider in ipairs(colls) do
      if collider.identity == little_ball then
	 local dx = love.mouse.getX() - collider:getX()
	 local dy = love.mouse.getY() - collider:getY()
	 local power = -5
	 collider:applyLinearImpulse(power * dx, power * dy)
      end
   end
end

little_ball = {}
little_ball.__index = little_ball
little_ball.identity = little_ball
setmetatable(little_ball, bf.Collider)

function spawn_random_ball()
   little_ball.new(love.math.random(love.graphics.getWidth()), 0)
end

function little_ball.new(x, y)
   local n = bf.Collider.new(world, 'Circle', x, y, 5)
   setmetatable(n, little_ball)
   return n
end

function little_ball:draw(alpha)
   love.graphics.setColor(0.9, 0.9, 0.0)
   love.graphics.circle('fill', self:getX(), self:getY(), self:getRadius())
end
