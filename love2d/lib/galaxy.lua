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

  galaxy.ship={}
  galaxy.shippath = nil


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

  galaxy.CreateShip = function(m,x,y,vx,vy)
    local ship = galaxy.ship
    ship.m = m
    ship.x = x
    ship.y = y
    ship.vx = vx or 0.0
    ship.vy = vy or 0.0
  end

  galaxy.CalculateAcceleration = function(xship, yship)
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

  galaxy.CalculateShipPath = function(rangePath)
    local ship = galaxy.ship
    local ax,ay,rsqd
    local x = galaxy.ship.x
    local y = galaxy.ship.y
    local vx = galaxy.ship.vx
    local vy = galaxy.ship.vy

    galaxy.shippath = {}
    table.insert(galaxy.shippath, x)
    table.insert(galaxy.shippath, y)

    repeat
      ax,ay = galaxy.CalculateAcceleration(x, y)
      local asqd = ax*ax + ay*ay
      local dt = 1.0*math.sqrt(galaxy.etaGrav / math.sqrt(asqd))
      x = x + vx*dt
      y = y + vy*dt
      vx = vx + ax*dt
      vy = vy + ay*dt
      rsqd = (x - ship.x)*(x - ship.x) + (y - ship.y)*(y - ship.y)
      table.insert(galaxy.shippath, x)
      table.insert(galaxy.shippath, y)
    until rsqd > rangePath*rangePath

  end

  galaxy.AdvanceShip = function(dt_full, ax_thrust, ay_thrust)
    local dt_sum = 0.0
    local ship = galaxy.ship
    repeat
      local ax,ay = galaxy.CalculateAcceleration(ship.x, ship.y)
      ax = ax + ax_thrust
      ay = ay + ay_thrust
      local asqd = ax*ax + ay*ay
      local dt = math.sqrt(galaxy.etaGrav / math.sqrt(asqd))
      dt = math.min(dt, 1.0000001*(dt_full - dt_sum))
      ship.x = ship.x + ship.vx*dt
      ship.y = ship.y + ship.vy*dt
      ship.vx = ship.vx + ax*dt
      ship.vy = ship.vy + ay*dt
      dt_sum = dt_sum + dt
    until dt_sum >= dt_full
  end

  galaxy.draw = function()
    love.graphics.setColor(255, 255, 255)
    for e=1,#galaxy.stars do
      local x = galaxy.stars[e].x
      local y = galaxy.stars[e].y
      love.graphics.circle("fill", x, y, 10.0*math.sqrt(galaxy.stars[e].m))
    end
    if galaxy.shippath then
      DEBUG.path = #galaxy.shippath
      love.graphics.setColor(0, 255, 0)
      love.graphics.line(galaxy.shippath)
    end
  end

  return galaxy
end
