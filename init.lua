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
function set_funcs(mainobject, subobject)
   -- this function assigns functions of a subobject to a primary object
   --[[
      mainobject: the table to which to assign the functions
      subobject: the table whose functions to assign
      no output
   --]]
   for k, v in pairs(subobject.__index) do
      if k ~= '__gc' and k ~= '__eq' and k ~= '__index'
	 and k ~= '__tostring' and k ~= 'destroy' and k ~= 'type'
         and k ~= 'typeOf' and k ~= 'getUserData' k ~= 'setUserData' then
	 mainobject[k] = function(mainobject, ...)
	    return v(subobject, ...)
	 end
      end
   end
end

lp = love.physics
lg = love.graphics

--TODO how to just get collider, but only local collider
local Collider = require('breezefield/collider')
local World = require('breezefield/world')

function bf.newWorld(...)
   return bf.World:new(...)
end

bf.Collider = Collider
bf.World = World

return bf
