local Point
do
  local _parent_0 = nil
  local _base_0 = {
    interpolate = function(a, b, strength)
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
      local lib_edges = voronoi.edges()
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
      voronoi = nil
    end,
    distributeMoisture = function(self)
      assignCornerMoisture()
      redistributeMoisture(landCorners(corners))
      return assignPolygonMoisture()
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
  return _class_0
end
