-- a Collider object, wrapping shape, body, and fixtue
local set_funcs, lp, lg = unpack(require("breezefield/utils"))

local Collider = {}
Collider.__index = Collider


local COLLIDER_TYPES = {
   CIRCLE = "Circle",
   CIRC = "Circle",
   RECTANGLE = "Rectangle",
   RECT = "Rectangle",
   POLYGON = "Polygon",
   POLY = "Polygon",
   LINE = "Line",
   CHAIN = "Chain"
}

function Collider.new(world, collider_type, ...)
   local o = {}
   local args = {...}
   setmetatable(o, Collider)
   -- note that you will need to set static vs dynamic later

   local _collider_type = COLLIDER_TYPES[collider_type:upper()]
   assert(_collider_type ~= nil, "unknown collider type: "..collider_type)
   collider_type = _collider_type
   if collider_type == 'Circle' then
      local x, y, r = unpack(args)
      o.body = lp.newBody(world._world, x, y, "dynamic")
      o.shape = lp.newCircleShape(r)
   elseif collider_type == "Rectangle" then
      local x, y, w, h = unpack(args)
      o.body = lp.newBody(world._world, x, y, "dynamic")
      o.shape = lp.newRectangleShape(w, h)
      collider_type = "Polygon"
   else
      o.body = lp.newBody(world._world, 0, 0, "dynamic")
      o.shape = lp['new'..collider_type..'Shape'](...)
   end

   o.collider_type = collider_type
   
   o.fixture = lp.newFixture(o.body, o.shape, 1)
   o.fixture:setUserData(o)
   
   set_funcs(o, o.body)
   set_funcs(o, o.shape)
   set_funcs(o, o.fixture)

   -- index by self for now
   o._world = world
   world.colliders[o] = o
   return o
end

function Collider:__draw__()
   local mode = 'line'
   love.graphics[self.collider_type:lower()](mode, self:getSpatialIdentity())
end

function Collider:draw()
   self:__draw__()
end


function Collider:destroy()
   self._world.colliders[self] = nil
   self.fixture:setUserData(nil)
   self.fixture:destroy()
   self.body:destroy()
end

function Collider:getSpatialIdentity()
   if self.collider_type == 'Circle' then
      return self:getX(), self:getY(), self:getRadius()
   else
      return self:getWorldPoints(self:getPoints())
   end
end


return Collider
