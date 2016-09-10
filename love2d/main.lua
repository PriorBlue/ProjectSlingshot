require("lib/postshader")
require("lib/galaxy")

function love.load()
	love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	world = love.physics.newWorld(0, 0, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

	objects = {} -- table to hold all our physical objects

	--let's create a ball
	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, 650/2 - 100, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	objects.ball.shape = love.physics.newCircleShape(8) --the ball's shape has a radius of 20
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1) -- Attach fixture to body and give it a density of 1.
	objects.ball.fixture:setRestitution(0.9) --let the ball bounce

	--let's create a ball 2
	objects.ball2 = {}
	objects.ball2.body = love.physics.newBody(world, 650/2 + 200, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	objects.ball2.shape = love.physics.newCircleShape(128) --the ball's shape has a radius of 20
	objects.ball2.fixture = love.physics.newFixture(objects.ball2.body, objects.ball2.shape, 1) -- Attach fixture to body and give it a density of 1.
	objects.ball2.fixture:setRestitution(0.9) --let the ball bounce

	milkyWay = CreateGalaxy(100, 300.0, 2)
	milkyWay:Init()

end

function love.update(dt)
	world:update(dt) --this puts the world into motion

	local dx = objects.ball2.body:getX() - objects.ball.body:getX()
	local dy = objects.ball2.body:getY() - objects.ball.body:getY()

	local forceX = 0
	local forceY = 0

	if math.abs(dx) > 10 then
		local dx2 = dx / (dx + dy)

		forceX = math.min(50.0, 50.0 / (objects.ball2.body:getX() - objects.ball.body:getX())) * dx2
	end

	if math.abs(dy) > 10 then
		local dy2 = dy / (dx + dy)

		forceY = math.min(50.0, 50.0 / (objects.ball2.body:getY() - objects.ball.body:getY())) * dy2
	end

	objects.ball.body:applyForce(forceX, forceY)

	--here we are going to create some keyboard events
	if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
		objects.ball.body:applyForce(10, 0)
	elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
		objects.ball.body:applyForce(-10, 0)
	elseif love.keyboard.isDown("up") then --press the up arrow key to set the ball in the air
		objects.ball.body:applyForce(0, -10)
	elseif love.keyboard.isDown("down") then --press the up arrow key to set the ball in the air
		objects.ball.body:applyForce(0, 10)
	end
end

function love.draw()
	love.graphics.translate(-objects.ball.body:getX() + love.graphics.getWidth() * 0.5, -objects.ball.body:getY() + love.graphics.getHeight() * 0.5)
	
	love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
	love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())

	love.graphics.setColor(14, 47, 193) --set the drawing color to red for the ball
	love.graphics.circle("fill", objects.ball2.body:getX(), objects.ball2.body:getY(), objects.ball2.shape:getRadius())

  milkyWay.draw()
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

end
