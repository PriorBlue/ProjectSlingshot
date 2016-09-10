function CreateGalaxy(numStars, radius, seed)
  local galaxy={}
  galaxy.numStars = numStars or 1
  galaxy.radius = radius or 1.0
  galaxy.seed = seed or 1
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
      self.CreateStar(m,x,y)
    end
  end

  galaxy.CreateStar = function(m,x,y)
    local star={}
    star.m = m
    star.x = x
    star.y = y
    table.insert(galaxy.stars, star)
  end

  galaxy.draw = function()
    love.graphics.setColor(255, 255, 255)
    for e=1,#galaxy.stars do
      local x = galaxy.stars[e].x
      local y = galaxy.stars[e].y
      love.graphics.points(x,y)
    end
  end

  return galaxy
end
