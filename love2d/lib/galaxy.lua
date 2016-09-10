function CreateGalaxy(numStars, xcentre, ycentre, radius, seed)
  local galaxy={}
  galaxy.numStars = numStars or 1
  galaxy.xcentre = xcentre or 0.0
  galaxy.ycentre = ycentre or 0.0
  galaxy.radius = radius or 1.0
  galaxy.seed = seed or 1
  galaxy.etaGrav = 10.0
  galaxy.Gconst = 20000.0
  galaxy.timeMult = 0.1
  galaxy.stars={}

  galaxy.ship={}
  galaxy.shippath = nil
  galaxy.asteroidImg = love.graphics.newImage("gfx/asteroid_color.png")
  galaxy.planetImg = love.graphics.newImage("gfx/planet_256.png")
  galaxy.sunImg = love.graphics.newImage("gfx/planet_256.png")
  galaxy.shipImg = love.graphics.newImage("gfx/mothership_body_color.png")

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
    ship.tlast = 0.0
    ship.dt  = 0.0
    ship.m   = m
    ship.x   = x
    ship.y   = y
    ship.x0  = x
    ship.y0  = y
    ship.vx  = vx or 0.0
    ship.vy  = vy or 0.0
    ship.vx0 = vx or 0.0
    ship.vy0 = vy or 0.0
    ship.ax  = 0.0
    ship.ay  = 0.0
    ship.ax0 = 0.0
    ship.ay0 = 0.0
    ship.ax, ship.ay = galaxy.CalculateAcceleration(ship.x, ship.y)
  end

  galaxy.CalculateAcceleration = function(xship, yship)
    local ax = 0.0
    local ay = 0.0
    for e=1,#galaxy.stars do
      local m = galaxy.stars[e].m
      local rsmooth = m*galaxy.etaGrav
      local x = galaxy.stars[e].x
      local y = galaxy.stars[e].y
      local dx = x - xship
      local dy = y - yship
      local distsqd = dx*dx + dy*dy + rsmooth*rsmooth--galaxy.etaGrav*galaxy.etaGrav
      local dist = math.sqrt(distsqd)
      local invdist = 1.0/dist
      local invdist3 = math.pow(invdist, 3.0)
      ax = ax + galaxy.Gconst*m*dx*invdist3
      ay = ay + galaxy.Gconst*m*dy*invdist3
    end
    return ax,ay
  end

  galaxy.CalculateShipPath = function(rangePath)
    local ship = galaxy.ship
    local ax,ay,ax0,ay0,vx0,vy0,x0,y0
    local x = galaxy.ship.x0
    local y = galaxy.ship.y0
    local vx = galaxy.ship.vx0
    local vy = galaxy.ship.vy0
    local ax = ship.ax0
    local ay = ship.ay0

    local pathTot = 0.0 - math.sqrt((ship.x - ship.x0)*(ship.x - ship.x0) + (ship.y - ship.y0)*(ship.y - ship.y0))

    galaxy.shippath = {}
    table.insert(galaxy.shippath, ship.x)
    table.insert(galaxy.shippath, ship.y)

    --ax, ay = galaxy.CalculateAcceleration(x, y)

    repeat
      x0 = x
      y0 = y
      vx0 = vx
      vy0 = vy
      ax0 = ax
      ay0 = ay

      local asqd = ax*ax + ay*ay
      local dtLocal = galaxy.timeMult*math.sqrt(galaxy.etaGrav / math.sqrt(asqd))

      x = x0 + vx0*dtLocal + 0.5*ax0*dtLocal*dtLocal
      y = y0 + vy0*dtLocal + 0.5*ay0*dtLocal*dtLocal

      ax, ay = galaxy.CalculateAcceleration(x, y)
      vx = vx0 + 0.5*(ax0 + ax)*dtLocal
      vy = vy0 + 0.5*(ay0 + ay)*dtLocal

      pathTot = pathTot + math.sqrt((x - x0)*(x - x0) + (y - y0)*(y - y0))
      table.insert(galaxy.shippath, x)
      table.insert(galaxy.shippath, y)
    until pathTot > rangePath

  end

  galaxy.AdvanceShip = function(dt_full, gameTime, ax_thrust, ay_thrust)
    local ship = galaxy.ship
    local localTime = gameTime
    local dtLocal = ship.dt

    if ax_thrust == 0.0 and ay_thrust == 0.0 then
      dtLocal = ship.dt
    else
      ship.dt = gameTime - ship.tlast
      dtLocal = ship.dt
    end

    repeat

      if (ship.tlast + ship.dt < gameTime + dt_full) then

        ship.x = ship.x0 + ship.vx0*dtLocal + 0.5*ship.ax0*dtLocal*dtLocal
        ship.y = ship.y0 + ship.vy0*dtLocal + 0.5*ship.ay0*dtLocal*dtLocal

        ship.ax, ship.ay = galaxy.CalculateAcceleration(ship.x, ship.y)
        ship.ax = ship.ax + ax_thrust
        ship.ay = ship.ay + ay_thrust

        local asqd = ship.ax*ship.ax + ship.ay*ship.ay
        ship.dt = galaxy.timeMult*math.sqrt(galaxy.etaGrav / math.sqrt(asqd))

        ship.vx = ship.vx0 + 0.5*(ship.ax0 + ship.ax)*dtLocal
        ship.vy = ship.vy0 + 0.5*(ship.ay0 + ship.ay)*dtLocal

        ship.tlast = localTime
        ship.x0  = ship.x
        ship.y0  = ship.y
        ship.vx0 = ship.vx
        ship.vy0 = ship.vy
        ship.ax0 = ship.ax
        ship.ay0 = ship.ay

      else

        dtLocal = gameTime + dt_full - ship.tlast
        ship.x = ship.x0 + ship.vx0*dtLocal + 0.5*ship.ax0*dtLocal*dtLocal
        ship.y = ship.y0 + ship.vy0*dtLocal + 0.5*ship.ay0*dtLocal*dtLocal

      end

    until ship.tlast + ship.dt >= gameTime + dt_full
  end

  galaxy.draw = function()
    love.graphics.setColor(255, 255, 255)
    for e=1,#galaxy.stars do
      local x = galaxy.stars[e].x
      local y = galaxy.stars[e].y
		if galaxy.stars[e].m < 0.5 then
			love.graphics.draw(galaxy.asteroidImg, x, y, 0, 0.1*math.sqrt(galaxy.stars[e].m), 0.1*math.sqrt(galaxy.stars[e].m), galaxy.asteroidImg:getWidth() * 0.5, galaxy.asteroidImg:getHeight() * 0.5)
		else
			love.graphics.draw(galaxy.planetImg, x, y, 0, 0.2*math.sqrt(galaxy.stars[e].m), 0.2*math.sqrt(galaxy.stars[e].m), galaxy.planetImg:getWidth() * 0.5, galaxy.planetImg:getHeight() * 0.5)
		end
	  --love.graphics.circle("fill", x, y, 10.0*math.sqrt(galaxy.stars[e].m))
    end
    if galaxy.shippath then
      love.graphics.setColor(0, 255, 0)
      love.graphics.line(galaxy.shippath)
    end

	love.graphics.setColor(255, 255, 255) --set the drawing color to red for the ball
	love.graphics.draw(galaxy.shipImg, milkyWay.ship.x, milkyWay.ship.y, -math.atan2(milkyWay.ship.vx, milkyWay.ship.vy), -0.01, -0.01, galaxy.shipImg:getWidth() * 0.5, galaxy.shipImg:getHeight() * 0.5) --ship.body:getX(), ship.body:getY(), ship.shape:getRadius())
  end

  return galaxy
end
