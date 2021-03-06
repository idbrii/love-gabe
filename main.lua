-- Gabe functions by monkey-patching the love table, and should be called
-- first.
require 'gabe' ()
-- Gabe.state is the state management libraries
local state  = require 'gabe.state'
-- Gabe.reload provides functions to reload code
local reload = require 'gabe.reload'
-- Gabe.class provides a simple, reload-friendly class implementation
local class = require 'gabe.class'

local Rect = require 'rect'

-- An example class.
------------------------------------------------------------------------------

-- in Gabe, all classes _must_ be named. When a game is reloaded, objects will
-- swap out their old classes for new ones with the same name.
local Dot = class 'dot'

-- This means that class-level fields can be changed. If you change Dot.radius
-- here, and reload the game, all dots will reflect the new radius value.
Dot.radius = 20

-- In lua, methods are also fields. this means that you can redefine methods in
-- the exact same way that you can redefine fields. Try changing 'fill' to
-- 'line', or switching from a circle to a square.
function Dot:draw()
	love.graphics.circle('fill', self.x, self.y, self.radius)
end

-- Dot:init() is a constructor. It will only be called once, when an object is
-- first created, so changing init() and reloading will only affect new dots,
-- not old ones.
function Dot:init(x, y)
	self.x, self.y = x, y
end

-------------------------------------------------------------------------------

-- Game lifecycle functions. Use these to set up and tear down game state as
-- necessary.
-------------------------------------------------------------------------------

-- Happens only once, at the very beginning
function love.load()
	print("Game loaded")
end

-- Happens once, at the very end
function love.quit()
	print("Game quit")
end

-- Happens on love.quit, and in between resets
function state.stop()
	print("stop")
end

-- Happens on love.load, and in between resets
function state.start()
	print("start")
	local w, h = love.graphics.getDimensions()
	S.dots = {}
	for i=1, 3 do
		local dot = Dot.new(math.random(w), math.random(h))
		table.insert(S.dots, dot)
	end

	S.rects = {}
	for i=1, 3 do
		local rect = Rect.new(math.random(w), math.random(h))
		table.insert(S.rects, rect)
	end
end

-------------------------------------------------------------------------------

-- LOVE callbacks. you should recognize these.
-------------------------------------------------------------------------------
function love.draw()
	for _, d in ipairs(S.dots) do
		d:draw()
	end
	for _, d in ipairs(S.rects) do
		d:draw()
	end
	love.graphics.circle('fill', 400, 100, 100)
end

function love.keypressed(k)
	if k == 'escape' then
		love.event.quit()
	elseif k == '1' then
		-- This reloads the game's code, to reflect changes you have made.
		reload.reload_all()
		print("reloaded")
	elseif k == '2' then
		-- This resets the game's state. This is usually faster than closing
		-- and re-opening your game, and can be used throughout testing.
		-- NOTE: resetting your game does not automatically reload the game,
		-- so you should do both to fully reflect changes.
		reload.reload_all()
		state.reset()
		print("reset")
	elseif k == '3' then
		-- pressing '3' will trigger an error, which you can recover from by
		-- reseting/reloading the game. This is useful for fixing mistakes.
		error("reload me!")
	end
end
-------------------------------------------------------------------------------
