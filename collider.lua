-- a Collider object, wrapping shape, body, and fixtue
local set_funcs, lp, lg, COLLIDER_TYPES = unpack(
   require((...):gsub('collider', '') .. '/utils'))

local Collider = {}
Collider.__index = Collider



function Collider.new(world, collider_type, ...)
   -- deprecated
   return world:newCollider(collider_type, {...})
end

function Collider:draw_type()
   if self.collider_type == 'Edge' or self.collider_type == 'Chain' then
      return 'line'
   end
   return self.collider_type:lower()
end

function Collider:__draw__()
   self._draw_type = self._draw_type or self:draw_type()
   local args
   if self._draw_type == 'line' then
      args = {self:getSpatialIdentity()}
   else
      args = {'line', self:getSpatialIdentity()}
   end
   love.graphics[self:draw_type()](unpack(args))
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

function Collider:collider_contacts()
   local contacts = self:getContacts()
   local colliders = {}
   for i, contact in ipairs(contacts) do
      if contact:isTouching() then
	 local f1, f2 = contact:getFixtures()
	 if f1 == self.fixture then
	    colliders[#colliders+1] = f2:getUserData()
	 else
	    colliders[#colliders+1] = f1:getUserData()
	 end
      end
   end
   return colliders
end

return Collider
