-- breezefield: init.lua
--[[
   implements Collider and World objects
   Collider wraps the basic functionality of shape, fixture, and body
   World wraps world, and provides automatic drawing simplified collisions
]]--



local bf = {}


local Collider = require('breezefield/collider')
local World = require('breezefield/world')


function bf.newWorld(...)
   return bf.World:new(...)
end

bf.Collider = Collider
bf.World = World

return bf
