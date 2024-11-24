-- a Collider object, wrapping shape, body, and fixtue
local set_funcs, lp, lg, COLLIDER_TYPES = unpack(
   require((...):gsub('collider', '') .. '/utils'))

local Collider = {}
Collider.__index = Collider



function Collider.new(world, collider_type, ...)
   print("Collider.new is deprecated and may be removed in a later version. use world:newCollider instead")
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

function Collider:setDrawOrder(num)
   self._draw_order = num
   self._world._draw_order_changed = true
end

function Collider:getDrawOrder()
   return self._draw_order
end

function Collider:draw()
   self:__draw__()
end


function Collider:destroy()
   self._world:_remove(self)
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

--- Sets a collision class to the collider.
---@param name string
function Collider:setCollisionClass(name)
   local cls = self._world.collision_classes[name]

   assert(cls, "collision class '" .. tostring(name) .. "' does not exist")

   local cls_id = cls.id
   local cls_info = cls.info

   self.fixture:setCategory(cls_id)

   -- classes to be not inserted
   local doesnot_insert = {}

   if cls_info.except then
      for i=1, #cls_info.except do
         doesnot_insert[cls_info.except[i]] = true
      end
   end

   local to_ignore = {}
   if cls_info.ignores then
      -- if it's All then expand to every collision class that exist
      if cls_info.ignores == "All" then
         cls_info.ignores = {}
         for cls_name in pairs(self._world.collision_classes) do
            if cls_name ~= name  then
               cls_info.ignores[#cls_info.ignores+1] = cls_name
            end
         end
      end

      for i=1, #cls_info.ignores do
         local ignore_cls = cls_info.ignores[i]

         if not doesnot_insert[ignore_cls] then
            local id = self._world.collision_classes[ignore_cls].id

            table.insert(to_ignore, id)
         end
      end
   end

   self.collision_class = name

   self.fixture:setMask(unpack(to_ignore))
end

-- returns the collision class of the object
function Collider:getClass()
   return self.collision_class
end

return Collider
