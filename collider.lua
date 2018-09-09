-- a Collider entity, wrapping shape, body, and fixtue
--[[
   the __draw__ method draws the physics object
   you can overwrite the :draw method to draw your sprites, shapes etc
   
   

]]--

phys=love.physics

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
      o.body = phys.newBody(world._physworld, x, y, "dynamic")
      o.shape = phys.newCircleShape(r)
   elseif collider_type == "Polygon" then
      o.body = phys.newBody(world._physworld, 0, 0, "dynamic")
      o.shape = phys.newPolygonShape(...)
   else
      error("unknown collider type: "..collider_type)
   end
   -- that's all I need for now

   o.collider_type = collider_type
   
   o.fixture = phys.newFixture(o.body, o.shape, 1)
   o.fixture:setUserData(o)
   
   set_funcs(o, o.body)
   set_funcs(o, o.shape)
   set_funcs(o, o.fixture)

   -- index by self for now
   world.colliders[o] = o
   return o
end

function Collider:__draw__()
   local mode = 'line'
   if self.collider_type == 'Circle' then
      love.graphics.circle(mode, self:getX(), self:getY(), self:getRadius())
   elseif self.collider_type == 'Polygon' then
      love.graphics.polygon(mode, self:getWorldPoints(self:getPoints()))
   end
end
   

function Collider:draw()
   self.__draw__()
end

function Collider:delete()
   self.body:delete()
   self.body:release()
   self.shape:release()
   self.fixture:release()
end

return Collider
