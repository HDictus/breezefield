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
-- TODO: update test and tutorial
local Collider = require((...):gsub('world', '') .. 'collider')
local set_funcs, lp, lg, COLLIDER_TYPES = unpack(
   require((...):gsub('world', '') .. '/utils'))



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

local function check_vertices(vertices)
   if #vertices % 2 ~= 0 then
      error('vertices must be a multiple of 2')
   elseif #vertices < 4 then
      error('must have at least 2 vertices with x and y each')
   end
end

local function query_region(world, coll_type, args)
   local collider = world:newCollider(coll_type, args)
   collider:setSensor(true)
   world:_disable_callbacks()
   world:update(0)
   local colls = collider:collider_contacts(collider)
   collider:destroy()
   world:_enable_callbacks()
   return colls
end

function World:_disable_callbacks()
   self._callbacks = {self._world:getCallbacks()}
   self._world:setCallbacks()
end

function World:_enable_callbacks()
   self._world:setCallbacks(unpack(self._callbacks))
end

function World:queryPolygonArea(...)
   -- query an area enclosed by the lines connecting a series of points
   --[[
      inputs:
        x1, y1, x2, y2, ... floats, the x and y positions defining polygon
      outputs:
        colls: table, all Colliders intersecting the area
   --]]
   local vertices = {...}
   if type(vertices[1]) == 'table' then
      vertices = vertices[1]
   end
   check_vertices(vertices)
   return query_region(self, 'Polygon', vertices)
end

function World:queryCircleArea(x, y, r)
   -- get all colliders in a circle are
   --[[
      inputs: 
        x, y, r: floats, x, y and radius of circle
      outputs:
        colls: table: colliders in area
   ]]--
   return query_region(self, 'Circle', {x, y, r})
end

function World:queryEdgeArea(...)
   -- get all colliders along a (series of) line(s)
   --[[
      inputs:
        x1, y1, x2, y2, ... floats, the x and y positions defining lines
       outpts:
        colls: table: colliders intersecting these lines
   --]]
   local vertices = {...}
   if type(vertices[1]) == 'table' then
      vertices = vertices[1]
   end
   check_vertices(vertices)
   return  query_region(self, 'Edge', vertices)
end

function World:update(dt)
   -- update physics world
   self._world:update(dt)
   for i, v in pairs(self.collide_events) do
      v()
      self.collide_events[i] = nil
   end
end

--[[
create a new collider in this world

args:
   collider_type (string): the type of the collider (not case seinsitive). any of:
      circle, rectangle, polygon, edge, chain. 
   shape_arguments (table): arguments required to instantiate shape.
      circle: {x, y, radius}
      rectangle: {x, y, width height}
      polygon/edge/chain: {x1, y1, x2, y2, ...}
   table_to_use (optional, table): table to generate as the collider
]]--
function World:newCollider(collider_type, shape_arguments, table_to_use)
      
   local o = table_to_use or {}
   setmetatable(o, Collider)
   -- note that you will need to set static vs dynamic later
   local _collider_type = COLLIDER_TYPES[collider_type:upper()]
   assert(_collider_type ~= nil, "unknown collider type: "..collider_type)
   collider_type = _collider_type
   if collider_type == 'Circle' then
      local x, y, r = unpack(shape_arguments)
      o.body = lp.newBody(self._world, x, y, "dynamic")
      o.shape = lp.newCircleShape(r)
   elseif collider_type == "Rectangle" then
      local x, y, w, h = unpack(shape_arguments)
      o.body = lp.newBody(self._world, x, y, "dynamic")
      o.shape = lp.newRectangleShape(w, h)
      collider_type = "Polygon"
   else
      o.body = lp.newBody(self._world, 0, 0, "dynamic")
      o.shape = lp['new'..collider_type..'Shape'](unpack(shape_arguments))
   end

   o.collider_type = collider_type
   
   o.fixture = lp.newFixture(o.body, o.shape, 1)
   o.fixture:setUserData(o)
   
   set_funcs(o, o.body)
   set_funcs(o, o.shape)
   set_funcs(o, o.fixture)

   -- index by self for now
   o._world = self
   self.colliders[o] = o
   return o
end

return World
