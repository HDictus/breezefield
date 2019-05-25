-- function used for both
local function set_funcs(mainobject, subobject)
   -- this function assigns functions of a subobject to a primary object
   --[[
      mainobject: the table to which to assign the functions
      subobject: the table whose functions to assign
      no output
   --]]
   for k, v in pairs(subobject.__index) do
      if k ~= '__gc' and k ~= '__eq' and k ~= '__index'
	 and k ~= '__tostring' and k ~= 'destroy' and k ~= 'type'
         and k ~= 'typeOf'and k ~= 'getUserData' and k ~= 'setUserData' then
	 mainobject[k] = function(mainobject, ...)
	    return v(subobject, ...)
	 end
      end
   end
end

return {set_funcs, love.physics, love.graphics}
