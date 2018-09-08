local Collider = {}
Collider.__index = Collider

function Collider.new(world, collider_type, ...)
   local o = {}
   local args = {...}

   -- note that you will need to set static vs dynamic later
   if collider_type == 'Circle' then
      print(args[1], args[2])
      o.body = phys.newBody(world._physworld, args[1], args[2], "dynamic")
      o.shape = phys.newCircleShape(...)
   elseif collider_type == "Polygon" then
      o.body = phys.newBody(world._physworld, 0, 0, "dynamic")
      o.shape = phys.newPolygonShape(...)
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
      love.graphics.circle(mode, self:getX(), self:getY(), self:getRadius)
   elseif self.collider_type == 'Polygon' then
      love.graphics.polygon(mode, self:getWorldPoints(self:getPoints))
   end
end
   

function Collider:draw()
   self.__draw__()
end

