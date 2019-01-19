-- a Collider entity, wrapping shape, body, and fixtue
--[[
   the __draw__ method draws the physics object
   you can overwrite the :draw method to draw your sprites, shapes etc
   
   

]]--



local Collider = {}
Collider.__index = Collider

function Collider.new(world, collider_type, ...)
   local o = {}
   local args = {...}
   setmetatable(o, Collider)
   -- note that you will need to set static vs dynamic later
   if collider_type == 'Circle' then
      local x = args[1]
      local y = args[2]
      local r = args[3]
      o.body = lp.newBody(world._world, x, y, "dynamic")
      o.shape = lp.newCircleShape(r)	 
   elseif collider_type == "Polygon" then
      o.body = lp.newBody(world._world, 0, 0, "dynamic")
      o.shape = lp.newPolygonShape(...)
   else
      error("unknown collider type: "..collider_type)
   end
   -- that's all I need for now

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
   -- for k, v in pairs(self) do
   --    self[k] = nil
   -- end
end

function Collider:getSpatialIdentity() -- define this for circle
   if self.collider_type == 'Circle' then
      return self:getX(), self:getY(), self:getRadius()
   end
   if self.collider_type == 'Polygon' then
      return self:getWorldPoints(self:getPoints())
   end
end


return Collider
