local bf = require('breezefield')


function love.load()
   world = bf.newWorld(0, 0, true)
   ball = bf.Collider.new(world, "Circle", 325, 325, 20)
   tri = bf.Collider.new(world, "Polygon", {500, 500, 550, 500, 525, 456.7})
   -- test circle fully in circle
   local circleincircle = world:queryCircleArea(325, 325, 30)
   assert(circleincircle[1] == ball and #circleincircle == 1)
   -- test circle intersects circle
   local circleintcircle = world:queryCircleArea(320, 325, 20)
   assert(circleintcircle[1] == ball and #circleintcircle == 1)
   -- test polygon in circle
   local polyincircle = world:queryCircleArea(525, 500, 100)
   assert(polyincircle[1] == tri and #polyincircle == 1)
   -- test polygon intersects circle
   local polyintcircle = world:queryCircleArea(525, 525, 26)
   assert(polyintcircle[1] == tri and #polyintcircle == 1)
   --test circle in polygon
   local circleinpoly = world:queryPolygonArea(300, 300, 300, 350, 350, 350, 350, 300)
   assert(circleinpoly[1] == ball and #circleinpoly == 1)
   -- test circle intersects polygon
   local circleintpoly = world:queryPolygonArea(310, 300, 310, 350, 350, 350, 350, 300)
   assert(circleintpoly[1] == ball and #circleintpoly == 1)
   -- test polygon inside polygon
   local polyinpoly = world:queryPolygonArea(499, 499, 499, 551, 551, 551, 551, 499)
   assert(polyinpoly[1] == tri and #polyinpoly == 1)
   -- test polygon intersects polygon
   local polyintpoly = world:queryPolygonArea(505, 505, 499, 551, 551, 551, 551, 499)
   assert(polyintpoly[1] == tri and #polyintpoly == 1)

   -- test region fully inside collider
   local circlearoundcircle = world:queryCircleArea(325, 325, 5)
   assert(circlearoundcircle[1] == ball and #circlearoundcircle == 1)

   -- test line collider
   local aline = bf.Collider.new(world, 'edge', 100, 100, 120, 120, 150, 150)
   local edgeinpoly = world:queryRectangleArea(90, 90, 125, 125)
   assert(edgeinpoly[1] == aline and #edgeinpoly == 1)

   local circleinlines = world:queryEdgeArea(300, 300, 350, 350)
   assert(circleinlines[1] == ball and #circleinlines == 1)
   
   print('tests passed')
   love.event.quit()
end

