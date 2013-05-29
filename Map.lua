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
      time('Build graph', function()
        local voronoi = Voronoi(self.points, nil, {
          0,
          0,
          self.size,
          self.size
        })
        self:buildGraph(voronoi)
        voronoi = nil
      end)
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
    buildGraph = function(self) end,
    generateRandomPoints = function(self) end,
    improveRandomPoints = function(self) end,
    redistributeElevations = function(self)
      self:landCorners(corners)
      for i, corner in ipairs(self.corners) do
        if q.ocean or q.coast then
          q.elevation = 0.0
        end
      end
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
