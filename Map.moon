-- Make a map out of a voronoi graph
-- Author (Actionscript): amitp@cs.stanford.edu
-- Authors (Lua): tomk32@tomk32.com

-- TODO: Figure out what to use for
--  * Voronoi
--  * Edge, Center and Corner have indexes. get rid of them?

class Point
  new: (x, y) =>
    @x = x
    @y = y
    @

  interpolate: (a, b, strength) ->
    strength = strength or 0.5
    return Point((a.x + b.x) * strength, (a.y + b.y) * strength)

class Center
  new: =>
    @point = nil
    @index = 0
    @neighbors = {}
    @boders = {}
    @corners = {}
    @

class Corner
  new: =>
    @

class Edge
  new: =>
    @river = 0
    @

class Map
  -- TODO: accept a table in the constructor
  -- FIXME: Allow width and height for oblong shapes
  new: (size) =>
    @num_points = 2000
    @lake_treshold = 0.3 -- 0...1
    @num_lloyd_iterations = 2
    @size = size -- it's a square

    @island_shape = nil

    -- TODO: better naming?
    @map_random = PM_PRNG()

    @reset()
    return @

  newIsland: (_type, seed, variant) =>
    @island_hape = IslandShape['make' + _type](seed)
    @map_random.seed = variant
    return @

  reset: =>
    @points = {}
    @centers = {}
    @corners = {}
    @edges = {}

  go: (first, last) =>

    -- Keep track of the time each step needs
    times = {}
    time = (message, callback) ->
      start = os.time()
      callback()
      table.insert(times, {message, os.time() - start})

    time('Reset', @reset)
    time('Placing random points', @generateRandomPoints)
    time('Improve points', @improveRandomPoints)
    time('Build graph', @buildGraph)
    time('Improve corners', @improveCorners)

    -- NOTE: The original had these four in one timer
    table.insert(timer, {'Group', 'Elevations'})
    time('Assign corner elevations', @assignCornerElevations)
    time('Assign ocean coast and land', @assignOceanCoastAndLand)
    time('Redistribute Elevations', @redistributeElevations)
    time('Assign polygon Elevations', @assignPolygonElevations)

    -- NOTE: The original had these six in one timer
    table.insert(timer, {'Group', 'Moisture'})
    time('Calculate downslopes', @calculateDownslopes)
    time('Determine watersheds', @calculateWatersheds)
    time('Create rivers', @createRivers)
    time('Distribute moisture', @distributeMoisture)

    time('Assign Biomes', @assignBiomes)

  voronoi: =>
    return Voronoi(@points, nil, {0, 0, @size, @size})

  generateRandomPoints: =>
    for i=1, @num_points
      x = @map_random.nextDoubleRange(10, @size - 10)
      y = @map_random.nextDoubleRange(10, @size - 10)
      @points[i] = Point(x, y)
        -- we keep a margin of 10 ot the border of the map
    @

  -- Improve the random set of points with Lloyd Relaxation.
  improveRandomPoints: =>
    -- We'd really like to generate "blue noise". Algorithms:
    -- 1. Poisson dart throwing: check each new point against all
    --     existing points, and reject it if it's too close.
    -- 2. Start with a hexagonal grid and randomly perturb points.
    -- 3. Lloyd Relaxation: move each point to the centroid of the
    --     generated Voronoi polygon, then generate Voronoi again.
    -- 4. Use force-based layout algorithms to push points away.
    -- 5. More at http://www.cs.virginia.edu/~gfx/pubs/antimony/
    -- Option 3 is implemented here. If it's run for too many iterations,
    -- it will turn into a grid, but convergence is very slow, and we only
    -- run it a few times.
    for i=1, @num_lloyd_iterations
      -- TODO: Do we really need a new Voronoi here?
      voronoi = @voronoi()
      for i, point in ipairs(points)
        point.x = 0.0
        point.y = 0.0
        region = voronoi\region(point)
        region_count = 0
        for j, other_point in ipairs(region)
          point.x += other_point.x
          point.y += other_point.y
          region_count += 1
        point.x = point.x / region_count
        point.y = point.y / region_count
        region_count = nil
      voronoi = nil
    @

  -- Although Lloyd relaxation improves the uniformity of polygon
  -- sizes, it doesn't help with the edge lengths. Short edges can
  -- be bad for some games, and lead to weird artifacts on
  -- rivers. We can easily lengthen short edges by moving the
  -- corners, but **we lose the Voronoi property**.  The corners are
  -- moved to the average of the polygon centers around them. Short
  -- edges become longer. Long edges tend to become shorter. The
  -- polygons tend to be more uniform after this step.
  improveCorners: =>
    -- First we compute the average of the centers next to each corner.
    -- We create a new array to not distort this averaging
    new_corners = {}
    for i, corner in ipairs(@corners)
      if corner.border
        new_corners[i] = corner.point
      else
        point = Point(0.0, 0.0)
        corner_count = 0
        for j, other_corner in ipairs(corner.touches)
          point.x += other_corner.point.x
          point.y += other_corner.point.y
          corner_count += 1
        point.x = point.x / corner_count
        point.y = point.y / corner_count
        new_corners[i] = point

    -- Move the corners to the new locations.
    for i, point in pairs(new_corners)
      @corners[i].point = point

    for i, edge in ipairs(@edges)
      if edge.v0 and edge.v1
        edge.midpoint = Point.interpolate(edge.v0.point, edge.v1.point, 0.5)

  -- Rescale elevations so that the highest is 1.0, and they're
  -- distributed well. We want lower elevations to be more common
  -- than higher elevations, in proportions approximately matching
  -- concentric rings. That is, the lowest elevation is the
  -- largest ring around the island, and therefore should more
  -- land area than the highest elevation, which is the very
  redistributeElevations: =>
    @landCorners(corners)
    -- Assign zero elevation to non-land corners
    for i, corner in ipairs(@corners)
      if q.ocean or q.coast
        q.elevation = 0.0

  -- Create an array of corners that are on land only, for use by
  -- algorithms that work only on land.  We return an array instead
  -- of a vector because the redistribution algorithms want to sort
  -- this array using Array.sortOn.
  landCorners: =>
    locations = {}
    for i, corner in ipairs(@corners)
      if not corner.ocean and not corner.coast
        table.insert(locations, corner) 
    return locations

  -- Create a graph structure from the Voronoi edge list. The
  -- methods in the Voronoi object are somewhat inconvenient for
  -- my needs, so I transform that data into the data I actually
  -- need: edges connected to the Delaunay triangles and the
  -- Voronoi polygons, a reverse map from those four points back
  -- to the edge, a map from these four points to the points
  -- they connect to (both along the edge and crosswise).
  --
  -- Build graph data structure in 'edges', 'centers', 'corners',
  -- based on information in the Voronoi results: point.neighbors
  -- will be a list of neighboring points of the same type (corner
  -- or center); point.edges will be a list of edges that include
  -- that point. Each edge connects to four points: the Voronoi edge
  -- edge.{v0,v1} and its dual Delaunay triangle edge edge.{d0,d1}.
  -- For boundary polygons, the Delaunay edge will have one null
  -- point, and the Voronoi edge may be null.
  buildGraph: =>
    voronoi = @voronoi()
    @lib_edges = voronoi\edges()
    center_lookup = {}

    -- Build Center objects for each of the points, and a lookup map
    -- to find those Center objects again as we build the graph
    center_count = 0
    -- NOTE: This `centers = {}` is not in the original
    @centers = {}
    for i, point in ipairs(@points)
      center = Center()
      center.index = center_count
      center.point = point

      @centers[center_count] = center
      center_lookup[point] = center
      center_count += 1

    -- Workaround for Voronoi lib bug: we need to call region()
    -- before Edges or neighboringSites are available
    -- TOOD: Necessary for lua?
    for i, center in ipairs(@centers)
      voronoi\region(center)

    -- The Voronoi library generates multiple Point objects for
    -- corners, and we need to canonicalize to one Corner object.
    -- To make lookup fast, we keep an array of Points, bucketed by
    -- x value, and then we only have to look at other Points in
    -- nearby buckets. When we fail to find one, we'll create a new
    -- Corner object.
    @corner_map = {}


    addToTable = (tbl, element) ->
      if element ~= nil
        for i, el in ipairs(tbl)
          if el == element
            return -- already in the table
        table.insert(tbl, element)

    for i, lib_edge in ipairs(@lib_edges)
      -- TODO
      dedge = lib_edge\delaunayLine()
      vedge = lib_edge\voronoiEdge()

      -- Fill the graph data. Make an Edge object corresponding to
      -- the edge from the voronoi library.
      edge = Edge()
      edge.index = #@edges
      table.insert(@edges, edge)
      edge.midpoint = vedge.p0 && vedge.p1 && Point.interpolate(vedge.p0, vedge.p1)

      -- Edges point to corners. Edges point to centers.
      edge.v0 = @makeCorner(vedge.p0)
      edge.v1 = @makeCorner(vedge.p1)
      edge.d0 = center_lookup[dedge.p0]
      edge.d1 = center_lookup[dedge.p1]

      -- Centers point to edges. Corners point to edges.
      if (edge.d0 ~= nil)
        table.insert(edge.d0.borders, edge)
      if (edge.d1 ~= nil)
        table.insert(edge.d1.border, edge)
      if (edge.v0 ~= nil)
        table.insert(edge.v0.protrude, edge)
      if (edge.v1 ~= nil)
        table.insert(edge.v1.protrude, edge)

      -- Centers point to centers
      if edge.d0 ~= nil && edge.d1 ~= nil
        addToTable(edge.d0.neighbors, edge.d1)
        addToTable(edge.d1.neighbors, edge.d0)

      -- Corners point to corners
      if edge.v0 ~= nil && edge.v1 ~= nil
        addToTable(edge.v0.adjacent, edge.v1)
        addToTable(edge.v1.adjacent, edge.v0)

      -- Centers point to corners
      if edge.d0 ~= nil
        addToTable(edge.d0.adjacent, edge.v0)
        addToTable(edge.d0.adjacent, edge.v1)
      if edge.d1 ~= nil
        addToTable(edge.d1.adjacent, edge.v0)
        addToTable(edge.d1.adjacent, edge.v1)

      -- Corners point to centers
      if edge.v0 ~= nil
        addToTable(edge.v0.adjacent, edge.d0)
        addToTable(edge.v0.adjacent, edge.d1)
      if edge.v1 ~= nil
        addToTable(edge.v1.adjacent, edge.d0)
        addToTable(edge.v1.adjacent, edge.d1)

  makeCorner: (point) =>
    if point == nil
      return
    -- NOTE: ActionScript uses int, not sure if that is rounding dow
    for bucket = math.floor(point.x) - 1, 2
      for i, corner in ipairs(@corner_map[bucket])
        dx = point.x - @corner.point.x
        dy = point.y - @corner.point.y
        if dx * dx + dy * dy < 0.000001
          return corner

     -- NOTE: We are keeping track of the number of buckets
     bucket = math.floor(point.x)
     if not @corner_map[bucket]
       @corner_map[bucket] = {}
       @corner_map._length += 1
     coner = Corner()

     corner.index = corners._length
     corner.point = point
     corner.border = (point.x == 0 or point.x == @size or point.y == 0 or point.y == @size)
     corner.touches = {}
     corner.protrudes = {}
     corner.adjacent = {}
     corners[corner.index] = corner
     table.insert(@corner_map[bucket], corner)
     -- end makeCorner
     return corner





  -- Determine moisture at corners, starting at rivers
  -- and lakes, but not oceans. Then redistribute
  -- moisture to cover the entire range evenly from 0.0
  -- to 1.0. Then assign polygon moisture as the average
  -- of the corner moisture.
  distributeMoisture: =>
    assignCornerMoisture()
    redistributeMoisture(landCorners(corners))
    assignPolygonMoisture()

