-- breezefield: World.lua 
--[[
   World: has access to all the functions of love.physics.world
   additionally stores all Collider objects assigned to it in 
   self.colliders (as key-value pairs)
   can draw all its Colliders
   by default, calls :collide on any colliders in it for postSolve
   or for beginContact if the colliders are sensors
--]]


local World = {}
World.__index = World

function World:new(...)
   
   local w = {}
   setmetatable(w, self)
   w._physworld = phys.newWorld(...)
   set_funcs(w, w._physworld)
   w.colliders = {}
   w:setCallbacks(W.sensor_collision, nil, nil, W.collision)
   return w
end

function World:draw(alpha, draw_over)
   -- draw the world
   --[[ 
      alpha: sets the alpha of the drawing, defaults to 1
      draw_over: draws the collision objects shapes even if their 
                .draw method is overwritten
   --]]
   love.graphics.setColor(1, 1, 1, alpha or 1)
   for _, c in pairs(self.colliders) do
      c:draw()
      if draw_over() then
	 c:__draw__()
      end
   end
end

-- callbacks

-- little utility function
local function collide(obja, objb, ...)
   if obja.collide ~= nil then
      obja:collide(objb, ...)
   end
   if objb.collide ~= nil and not
   (obja:isDestroyed() or objb:isDestroyed()) then
      objb:collide(obja, ...)
   end
end

function World.collision(a, b, ...)
   -- objects that hit one another can have collude methods
   -- by default used as postSolve callback
   local obja = a:getMetaData(a)
   local objb = b:getMetaData(b)
   collide(obja, objb, ...)
end


function World:sensor_collision(a, b, ...)
   -- because sensor collision methods aren't called otherwise
   -- by default used as enter: callback
   local obja = a:getMetaData(a)
   local objb = b:getMetaData(b)
   if obja:isSensor() or objb:isSensor() then
      collide(obja, objb, ...)
end

return World
  
