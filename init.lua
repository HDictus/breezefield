-- breezefield: init.lua
--[[
   implements Collider and World objects
   Collider wraps the basic functionality of shape, fixture, and body
   World wraps world, and provides automatic drawing simplified collisions
]]--

-- TODO do something nice to make set/getFilterData more intuitive

local bf = {}

local phys = love.physics


-- function used for both
function set_funcs(collider, subobject)
   for k, v in pairs(subobject.__index) do
      if k ~= '__gc' and k ~= '__eq' and k ~= '__index' and k ~= '__tostring' and k ~= 'destroy' and k ~= 'type' and k ~= 'typeOf' then
	 collider[k] = function(collider, ...)
	    return v(subobject, ...)
	 end
      end
   end
end


local Collider = require('collider')
local World = require('world')

bf.Collider = Collider
bf.World = World

return bf
