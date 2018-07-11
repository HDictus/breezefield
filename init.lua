local bf = {}

phys = love.physics

Collider = {}
Collider.__index = Collider

function Collider.new(world, collider_type, ...)
   local o = {}
   local args = {...}
   -- note that you will need to set static vs dynamic later
   if collider_type == 'Circle' then
      o.body = phys.newBody(world._physworld, args[1], args[2], "dynamic")
      o.shape = phys.newCircleShape(...)
   elseif collider_type == "Polygon" then
      o.body = phys.newBody(world._physworld, 0, 0, "dynamic")
      o.shape = phys.newPolygonShape(...)
   end
   -- that's all I need for now
   o.fixture = phys.newFixture(o.body, o.shape)
   set_funcs(o, o.body)
   set_funcs(o, o.shape)
   set_funcs(o, o.fixture)
   return o
end


function set_funcs(collider, subobject)
   for k, v in pairs(subobject.__index) do
      if k ~= '__gc' and k ~= '__eq' and k ~= '__index' and k ~= '__tostring' and k ~= 'destroy' and k ~= 'type' and k ~= 'typeOf' then
	 collider[k] = function(collider, ...)
	    return v(subobject, ...)
	 end
      end
   end
end

bf.Collider = Collider
function bf.newWorld(...)
   local w = {}
   w._physworld = phys.newWorld(...)
   set_funcs(w, w._physworld)
   return w
end


return bf
