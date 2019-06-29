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

local set_funcs, lp, lg = unpack(require("breezefield/utils"))
local mlib = require('mlib/mlib')
-- NOTE for now use handy mlib functions, but maybe change later
-- they are a little overkill
-- ooh maybe take the chance to practice c and lua integration?

-- a helper for getting intersections from mlib

local function checkIntersections(colls, intersection_type, ...)
   -- iterate through a table to see if they intersect
   local function get_mlib_intersection(collider, type_2, ...)
      local type_1 = collider.collider_type
      local func =  mlib[type_1:lower()]['get'..type_2..'Intersection']
      -- awkward
      -- would prefer if type_1 args were consistenly required first
      -- messing with these args is awkward
      -- is this really cleaner than individual calls within functions?
      -- TODO send a pull request to mlib?
      if type_1 == 'Circle' then
	 local args = {collider:getSpatialIdentity()}
	 for i, v in ipairs({...}) do
	    args[#args+1] = v
	 end
	 return func(unpack(args))
	 -- will work whether type_2 is polygon or Circle
      else
	 local args = {...}
	 args[#args+1] = {collider:getSpatialIdentity()}
	 return func(unpack(args))
	 -- getPolygonPolygonIntersection requires tables
	 -- getPolygonCircleIntersection wants x,y,r and then table
      end
   end

   for i, c in ipairs(colls) do
      isin = get_mlib_intersection(c, intersection_type, ...)
      if not isin then table.remove(colls, i) end
   end
   return colls
end

---------------------------------------------------


local World = {}
World.__index = World
function World:new(...)
   -- create a new physics world
   --[[
      inputs: (same as love.physics.newWorld)
      xg: float, gravity in x direction
      yg: float, gravity in y direction
      sleep: boolean, whether bodies can sleep
      outputs:
      w: bf.World, the created world
   ]]--

   local w = {}
   setmetatable(w, self)
   w._world = lp.newWorld(...)
   set_funcs(w, w._world)
   w.update = nil -- to use our custom update
   w.colliders = {}

   -- some functions defined here to use w without being passed it

   function w.collide(obja, objb, coll_type, ...)
      -- collision event for two Colliders
      local function run_coll(obj1, obj2, ...)
	 if obj1[coll_type] ~= nil then
	    local e = obj1[coll_type](obj1, obj2, ...)
	    if type(e) == 'function' then
	       w.collide_events[#w.collide_events+1] = e
	    end
	 end
      end

      if obja ~= nil and objb ~= nil then
	 run_coll(obja, objb, ...)
	 run_coll(objb, obja, ...)
      end
   end

   function w.enter(a, b, ...)
      return w.collision(a, b, 'enter', ...)
   end
   function w.exit(a, b, ...)
      return w.collision(a, b, 'exit', ...)
   end
   function w.preSolve(a, b, ...)
      return w.collision(a, b, 'preSolve', ...)
   end
   function w.postSolve(a, b, ...)
      return w.collision(a, b, 'postSolve', ...)
   end

   function w.collision(a, b, ...)
      -- objects that hit one another can have collide methods
      -- by default used as postSolve callback
      local obja = a:getUserData(a)
      local objb = b:getUserData(b)
      w.collide(obja, objb, ...)
   end

   w:setCallbacks(w.enter, w.exit, w.preSolve, w.postSolve)
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
   local color = {love.graphics.getColor()}
   for _, c in pairs(self.colliders) do
      love.graphics.setColor(1, 1, 1, alpha or 1)
      c:draw(alpha)
      if draw_over then
	 love.graphics.setColor(1, 1, 1, alpha or 1)
	 c:__draw__()
      end
   end
   love.graphics.setColor(color)
end

function World:queryRectangleArea(x1, y1, x2, y2)
   -- query a bounding-box aligned area for colliders
   --[[
      inputs:
      x1, y1, x2, y2: floats, the x and y coordinates of two points
      outputs:
      colls: table, all colliders in bounding box
   --]]

   local colls = {}
   local callback = function(fixture)
      table.insert(colls, fixture:getUserData())
      return true
   end
   self:queryBoundingBox(x1, y1, x2, y2, callback)
   return colls
end

function World:queryPolygonArea(...)
   -- query an area enclosed by the lines connecting a series of points
   --[[
      inputs:
      (x, y, ) X 3+: floats, x and y coordinates of the points defining polygon
      outputs:
      colls: table, all Colliders intersecting the area
   --]]
   local vertices = {...}
   if type(vertices[1]) == table then
      vertices = vertices[1]
   end

   local function add_coordinate(value, coords, max, min)
      coords[#coords+1] = value
      if value > max then max = value
      elseif value < min then min = value end
      return coords, max, min
   end

   local x = {}
   local maxx = 0
   local minx = 0
   local y = {}
   local maxy = 0
   local miny = 0
   for i, v in ipairs(vertices) do
      if i % 2 == 0 then
	 x, maxx, minx = add_coordinate(v, x, maxx, minx)
      else
	 y, maxy, miny = add_coordinate(v, y, maxy, miny)
      end
   end
   local colls = self:queryRectangleArea(minx, miny, maxx, maxy)
   return checkIntersections(colls, 'Polygon', vertices)
end

function World:queryCircleArea(x, y, r)
   -- get all colliders in a circle are
   --[[
      inputs: 
      x, y, r: floats, x, y and radius of circle
      outputs:
      colls: table: colliders in area
   ]]--
   local maxx = x + r
   local minx = x - r
   local maxy = y + r
   local miny = y - r
   local colls = self:queryRectangleArea(minx, miny,
					 maxx, maxy)
   return checkIntersections(colls, 'Circle', x, y, r)
end



function World:update(dt)
   -- update physics world
   self._world:update(dt)
   for i, v in pairs(self.collide_events) do
      v()
      self.collide_events[i] = nil
   end
end

return World
