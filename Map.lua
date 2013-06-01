local Point
do
  local _parent_0 = nil
  local _base_0 = {
    interpolate = function(a, b, strength)
      strength = strength or 0.5
      return Point((a.x + b.x) * strength, (a.y + b.y) * strength)
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x = x
      self.y = y
      return self
    end,
    __base = _base_0,
    __name = "Point",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Point = _class_0
end
local Center
do
  local _parent_0 = nil
  local _base_0 = { }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self)
      self.point = nil
      self.index = 0
      self.neighbors = { }
      self.boders = { }
      self.corners = { }
      return self
    end,
    __base = _base_0,
    __name = "Center",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Center = _class_0
end
local Corner
do
  local _parent_0 = nil
  local _base_0 = { }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self)
      return self
    end,
    __base = _base_0,
    __name = "Corner",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Corner = _class_0
end
local Edge
do
  local _parent_0 = nil
  local _base_0 = { }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self)
      self.river = 0
      return self
    end,
    __base = _base_0,
    __name = "Edge",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Edge = _class_0
end
local PM_PRNG
do
  local _parent_0 = nil
  local _base_0 = {
    prime = math.pow(2, 31) - 1,
    nextInt = function(self)
      return self:generate()
    end,
    nextDouble = function(self)
      return self:generate() / self.prime
    end,
    nextIntRange = function(self, min, max)
      min = min - 0.4999
      max = max + 0.4999
      return math.floor(0.5 + min + ((max - min) * self:nextDouble()))
    end,
    nextDoubleRange = function(self, min, max)
      return min + ((max - min) * self:nextDouble())
    end,
    generate = function(self)
      self.seed = (self.seed * 16807) % self.prime
      return self.seed
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, seed)
      self.seed = seed or 1
    end,
    __base = _base_0,
    __name = "PM_PRNG",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PM_PRNG = _class_0
end
local Map
do
  local _parent_0 = nil
  local _base_0 = {
    newIsland = function(self, _type, seed, variant)
      self.island_hape = IslandShape['make' + _type](seed)
      self.map_random.seed = variant
      return self
    end,
    reset = function(self)
      self.points = { }
      self.centers = { }
      self.corners = { }
      self.edges = { }
    end,
    go = function(self, first, last)
      local times = { }
      local time
      time = function(message, callback)
        local start = os.time()
        callback()
        return table.insert(times, {
          message,
          os.time() - start
        })
      end
      time('Reset', self.reset)
      time('Placing random points', self.generateRandomPoints)
      time('Improve points', self.improveRandomPoints)
      time('Build graph', self.buildGraph)
      time('Improve corners', self.improveCorners)
      table.insert(timer, {
        'Group',
        'Elevations'
      })
      time('Assign corner elevations', self.assignCornerElevations)
      time('Assign ocean coast and land', self.assignOceanCoastAndLand)
      time('Redistribute Elevations', self.redistributeElevations)
      time('Assign polygon Elevations', self.assignPolygonElevations)
      table.insert(timer, {
        'Group',
        'Moisture'
      })
      time('Calculate downslopes', self.calculateDownslopes)
      time('Determine watersheds', self.calculateWatersheds)
      time('Create rivers', self.createRivers)
      time('Distribute moisture', self.distributeMoisture)
      return time('Assign Biomes', self.assignBiomes)
    end,
    voronoi = function(self)
      return Voronoi(self.points, nil, {
        0,
        0,
        self.size,
        self.size
      })
    end,
    generateRandomPoints = function(self)
      for i = 1, self.num_points do
        local x = self.map_random.nextDoubleRange(10, self.size - 10)
        local y = self.map_random.nextDoubleRange(10, self.size - 10)
        self.points[i] = Point(x, y)
      end
      return self
    end,
    improveRandomPoints = function(self)
      for i = 1, self.num_lloyd_iterations do
        local voronoi = self:voronoi()
        for i, point in ipairs(points) do
          point.x = 0.0
          point.y = 0.0
          local region = voronoi:region(point)
          local region_count = 0
          for j, other_point in ipairs(region) do
            point.x = point.x + other_point.x
            point.y = point.y + other_point.y
            region_count = region_count + 1
          end
          point.x = point.x / region_count
          point.y = point.y / region_count
          region_count = nil
        end
        voronoi = nil
      end
      return self
    end,
    improveCorners = function(self)
      local new_corners = { }
      for i, corner in ipairs(self.corners) do
        if corner.border then
          new_corners[i] = corner.point
        else
          local point = Point(0.0, 0.0)
          local corner_count = 0
          for j, other_corner in ipairs(corner.touches) do
            point.x = point.x + other_corner.point.x
            point.y = point.y + other_corner.point.y
            corner_count = corner_count + 1
          end
          point.x = point.x / corner_count
          point.y = point.y / corner_count
          new_corners[i] = point
        end
      end
      for i, point in pairs(new_corners) do
        self.corners[i].point = point
      end
      for i, edge in ipairs(self.edges) do
        if edge.v0 and edge.v1 then
          edge.midpoint = Point.interpolate(edge.v0.point, edge.v1.point, 0.5)
        end
      end
    end,
    redistributeElevations = function(self)
      self:landCorners(corners)
      for i, corner in ipairs(self.corners) do
        if q.ocean or q.coast then
          q.elevation = 0.0
        end
      end
    end,
    landCorners = function(self)
      local locations = { }
      for i, corner in ipairs(self.corners) do
        if not corner.ocean and not corner.coast then
          table.insert(locations, corner)
        end
      end
      return locations
    end,
    buildGraph = function(self)
      local voronoi = self:voronoi()
      self.lib_edges = voronoi:edges()
      local center_lookup = { }
      local center_count = 0
      self.centers = { }
      for i, point in ipairs(self.points) do
        local center = Center()
        center.index = center_count
        center.point = point
        self.centers[center_count] = center
        center_lookup[point] = center
        center_count = center_count + 1
      end
      for i, center in ipairs(self.centers) do
        voronoi:region(center)
      end
      self.corner_map = { }
      local addToTable
      addToTable = function(tbl, element)
        if element ~= nil then
          for i, el in ipairs(tbl) do
            if el == element then
              return 
            end
          end
          return table.insert(tbl, element)
        end
      end
      for i, lib_edge in ipairs(self.lib_edges) do
        local dedge = lib_edge:delaunayLine()
        local vedge = lib_edge:voronoiEdge()
        local edge = Edge()
        edge.index = #self.edges
        table.insert(self.edges, edge)
        edge.midpoint = vedge.p0 and vedge.p1 and Point.interpolate(vedge.p0, vedge.p1)
        edge.v0 = self:makeCorner(vedge.p0)
        edge.v1 = self:makeCorner(vedge.p1)
        edge.d0 = center_lookup[dedge.p0]
        edge.d1 = center_lookup[dedge.p1]
        if (edge.d0 ~= nil) then
          table.insert(edge.d0.borders, edge)
        end
        if (edge.d1 ~= nil) then
          table.insert(edge.d1.border, edge)
        end
        if (edge.v0 ~= nil) then
          table.insert(edge.v0.protrude, edge)
        end
        if (edge.v1 ~= nil) then
          table.insert(edge.v1.protrude, edge)
        end
        if edge.d0 ~= nil and edge.d1 ~= nil then
          addToTable(edge.d0.neighbors, edge.d1)
          addToTable(edge.d1.neighbors, edge.d0)
        end
        if edge.v0 ~= nil and edge.v1 ~= nil then
          addToTable(edge.v0.adjacent, edge.v1)
          addToTable(edge.v1.adjacent, edge.v0)
        end
        if edge.d0 ~= nil then
          addToTable(edge.d0.adjacent, edge.v0)
          addToTable(edge.d0.adjacent, edge.v1)
        end
        if edge.d1 ~= nil then
          addToTable(edge.d1.adjacent, edge.v0)
          addToTable(edge.d1.adjacent, edge.v1)
        end
        if edge.v0 ~= nil then
          addToTable(edge.v0.adjacent, edge.d0)
          addToTable(edge.v0.adjacent, edge.d1)
        end
        if edge.v1 ~= nil then
          addToTable(edge.v1.adjacent, edge.d0)
          addToTable(edge.v1.adjacent, edge.d1)
        end
      end
    end,
    makeCorner = function(self, point)
      if point == nil then
        return 
      end
      for bucket = math.floor(point.x) - 1, 2 do
        for i, corner in ipairs(self.corner_map[bucket]) do
          local dx = point.x - self.corner.point.x
          local dy = point.y - self.corner.point.y
          if dx * dx + dy * dy < 0.000001 then
            return corner
          end
        end
      end
      local bucket = math.floor(point.x)
      if not self.corner_map[bucket] then
        self.corner_map[bucket] = { }
        self.corner_map._length = self.corner_map._length + 1
      end
      local coner = Corner()
      corner.index = corners._length
      corner.point = point
      corner.border = (point.x == 0 or point.x == self.size or point.y == 0 or point.y == self.size)
      corner.touches = { }
      corner.protrudes = { }
      corner.adjacent = { }
      corners[corner.index] = corner
      table.insert(self.corner_map[bucket], corner)
      return corner
    end,
    assignCornerElevations = function(self)
      local queue = { }
      local queue_count = 0
      for i, corner in ipairs(self.corners) do
        corner.water = not self:inside(corner.point)
        if corner.border then
          corner.elevation = 0.0
          queue_count = queue_count + 1
          queue[queue_count] = corner
        else
          corner.elevation = math.huge
        end
      end
      local first_corner = 1
      while queue_count > 0 do
        local corner = queue[first_corner]
        for i, adjacent in ipairs(corner.adjacent) do
          local new_elevation = 0.001 + corner.elevation
          if not corner.water and not adjacent.water then
            new_elevation = new_elevation + 1
          end
          if new_elevation < adjacent.elevation then
            adjacent.elevation = new_elevation
            queue_count = queue_count + 1
            queue[queue_count] = adjacent
          end
          first_corner = first_corner + 1
          queue_count = queue_count - 1
        end
      end
    end,
    redistributeElevations = function(self)
      local locations = self.points
      local scale_factor = 1.1
      local scale_factor_sqrt = math.sqrt(scale_factor)
      table.sort(locations, function(a, b)
        return a.elevation < b.elevation
      end)
      local locations_length = #locations
      for i, point in ipairs(locations) do
        local y = i / (locations.length(-1))
        local x = scale_factor_sqrt - math.sqrt(SCALE_FACTOR * (1 - y))
        if x > 1.0 then
          x = 1.0
        end
        point.elevation = x
      end
    end,
    redistributeMoisture = function(self, locations)
      table.sort(locations, function(a, b)
        return a.moisture < b.moisture
      end)
      local locations_length = #locations
      for i, point in ipairs(locations) do
        point.moisture = i / locations_length
      end
    end,
    assignOceanCoastAndLand = function(self)
      local queue = { }
      local queue_count = 0
      for i, point in ipairs(self.centers) do
        local num_water = 0
        for j, corner in ipairs(point.corners) do
          if corner.border then
            point.border = true
            p.ocean = true
            corner.water = true
            queue_count = queue_count + 1
            queue[queue_count] = point
          end
          if corner.water then
            num_water = num_water + 1
          end
        end
        point.water = (point.ocean or num_water >= #point.corners * self.lake_treshold)
      end
      local first_point = 1
      while queue_count > 0 do
        local point = queue[first_point]
        for i, neighbor in ipairs(point.neighbors) do
          if neighbor.water and not neighbor.ocean then
            neighbor.ocean = true
            queue_count = queue_count + 1
            queue[queue_count] = neighbor
          end
          local first_corner = first_corner + 1
          queue_count = queue_count - 1
        end
      end
      for i, point in ipairs(self.centers) do
        local num_ocean = 0
        local num_land = 0
        for j, neighbor in ipairs(point.neighbors) do
          if neighbor.ocean then
            num_ocean = num_ocean + 1
          elseif not neighbor.water then
            num_land = num_land + 1
          end
        end
        point.coast = num_land > 0 and num_ocean > 0
      end
      for i, point in ipairs(self.corners) do
        local num_ocean = 0
        local num_land = 0
        for j, neighbor in ipairs(point.touches) do
          if neighbor.ocean then
            num_ocean = num_ocean + 1
          elseif not neighbor.water then
            num_land = num_land + 1
          end
        end
        point.ocean = num_ocean == #point.touches
        point.coast = num_land > 0 and num_ocean > 0
        point.water = point.border or (num_land ~= #point.touches and not point.coast)
      end
    end,
    assignPolygonElevations = function(self)
      for i, point in ipairs(self.centers) do
        local sum_elevation = 0
        for j, corner in ipairs(point.corners) do
          sum_elevation = sum_elevation + point.elevation
        end
        point.elevation = sum_elevation / #point.corners
      end
    end,
    calculateDownslopes = function(self)
      for i, point in ipairs(self.corners) do
        local r = point
        for j, adjacent in ipairs(point.adjacent) do
          if adjacent.elevation < r.elevation then
            r = adjacent
          end
        end
        point.downslope = r
      end
    end,
    calculateWatersheds = function(self)
      for i, point in ipairs(self.corners) do
        point.watershed = point
        if not point.ocean and not point.coast then
          point.watershed = point.downslope
        end
      end
      for i = 0, math.floor(self.size / 5) do
        local changed = false
        for j, corner in ipairs(self.corners) do
          if not corner.ocean and not corner.coast and not corner.watershed.coast then
            local r = corner.downslope.watershed
            if not r.ocean then
              corner.watershed = r
            end
            changed = true
          end
        end
        if not changed then
          break
        end
      end
      for i, point in ipairs(self.corners) do
        point.watershed_size = 1 + (r.watershed_size or 0)
      end
    end,
    createRivers = function(self)
      local corners_length = #self.corners
      for i = 1, self.size / 2 do
        local _continue_0 = false
        repeat
          local point = self.corners[self.map_random:nextIntRange(1, corners_length)]
          if point.ocean or point.elevation < 0.3 or point.elevation > 0.9 then
            _continue_0 = true
            break
          end
          while not point.coast do
            if point == point.downslope then
              break
            end
            local edge = self:lookupEdgeFromCorner(point, point.downslope)
            edge.river = edge.river + 1
            point.river = 1 + (point.river or 0)
            point.downslope.river = 1 + (point.downslope.river or 0)
            point = point.downslope
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
    end,
    assignCornerMoisture = function(self)
      local queue = { }
      local queue_count = 0
      for i, point in ipairs(self.corners) do
        if (point.water or point.river > 0) and not point.ocean then
          point.moisture = 1.0
          if point.river > 0 then
            point.moisture = Math.min(3.0, (0.2 * point.river))
          end
          queue_count = queue_count + 1
          queue[queue_count] = point
        else
          point.moisture = 0.0
        end
      end
      local first_point = 1
      while queue_count > 0 do
        local point = queue[first_point]
        for i, adjacent in ipairs(point.adjacent) do
          local new_moisture = point.moisture * 0.8
          if new_moisture > adjacent.moisture then
            adjacent.moisture = new_moisture
            queue_count = queue_count + 1
            queue[queue_count] = adjacent
          end
          local first_corner = first_corner + 1
          queue_count = queue_count - 1
        end
      end
      for i, corner in ipairs(self.corners) do
        if corner.ocean or corner.coast then
          corner.moisture = 1.0
        end
      end
    end,
    assignPolygonMoisture = function(self)
      for i, point in ipairs(self.centers) do
        local sum = 0
        for j, corner in ipairs(point.corners) do
          sum = sum + point.moisture
        end
        point.moisture = sum / #point.moisture
      end
    end,
    distributeMoisture = function(self)
      assignCornerMoisture()
      redistributeMoisture(self:landCorners(corners))
      return assignPolygonMoisture()
    end,
    getBiome = function(self, point)
      local e = point.elevation
      local m = point.moisture
      if point.ocean then
        return "OCEAN"
      end
      if point.water then
        if e < 0.1 then
          return 'MARSH'
        end
        if e > 0.8 then
          return 'ICE'
        end
        return 'LAKE'
      end
      if e > 0.8 then
        if m > 0.5 then
          return 'SNOW'
        end
        if m > 0.33 then
          return 'TUNDRA'
        end
        if m > 0.16 then
          return 'BARE'
        end
        return 'SCORCHED'
      end
      if e > 0.6 then
        if m > 0.66 then
          return 'Taiga'
        end
        if m > 0.33 then
          return 'SHRUBLAND'
        end
        return 'TEMPERATE_DESERT'
      end
      if e > 0.3 then
        if m > 0.83 then
          return 'TROPICAL_RAIN_FOREST'
        end
        if m > 0.33 then
          return 'TROPICAL_SEASONAL_FOREST'
        end
        if m > 0.16 then
          return 'GRASSLAND'
        else
          return 'SUBTROPICAL_DESERT'
        end
      end
    end,
    assignBiomes = function(self)
      for i, point in ipairs(self.centers) do
        point.biome = self:getBiome(point)
      end
    end,
    lookupEdgeFromCenter = function(self, center, other_center)
      for i, edge in ipairs(center.borders) do
        if edge.d0 == other_center or edge.d1 == other_center then
          return edge
        end
      end
    end,
    lookupEdgeFromCorner = function(self, corner, other_corner)
      for i, edge in ipairs(polygon.protrudes) do
        if edge.v0 == other_polygon or edge.v1 == other_polygon then
          return edge
        end
      end
    end,
    inside = function(self, point)
      return IslandShape(Point(2 * (point.x / self.size - 0.5), 2 * (point.y / self.size - 0.5)))
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, size)
      self.num_points = 2000
      self.lake_treshold = 0.3
      self.num_lloyd_iterations = 2
      self.size = size
      self.island_shape = nil
      self.map_random = PM_PRNG()
      self:reset()
      return self
    end,
    __base = _base_0,
    __name = "Map",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Map = _class_0
end
local IslandShape
do
  local _parent_0 = nil
  local _base_0 = {
    makeRadial = function(seed)
      local ISLAND_FACTOR = 1.07
      do
        local _obj_0 = new(PM_PRNG())
        PM_PRNG = _obj_0.islandRandom
      end
      islandRandom.seed = seed
      local bumps = islandRandom.nextIntRange(1, 6)
      local startAngle = islandRandom.nextDoubleRange(0, 2 * math.PI)
      local dipAngle = islandRandom.nextDoubleRange(0, 2 * math.PI)
      local dipWidth = islandRandom.nextDoubleRange(0.2, 0.7)
      local _ = {
        inside = function(self, q)
          local angle = math.atan2(q.y, q.x)
          local length = 0.5 * (math.max(math.abs(q.x), math.abs(q.y)) + q.length)
          local r1 = 0.5 + 0.40 * math.sin(startAngle + bumps * angle + math.cos((bumps + 3) * angle))
          local r2 = 0.7 - 0.20 * math.sin(startAngle + bumps * angle - math.sin((bumps + 2) * angle))
          if math.abs(angle - dipAngle) < dipWidth or math.abs(angle - dipAngle + 2 * math.PI) < dipWidth or math.abs(angle - dipAngle - 2 * math.PI) < dipWidth then
            r1, r2 = 0.2, 0.2
          end
          return (length < r1 or (length > r1 * ISLAND_FACTOR and length < r2))
        end
      }
      return inside
    end,
    makePerlin = function(seed)
      local perlin = BitmapData(256, 256)
      perlin.perlinNoise(64, 64, 8, seed, false, true)
      return function(q)
        local c = (255 - perlin.getPixel(math.floor((q.x + 1) * 128), int((q.y + 1) * 128))) / 255.0
        return c > (0.3 + 0.3 * q.length * q.length)
      end
    end,
    makeSquare = function(seed)
      return function(q)
        return true
      end
    end,
    makeBlob = function(seed)
      return function(q)
        local eye1 = Point(q.x(-0.2, q.y / 2 + 0.2)).length < 0.05
        local eye2 = Point(q.x + 0.2, q.y / 2 + 0.2).length < 0.05
        local body = q.length < 0.8 - 0.18 * math.sin(5 * math.atan2(q.y, q.x))
        return body and not eye1 and not eye2
      end
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, _parent_0.__base)
  end
  local _class_0 = setmetatable({
    __init = function(self, ...)
      if _parent_0 then
        return _parent_0.__init(self, ...)
      end
    end,
    __base = _base_0,
    __name = "IslandShape",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil and _parent_0 then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0 and _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  IslandShape = _class_0
  return _class_0
end
