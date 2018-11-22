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
   w.update = nil -- to use our custom update
   w.colliders = {}
   
   -- some functions defined here to use w without being passed it
   
   function w.collide(obja, objb, ...)
      -- collision event for two Colliders
      local function run_coll(obj1, obj2, ...)
	 if obj1.collide ~= nil then
	    local e = obj1:collide(obj2, ...)
	    if type(e) == 'function' then
	       w.collide_events[#w.collide_events] = e
	    end
	 end
      end

      if obja ~= nil and objb ~= nil then
	 run_coll(obja, objb, ...)
	 run_coll(objb, obja, ...)
      end
   end

   function w.collision(a, b, ...)
      -- objects that hit one another can have collide methods
      -- by default used as postSolve callback
      local obja = a:getUserData(a)
      local objb = b:getUserData(b)
      w.collide(obja, objb, ...)
   end

   
   function w.sensor_collision(a, b, ...)
      -- because sensor collision methods aren't called otherwise
      -- by default used as enter: callback
      local obja = a:getUserData(a)
      local objb = b:getUserData(b)
      if obja:isSensor() or objb:isSensor() then
	 w.collide(obja, objb, ...)
      end
   end

   w:setCallbacks(w.sensor_collision, nil, nil, w.collision)
   w.collide_events = {}
   
   return w
end


function World:draw(alpha, draw_over)
   -- draw the world
   --[[ 
      alpha: sets the alpha of the drawing, defaults to 1
      draw_over: draws the collision objects shapes even if their 
                .draw method is overwritten
   --]]
   for _, c in pairs(self.colliders) do
      c:draw(alpha)
      if draw_over then
	 love.graphics.setColor(1, 1, 1, alpha or 1)
	 c:__draw__()
      end
   end
end

-- callbacks

-- little utility functi on

-- TODO implement queryPolygonArea

function World:queryRectangleArea(x1, y1, x2, y2)
   local colls = {}
   local callback = function(fixture)
      table.insert(colls, fixture:getUserData())
      return true
   end
   self:queryBoundingBox(x1, y1, x2, y2, callback)
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
   for i, c in ipairs(colls) do
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

      if not isin then table.remove(colls, i) end
   end
   return colls
end

function World:update(dt)
   self._physworld:update(dt)
   for i, v in pairs(self.collide_events) do
      v()
      self.collide_events[i] = nil
   end
end

return World

