function CreateGalaxy(numStars, xcentre, ycentre, radius, seed)
  local galaxy={}
  galaxy.numStars = numStars or 1
  galaxy.xcentre = xcentre or 0.0
  galaxy.ycentre = ycentre or 0.0
  galaxy.radius = radius or 1.0
  galaxy.seed = seed or 1
  galaxy.etaGrav = 10.0
  galaxy.Gconst = 20000.0
  galaxy.stars={}

  galaxy.Init = function(self)
    love.math.setRandomSeed(self.seed)
    for e=1,self.numStars do
      local x,y,m,rsqd
      repeat
        m = love.math.random()
        x = radius*(1.0 - 2.0*love.math.random())
        y = radius*(1.0 - 2.0*love.math.random())
        rsqd = x*x + y*y
      until rsqd < radius*radius
      self.CreateStar(m, xcentre + x, ycentre + y)
    end
  end

  galaxy.CreateStar = function(m,x,y)
    local star={}
    star.m = m
    star.x = x
    star.y = y
    table.insert(galaxy.stars, star)
  end

  galaxy.CalculateForce = function(xship, yship)
    local ax = 0.0
    local ay = 0.0
    for e=1,#galaxy.stars do
      local m = galaxy.stars[e].m
      local x = galaxy.stars[e].x
      local y = galaxy.stars[e].y
      local dx = x - xship
      local dy = y - yship
      local distsqd = dx*dx + dy*dy + galaxy.etaGrav*galaxy.etaGrav
      local dist = math.sqrt(distsqd)
      local invdist = 1.0/dist
      local invdist3 = math.pow(invdist, 3.0)
      ax = ax + galaxy.Gconst*m*dx*invdist3
      ay = ay + galaxy.Gconst*m*dy*invdist3
      DEBUG.dist = dist
      DEBUG.ax = ax
      DEBUG.ay = ay
    end
    DEBUG.ax = ax
    DEBUG.ay = ay
    return ax,ay
  end

  galaxy.draw = function()
    love.graphics.setColor(255, 255, 255)
    for e=1,#galaxy.stars do
      local x = galaxy.stars[e].x
      local y = galaxy.stars[e].y
      love.graphics.circle("fill", x, y, 10.0*math.sqrt(galaxy.stars[e].m))
    end
  end

  return galaxy
end
