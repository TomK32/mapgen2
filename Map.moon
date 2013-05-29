-- Make a map out of a voronoi graph
-- Author (Actionscript): amitp@cs.stanford.edu
-- Authors (Lua): tomk32@tomk32.com

-- NOTE: 
--   * method names are using camelcase
--   * attributes names are using underscore


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
    time 'Build graph', ->
      voronoi = Voronoi(@points, nil, {0, 0, @size, @size})
      @buildGraph(voronoi)
      voronoi = nil
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

  -- Create a graph structure from the Voronoi edge list. The
  -- methods in the Voronoi object are somewhat inconvenient for
  -- my needs, so I transform that data into the data I actually
  -- need: edges connected to the Delaunay triangles and the
  -- Voronoi polygons, a reverse map from those four points back
  -- to the edge, a map from these four points to the points
  -- they connect to (both along the edge and crosswise).
  buildGraph: =>

  generateRandomPoints: =>

  improveRandomPoints: =>

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

  -- Determine moisture at corners, starting at rivers
  -- and lakes, but not oceans. Then redistribute
  -- moisture to cover the entire range evenly from 0.0
  -- to 1.0. Then assign polygon moisture as the average
  -- of the corner moisture.
  distributeMoisture: =>
    assignCornerMoisture()
    redistributeMoisture(landCorners(corners))
    assignPolygonMoisture()

