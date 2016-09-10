--[[
The MIT License (MIT)

Copyright (c) 2014 Marcus Ihde

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

LOVE_POSTSHADER_BUFFER_RENDER = love.graphics.newCanvas()
LOVE_POSTSHADER_BUFFER_BACK = love.graphics.newCanvas()
LOVE_POSTSHADER_BUFFER_BACK2 = love.graphics.newCanvas()
LOVE_POSTSHADER_BUFFER_GLOW = love.graphics.newCanvas()
LOVE_POSTSHADER_BUFFER_GLOW2 = love.graphics.newCanvas()
LOVE_POSTSHADER_LAST_BUFFER = nil

LOVE_POSTSHADER_BLURV = love.graphics.newShader("shader/blurv.glsl")
LOVE_POSTSHADER_BLURH = love.graphics.newShader("shader/blurh.glsl")
LOVE_POSTSHADER_WINDV = love.graphics.newShader("shader/windv.glsl")
LOVE_POSTSHADER_WINDH = love.graphics.newShader("shader/windh.glsl")
LOVE_POSTSHADER_CONTRAST = love.graphics.newShader("shader/contrast.glsl")
LOVE_POSTSHADER_CHROMATIC_ABERRATION = love.graphics.newShader("shader/chromatic_aberration.glsl")
LOVE_POSTSHADER_FOUR_COLOR = love.graphics.newShader("shader/four_colors.glsl")
LOVE_POSTSHADER_MONOCHROM = love.graphics.newShader("shader/monochrom.glsl")
LOVE_POSTSHADER_SCANLINES = love.graphics.newShader("shader/scanlines.glsl")
LOVE_POSTSHADER_TILT_SHIFT = love.graphics.newShader("shader/tilt_shift.glsl")
LOVE_POSTSHADER_TRANSLATE = false
LOVE_POSTSHADER_TRANSLATE_X = 0
LOVE_POSTSHADER_TRANSLATE_Y = 0
LOVE_POSTSHADER_TRANSLATE_SCALE = 1
LOVE_POSTSHADER_TRANSLATE_ROTATION = 0

love.postshader = {}

love.postshader.setBuffer = function(buffer)
	if buffer == "back" then
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
	elseif buffer == "glow" then
		LOVE_POSTSHADER_BUFFER_GLOW:clear(0,0,0)
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_GLOW)
	else
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_RENDER)
	end
	LOVE_POSTSHADER_LAST_BUFFER = love.graphics.getCanvas()
end

love.postshader.setTranslation = function(x, y)
	LOVE_POSTSHADER_TRANSLATE_X = x
	LOVE_POSTSHADER_TRANSLATE_Y = y
	LOVE_POSTSHADER_TRANSLATE = true
end

love.postshader.setScale = function(scale)
	LOVE_POSTSHADER_TRANSLATE_SCALE = scale
	LOVE_POSTSHADER_TRANSLATE = true
end

love.postshader.setRotation = function(rotation)
	LOVE_POSTSHADER_TRANSLATE_ROTATION = rotation
	LOVE_POSTSHADER_TRANSLATE = true
end

love.postshader.addEffect = function(shader, ...)
	args = {...}
	LOVE_POSTSHADER_LAST_BUFFER = love.graphics.getCanvas()

	if LOVE_POSTSHADER_TRANSLATE then
		love.graphics.pop()
	end

	love.graphics.setColor(255, 255, 255)
	if shader ~= "glow" then
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
	end
	love.graphics.setBlendMode("alpha")

	if shader == "bloom" then
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)
		
		-- Bloom Shader
		LOVE_POSTSHADER_BLURV:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_BLURH:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_BLURV:send("steps", args[1] or 2.0)
		LOVE_POSTSHADER_BLURH:send("steps", args[1] or 2.0)

		love.graphics.setShader(LOVE_POSTSHADER_BLURV)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)

		love.graphics.setShader(LOVE_POSTSHADER_BLURH)
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK2)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)

		love.graphics.setShader(LOVE_POSTSHADER_CONTRAST)
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK2)

		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK2)
		love.graphics.setShader()
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.setBlendMode("add")
		love.graphics.setColor(255, 255, 255, (args[2] or 0.25) * 255)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.setBlendMode("alpha")
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK2)
	elseif shader == "blur" then
		-- Blur Shader
		LOVE_POSTSHADER_BLURV:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_BLURH:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_BLURV:send("steps", args[1] or 2.0)
		LOVE_POSTSHADER_BLURH:send("steps", args[2] or 2.0)

		love.graphics.setShader(LOVE_POSTSHADER_BLURV)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)

		love.graphics.setShader(LOVE_POSTSHADER_BLURH)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)
	elseif shader == "wind" then
		-- Wind Shader
		LOVE_POSTSHADER_WINDV:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_WINDH:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_WINDV:send("steps", args[1] or 2.0)
		LOVE_POSTSHADER_WINDH:send("steps", args[2] or 2.0)

		love.graphics.setShader(LOVE_POSTSHADER_WINDV)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)

		love.graphics.setShader(LOVE_POSTSHADER_WINDH)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)
	elseif shader == "glow" then
		-- Blur Shader
		LOVE_POSTSHADER_BLURV:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_BLURH:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_BLURV:send("steps", args[1] or 2.0)
		LOVE_POSTSHADER_BLURH:send("steps", args[2] or 2.0)

		LOVE_POSTSHADER_BUFFER_GLOW2:clear()
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_GLOW2)

		love.graphics.setBlendMode("additive")
		love.graphics.setShader(LOVE_POSTSHADER_BLURV)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_GLOW)

		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_GLOW)

		love.graphics.setShader(LOVE_POSTSHADER_BLURH)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_GLOW2)

		love.graphics.setCanvas(LOVE_POSTSHADER_LAST_BUFFER)
		love.graphics.setShader()
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_GLOW)
	elseif shader == "chromatic" then
		-- Chromatic Shader
		LOVE_POSTSHADER_CHROMATIC_ABERRATION:send("redStrength", {args[1] or 0.0, args[2] or 0.0})
		LOVE_POSTSHADER_CHROMATIC_ABERRATION:send("greenStrength", {args[3] or 0.0, args[4] or 0.0})
		LOVE_POSTSHADER_CHROMATIC_ABERRATION:send("blueStrength", {args[5] or 0.0, args[6] or 0.0})
		love.graphics.setShader(LOVE_POSTSHADER_CHROMATIC_ABERRATION)
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)
	elseif shader == "4colors" then
		-- 4 Color Shader
		if #args ~= 4 then
			args = {}
			args[1] = {15, 56, 15}
			args[2] = {48, 98, 48}
			args[3] = {139, 172, 15}
			args[4] = {155, 188, 15}
		end

		for i = 1, 4 do
			for k = 1, 3 do
				args[i][k] = args[i][k] / 255.0
			end
		end
		LOVE_POSTSHADER_FOUR_COLOR:send("palette", args[1], args[2], args[3], args[4])
		love.graphics.setShader(LOVE_POSTSHADER_FOUR_COLOR)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)
	elseif shader == "monochrom" then
		-- Monochrom Shader
		for i = 1, 3 do
			if args[i] then
				args[i] = args[i] / 255.0
			end
		end
		LOVE_POSTSHADER_MONOCHROM:send("tint", {args[1] or 1.0, args[2] or 1.0, args[3] or 1.0})
		LOVE_POSTSHADER_MONOCHROM:send("fudge", args[4] or 0.1)
		LOVE_POSTSHADER_MONOCHROM:send("time", args[5] or love.timer.getTime())
		love.graphics.setShader(LOVE_POSTSHADER_MONOCHROM)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)
	elseif shader == "scanlines" then
		-- Scanlines Shader
		LOVE_POSTSHADER_SCANLINES:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_SCANLINES:send("strength", args[1] or 1.0)
		LOVE_POSTSHADER_SCANLINES:send("time", 0)
		love.graphics.setShader(LOVE_POSTSHADER_SCANLINES)
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_RENDER)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.setShader()
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)
	elseif shader == "tiltshift" then
		-- Blur Shader
		LOVE_POSTSHADER_BLURV:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_BLURH:send("screenSize", {love.graphics.getWidth(), love.graphics.getHeight()})
		LOVE_POSTSHADER_BLURV:send("steps", args[1] or 2.0)
		LOVE_POSTSHADER_BLURH:send("steps", args[1] or 2.0)

		love.graphics.setShader(LOVE_POSTSHADER_BLURV)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_RENDER)

		love.graphics.setShader(LOVE_POSTSHADER_BLURH)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)

		LOVE_POSTSHADER_TILT_SHIFT:send("imgBuffer", LOVE_POSTSHADER_BUFFER_RENDER)
		love.graphics.setShader(LOVE_POSTSHADER_TILT_SHIFT)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK)
	end

	if shader ~= "bloom" and shader ~= "glow" then
		love.graphics.setBlendMode("alpha")
		love.graphics.setCanvas(LOVE_POSTSHADER_BUFFER_BACK)
		love.graphics.setShader()
		love.graphics.setColor(255, 255, 255, 63)
		love.graphics.draw(LOVE_POSTSHADER_BUFFER_BACK2)
	end

	if LOVE_POSTSHADER_TRANSLATE then
		love.graphics.push()
		love.graphics.translate(love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
		love.graphics.scale(LOVE_POSTSHADER_TRANSLATE_SCALE)
		love.graphics.rotate(LOVE_POSTSHADER_TRANSLATE_ROTATION)
		love.graphics.translate(LOVE_POSTSHADER_TRANSLATE_X, LOVE_POSTSHADER_TRANSLATE_Y)
	end
end

love.postshader.draw = function()
	if LOVE_POSTSHADER_LAST_BUFFER then
		love.graphics.setBackgroundColor(0, 0, 0)
		love.graphics.setBlendMode("alpha")
		love.graphics.setCanvas()
		love.graphics.setShader()
		love.graphics.setColor(255, 255, 255)
		if LOVE_POSTSHADER_TRANSLATE then
			love.graphics.pop()
		end

		love.graphics.draw(LOVE_POSTSHADER_LAST_BUFFER)

		if LOVE_POSTSHADER_TRANSLATE then
			love.graphics.push()
			love.graphics.translate(love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
			love.graphics.scale(LOVE_POSTSHADER_TRANSLATE_SCALE)
			love.graphics.rotate(LOVE_POSTSHADER_TRANSLATE_ROTATION)
			love.graphics.translate(LOVE_POSTSHADER_TRANSLATE_X, LOVE_POSTSHADER_TRANSLATE_Y)
		end
	end
end

love.postshader.refreshScreenSize = function()
	LOVE_POSTSHADER_BUFFER_RENDER = love.graphics.newCanvas()
	LOVE_POSTSHADER_BUFFER_BACK = love.graphics.newCanvas()
end