-- breezefield: World.lua 
--[[
   World: has access to all the functions of love.physics.world
   additionally stores all Collider objects assigned to it in 
   self.colliders (as key-value pairs)
   can draw all its Colliders
   by default, calls :collide on any colliders in it for postSolve
   or for beginContact if the colliders are sensors
--]]
-- TODO make updating work from here too
local phys=love.physics

Math = require('mlib/mlib')


local World = {}
World.__index = World
function World:new(...)
   
   local w = {}
   setmetatable(w, self)
   w._physworld = phys.newWorld(...)
   set_funcs(w, w._physworld)
   w.colliders = {}
   w:setCallbacks(w.sensor_collision, nil, nil, w.collision)
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
   -- objects that hit one another can have collide methods
   -- by default used as postSolve callback
   local obja = a:getUserData(a)
   local objb = b:getUserData(b)
   collide(obja, objb, ...)
end


function World.sensor_collision(a, b, ...)
   -- because sensor collision methods aren't called otherwise
   -- by default used as enter: callback
   local obja = a:getUserData(a)
   local objb = b:getUserData(b)
   if obja:isSensor() or objb:isSensor() then
      collide(obja, objb, ...)
   end
end

-- TODO implement queryPolygonArea

function World:queryRectangleArea(x1, y1, x2, y2)
   local colls = {}
   local callback = function(fixture)
      print(fixture)
      table.insert(colls, fixture:getUserData())
   end
   self:queryBoundingBox(x1, y1, x2, y2, callback)
   print(x1, y1, x2, y2)
   return colls
end

function World:queryCircleArea(x, y, r)
   -- get all colliders in a circle are
   local maxx = x + r
   local minx = x - r
   local maxy = y + r
   local miny = y - r
   local colls = self:queryRectangleArea(minx, miny,
					 maxx, maxy)
   -- NOTE for now use handy mlib functions, but maybe change later
   -- they are a little overkill
   -- ooh maybe take the chance to embed some c?
   print(#colls)
   for i, c in ipairs(colls) do
      print(i, getmetatable(c) == standard_bullet)
      local isin = false
      if c.collider_type == 'Circle' then
	 isin = 
	    Math.circle.getCircleIntersection(x, y, r, c:getX(),
					      c:getY(), c:getRadius())
      elseif c.collider_type == 'Polygon' then
	 isin =
	    Math.polygon.getCircleIntersection(
	       x, y, r,
	       {c:getWorldPoints(c:getPoints())})   
      else
	 error('unexpected collider type')
      end
      print(isin)
      if not isin then table.remove(colls, i) end
   end
   return colls
end

return World

