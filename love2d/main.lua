require("lib/postshader")
require("lib/galaxy")

function love.load()
	--love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	--world = love.physics.newWorld(0, 0, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

	--let's create a ball
	--ship = {}
	--ship.body = love.physics.newBody(world, 0.0, 0.0, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	--ship.shape = love.physics.newCircleShape(8) --the ball's shape has a radius of 20
	--ship.fixture = love.physics.newFixture(ship.body, ship.shape, 1) -- Attach fixture to body and give it a density of 1.
	--ship.fixture:setRestitution(0.9) --let the ball bounce

	milkyWay = CreateGalaxy(400, 0.0, 0.0, 3000.0, 2)
	milkyWay:Init()
	DEBUG = {}

	milkyWay.CreateShip(1.0, 0.0, 0.0, 0.5, 0.0)

	ZOOM = 1
	background = love.graphics.newImage("gfx/starfield_4K.png")

  gameTime = 0.0
	shipPathRange = 500.0

end

function love.update(dt)
	love.window.setTitle(love.timer.getFPS())
	--world:update(dt) --this puts the world into motion

  --ax,ay = milkyWay.CalculateAcceleration(ship.body:getX(), ship.body:getY())

  local ax = 0.0
	local ay = 0.0


	--ship.body:applyForce(ax, ay)
	--print(ax,ay)

	--here we are going to create some keyboard events
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then --press the right arrow key to push the ball to the right
		ax = ax + 10.0
	elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then --press the left arrow key to push the ball to the left
		ax = ax - 10.0
	elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then --press the up arrow key to set the ball in the air
		ay = ay - 10.0
	elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then --press the up arrow key to set the ball in the air
		ay = ay + 10.0
	end

	milkyWay.AdvanceShip(dt, gameTime, ax, ay)
	milkyWay.CalculateShipPath(shipPathRange)

	gameTime = gameTime + dt
end

function love.draw()
	love.graphics.draw(background)


	love.graphics.translate(-milkyWay.ship.x * ZOOM + love.graphics.getWidth() * 0.5, -milkyWay.ship.y * ZOOM + love.graphics.getHeight() * 0.5)
	love.graphics.scale(ZOOM, ZOOM)
  milkyWay.draw()

	love.graphics.origin()
	local ax,ay = milkyWay.CalculateAcceleration(milkyWay.ship.x, milkyWay.ship.y)
	local count = 0
	for k,v in pairs(DEBUG) do
		count = count + 1
    love.graphics.print(k .. "   " .. v, 16, count*16)
	end
	--love.graphics.print(math.floor(ax) .. "                        " .. math.floor(ay), 16, 16)
end

function love.keypressed(key, scancode, isrepeat)

end

function love.keyreleased(key)

end

function love.textinput(text)

end

function love.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

end

function love.mousemoved(x, y, dx, dy)

end

function love.wheelmoved(x, y)
	if y < 1 then
		ZOOM = ZOOM * 0.5
	else
		ZOOM = ZOOM * 2
	end
end
