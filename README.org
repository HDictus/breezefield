
#+TOC: headlines 2

* introduction

** why breezefield?
   The love physics library is very flexible, but doing relatively simple
   things with it can be tedious. A good solution is the [[https://github.com/adnzzzzZ/windfield][windfield]] library,
   but a few things didn't quite sit right for me.
    
   I've used windfield for a few practice projects, and I liked it very much. 
   It makes protoyping faster, and massively reduces the time
   and mental effort spent putting together all the pieces of love.physics.
   so far however, I've encountered the occaisional issue that was tricky to
   track down due to (in particular) the collision-management system in place
   in windfield. When I needed to modify parts of it to my purposes, 
   I found its size and complexity made it take a little longer than it could
   have with a simpler library.
    
   Breezefield is a lightweight alternative that takes the parts that I 
   liked best about windfield and leaves out what I felt held it back.


* functionality
** easily create physics objects (body + shape + fixture)
  #+BEGIN_SRC lua
  world:newCollider(<shape_type>, <shape_args>, <table_to_use>(optional))
  #+END_SRC
** query rectangle, circle, edge, or polygon areas
  #+BEGIN_SRC lua
  world:queryRectangleArea(x1, y1, x2, y2)
  #+END_SRC 

** love.physics.<object> methods mapped to breezefield objects
  #+BEGIN_SRC lua
  Collider:<methodname> (e.g. get/setRestitution, get/setX, etc...)
  World:<methodname> (e.g. update)
  #+END_SRC 

  So you can make a collider move rightwards with

 #+BEGIN_SRC lua
  collider:setLinearVelocity(100, 0)
 #+END_SRC 

** Collision handling
   You can set collision events for a Collider by overwriting some methods:
    - `:enter(other, collision) called on each collider when two colliders come into contact
    - `:exit(other, collision) called on each collider when two colliders cease to be in contact
    - `:preSolve(other, collision)` called on each collider before their collision(e.g. bounce) has been resolved
    - `:postSolve(other, collision, normalimpulse, tangentimpulse)` called on each collider after their collision has been resolved

   The collision argument to each will be the `love.physics.Contact` (https://love2d.org/wiki/Contact) object associated with the collision.
   A handy trick to prevent colliders from colliding with each other is to do `collision:setEnabled(False)` inside the preSolve method.
    You may notice that these correspond to the four callbacks in https://love2d.org/wiki/Tutorial:PhysicsCollisionCallbacks .
   
   If you wish to handle collisions differently, you can also just overwrite those callbacks with `world:setCallbacks`
    
** draw physics objects with one command
  #+BEGIN_SRC lua
  world:draw()
  #+END_SRC 

*** can be repurposed to draw in-game shapes/sprites!
  Just redefine :draw on your collider objects, 
  add other objects with :draw methods to world.colliders.
  # TODO rename world.colliders to world.to_draw?
  Call world:draw(<alpha>, true) to draw physics boundaries in addition to
  self-defined :draw methods
  
  You can ensure some colliders are drawn over others with `Collider:setDrawOrder(number)`.
  Colliders with higher draw orders will be drawn over those with smaller draw orders.
  The default is 0, and the draw order can be negative.
** access to love.physics objects if you have something more creative in mind
   World._physworld contains the regular love.physics.world object.
   Collider.fixture, Collider.body, Collider.shape all contain the 
   respective physics objects
*** please let me know if there are any issues 
    if there are any issues in breezefields implementation that complicates using
    love.physics together with it, let me know, or better yet, send a pull request

* Installation
  I reccomend you ensure you understand love.physics, as breezefield mostly just wraps that. You can start [[https://love2d.org/wiki/Tutorial:Physics][here]]. 
  To install simply clone or download the repository and place breezefield anywhere in your lua path or in your project directory.

* example/tutorial
** Basics
*** setting up a basic world
#+BEGIN_SRC lua
bf = require("breezefield")

function love.load()
   world = bf.newWorld(0, 90.81, true)
   -- bf.World:new also works
   -- any function of love.physics.world should work on World
   print(world:getGravity())

   ground = bf.Collider.new(world, "Polygon",
				    {0, 550, 650, 550 , 650, 650, 0, 650})
   ground:setType("static")

   ball = bf.Collider.new(world, "Circle", 325, 325, 20)
   
   ball:setRestitution(0.8) -- any function of shape/body/fixture works
   block1 = bf.Collider.new(world, "Polygon", {150, 375, 250, 375,
					       250, 425, 150, 425})

end
#+END_SRC
*** forces, movement and control
    any functions for shape, body, or fixture work on Colliders
#+BEGIN_SRC lua
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

#+END_SRC

*** easily draw physics
#+BEGIN_SRC lua
function love.draw()
   world:draw()
end
#+END_SRC

** call functions on collision
   default collision callbacks of World will locate the colliders from a fixture's userData and call the relevant :enter :exit :postSolve or :preSolve method

**** pre: make that function and object to play with
    #+BEGIN_SRC lua
little_ball = {}
little_ball.__index = little_ball
setmetatable(little_ball, bf.Collider) -- this is important
-- otherwise setting the new object's metatable to little_ball overwrites

function spawn_random_ball()
   little_ball.new(love.math.random(love.graphics.getWidth()), 0)
end

function little_ball.new(x, y)
   local n = bf.Collider.new(world, 'Circle', x, y, 5)
   setmetatable(n, little_ball)
   return n
end

#+END_SRC

*** define collision function
    one feature is that any function callbacks returned by Collider:enter/exit/<post/pre>Solve are run in world:update()
    this lets us easily create and destroy objects in collision callbacks without crashing Box2D (love.physics's backend)
#+BEGIN_SRC lua
   function ball:postSolve(other)
      if other == block1 then
	 -- creating Collder.new should never be called inside a callback
	 -- a limitation of (box2d)
	 -- instead, return a function to be called during World:update()
	 return spawn_random_ball -- see above for definition
      end
   end

#+END_SRC

** change appearance of physics objects 
   simply define the :draw function on your collider 
   (you can still access the default draw as :__draw__)
#+BEGIN_SRC lua
function little_ball:draw(alpha)
   love.graphics.setColor(0.9, 0.9, 0.0)
   love.graphics.circle('fill', self:getX(), self:getY(), self:getRadius())
end
#+END_SRC

** query the world (supports rectangle, circle, polygon and edge)
#+BEGIN_SRC lua
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
#+END_SRC
and after little_ball's declaration
#+BEGIN_SRC lua
little_ball.identity = little_ball
#+END_SRC
** TODO define some form of collision filtering
   for now, see:
   [[https://love2d.org/wiki/Contact:setEnabled]]
   [[https://love2d.org/wiki/Fixture:setFilterData]]


   
* links
** forum
   [[https://love2d.org/forums/viewtopic.php?f=5&t=86113&p=224718#p224718][forum]]
   
