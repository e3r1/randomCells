math.randomseed(os.clock())
require("UI")
resx = 600 resy = 600 worldSize = 20

local gameSpeed = 30

local cells = {}
local month = 1

local PeacefulStartSatiety = 10
local PredatorStartSatiety = 35
local ReduceSatiety = 1
local PeacefulReproduceSatiety = 60
local PredatorReproduceSatiety = 90
local ReproduceCost = 50

local GrassCalories = 5

function love.load()
	love.window.setMode(900, 700, {vsync=0})

	btn = Buttons:new("example text", 700, 100, 150, 40)
	btn.click = 
	function()
		createCells(cells)
	end
	createCells(cells)
end

function createCells(cells)
	for i=0,worldSize+1 do
		cells[i] = {}
		for j=0,worldSize+1 do
			local seed = math.random(100)
			cells[i][j] = {}

			if seed <= 100 then
				cells[i][j].type = 'empty'
			end
			if seed <= 40 then
				cells[i][j].type = 'grass'
			end
			if seed <= 12 then
				cells[i][j].type = 'peaceful'
				cells[i][j].satiety = PeacefulStartSatiety
			end
			if seed <= 4 then
				cells[i][j].type = 'predator'
				cells[i][j].satiety = PredatorStartSatiety
			end

			if i==0 or i==worldSize+1 or j==0 or j==worldSize+1 then
				cells[i][j].type = 'border'
			end
		end
	end
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	updateCells(cells)
	month = month % 12 + 1

	love.timer.sleep(1 / gameSpeed - dt)
end

function updateCells(cells)
	grassScrypt = function(i, j, cells)
		tryReproduce(i, j, cells)
	end

	peacefulScrypt = function(i, j, cells)
		hunger(i, j, cells)
		alive = tryLive(i, j, cells)
		if alive then
			sate = tryEatGrass(i, j, cells)
			reprodused = tryReproduce(i, j, cells)
			if not sate and not reprodused then
				tryMove(i, j, cells)
			end
		end
	end

	predatorScrypt = function(i, j, cells)
		hunger(i, j, cells)
		alive = tryLive(i, j, cells)
		if alive then
			sate = tryEatPeaceful(i, j, cells)
			reprodused = tryReproduce(i, j, cells)
			if not sate and not reprodused then
				tryMove(i, j, cells)
			end
		end
	end

	grassCells = {}
	peacefulCells = {}
	predatorCells = {}
	
	for i=1,worldSize do
		for j=1,worldSize do
			if cells[i][j].type == 'grass' then
				table.insert(grassCells, {i, j})
			end
			if cells[i][j].type == 'peaceful' then
				table.insert(peacefulCells, {i, j})
			end
			if cells[i][j].type == 'predator' then
				table.insert(predatorCells, {i, j})
			end
		end
	end

	for index, ij in ipairs(grassCells) do
		i, j = unpack(ij)
		updateCellType('grass', grassScrypt, i, j, cells)
	end
	for index, ij in ipairs(peacefulCells) do
		i, j = unpack(ij)
		updateCellType('peaceful', peacefulScrypt, i, j, cells)
	end
	for index, ij in ipairs(predatorCells) do
		i, j = unpack(ij)
		updateCellType('predator', predatorScrypt, i, j, cells)
	end
end

function updateCellType(type, script, i, j, cells)
	if cells[i][j].type == type then
		script(i, j, cells)
	end
end

function hunger(i, j, cells)
	cells[i][j].satiety = cells[i][j].satiety - ReduceSatiety
end

function tryMove(i, j, cells)
	if cells[i][j].type =='grass' then
		possibleDirs = {}
		if cells[i-1][j].type == 'empty' then
			table.insert(possibleDirs, {-1, 0})
		end
		if cells[i+1][j].type == 'empty' then
			table.insert(possibleDirs, {1, 0})
		end
		if cells[i][j-1].type == 'empty' then
			table.insert(possibleDirs, {0, -1})
		end
		if cells[i][j+1].type == 'empty' then
			table.insert(possibleDirs, {0, 1})
		end
		
		if #possibleDirs ~= 0 then
			local dir = math.random(#possibleDirs)
			local di, dj = unpack(possibleDirs[dir])

			cells[i+di][j+dj].type = cells[i][j].type
			cells[i][j].type = 'empty'
			
			return true
		else
			return false
		end
	end

	if cells[i][j].type =='peaceful' then
		possibleDirs = {}
		if cells[i-1][j].type == 'empty' or cells[i-1][j].type == 'grass' then
			table.insert(possibleDirs, {-1, 0})
		end
		if cells[i+1][j].type == 'empty' or cells[i+1][j].type == 'grass' then
			table.insert(possibleDirs, {1, 0})
		end
		if cells[i][j-1].type == 'empty' or cells[i][j-1].type == 'grass' then
			table.insert(possibleDirs, {0, -1})
		end
		if cells[i][j+1].type == 'empty' or cells[i][j+1].type == 'grass' then
			table.insert(possibleDirs, {0, 1})
		end
		
		if #possibleDirs ~= 0 then
			local dir = math.random(#possibleDirs)
			local di, dj = unpack(possibleDirs[dir])

			cells[i+di][j+dj].type = cells[i][j].type
			cells[i+di][j+dj].satiety = cells[i][j].satiety
			cells[i][j].type = 'empty'
			
			return true
		else
			return false
		end
	end

	if cells[i][j].type =='predator' then
		possibleDirs = {}
		if cells[i-1][j].type == 'empty' or cells[i-1][j].type == 'grass' then
			table.insert(possibleDirs, {-1, 0})
		end
		if cells[i+1][j].type == 'empty' or cells[i+1][j].type == 'grass' then
			table.insert(possibleDirs, {1, 0})
		end
		if cells[i][j-1].type == 'empty' or cells[i][j-1].type == 'grass' then
			table.insert(possibleDirs, {0, -1})
		end
		if cells[i][j+1].type == 'empty' or cells[i][j+1].type == 'grass' then
			table.insert(possibleDirs, {0, 1})
		end
		
		if #possibleDirs ~= 0 then
			local dir = math.random(#possibleDirs)
			local di, dj = unpack(possibleDirs[dir])

			cells[i+di][j+dj].type = cells[i][j].type
			cells[i+di][j+dj].satiety = cells[i][j].satiety
			cells[i][j].type = 'empty'
			
			return true
		else
			return false
		end
	end
	
end

function tryReproduce(i, j, cells)
	possibleDirs = {}
		if cells[i-1][j].type == 'empty' then
			table.insert(possibleDirs, {-1, 0})
		end
		if cells[i+1][j].type == 'empty' then
			table.insert(possibleDirs, {1, 0})
		end
		if cells[i][j-1].type == 'empty' then
			table.insert(possibleDirs, {0, -1})
		end
		if cells[i][j+1].type == 'empty' then
			table.insert(possibleDirs, {0, 1})
		end
		
		if #possibleDirs ~= 0 then
			local dir = math.random(#possibleDirs)
			local di, dj = unpack(possibleDirs[dir])

			if cells[i][j].type =='grass' then
				if month >=6 and month<=8 then
					cells[i+di][j+dj].type = cells[i][j].type
				end
				
			end

			if cells[i][j].type =='peaceful' then
				if cells[i][j].satiety >= PeacefulReproduceSatiety then
					cells[i+di][j+dj].type = cells[i][j].type
					cells[i+di][j+dj].satiety = PeacefulStartSatiety
					cells[i][j].satiety = cells[i][j].satiety - PeacefulStartSatiety - ReproduceCost
				else
					return false
				end
			end

			if cells[i][j].type =='predator' then
				if cells[i][j].satiety >= PredatorReproduceSatiety then
					cells[i+di][j+dj].type = cells[i][j].type
					cells[i+di][j+dj].satiety = PredatorStartSatiety
					cells[i][j].satiety = cells[i][j].satiety - PredatorStartSatiety - ReproduceCost
				else
					return false
				end
			end
			
			return true
		else
			return false
		end
end

function tryEatGrass(i, j, cells)
	possibleDirs = {}
		if cells[i-1][j].type == 'grass' then
			table.insert(possibleDirs, {-1, 0})
		end
		if cells[i+1][j].type == 'grass' then
			table.insert(possibleDirs, {1, 0})
		end
		if cells[i][j-1].type == 'grass' then
			table.insert(possibleDirs, {0, -1})
		end
		if cells[i][j+1].type == 'grass' then
			table.insert(possibleDirs, {0, 1})
		end
		
		if #possibleDirs ~= 0 then
			local dir = math.random(#possibleDirs)
			local di, dj = unpack(possibleDirs[dir])
			cells[i+di][j+dj].type = 'empty'
			cells[i][j].satiety = cells[i][j].satiety + GrassCalories
			return true
		else
			return false
		end
end

function tryEatPeaceful(i, j, cells)
	possibleDirs = {}
		if cells[i-1][j].type == 'peaceful' then
			table.insert(possibleDirs, {-1, 0})
		end
		if cells[i+1][j].type == 'peaceful' then
			table.insert(possibleDirs, {1, 0})
		end
		if cells[i][j-1].type == 'peaceful' then
			table.insert(possibleDirs, {0, -1})
		end
		if cells[i][j+1].type == 'peaceful' then
			table.insert(possibleDirs, {0, 1})
		end
		
		if #possibleDirs ~= 0 then
			local dir = math.random(#possibleDirs)
			local di, dj = unpack(possibleDirs[dir])
			cells[i+di][j+dj].type = 'empty'
			cells[i][j].satiety = cells[i][j].satiety + cells[i+di][j+dj].satiety
			return true
		else
			return false
		end
end

function tryLive(i, j, cells)
	if cells[i][j].satiety <= 0 then
		cells[i][j].type = 'empty'
		return false
	else
		return true
	end
end

function love.draw()
	dx = resx/worldSize
	dy = resy/worldSize
	for i=1,worldSize do
		for j=1,worldSize do
			local color
			if cells[i][j].type == 'empty' then
				color = {0.1, 0.1, 0.1}
			end
			if cells[i][j].type == 'grass' then
				color = {0, 1, 0}
			end
			if cells[i][j].type == 'peaceful' then
				color = {1, 0.5, 0.6}
			end
			if cells[i][j].type == 'predator' then
				color = {1, 0, 0}
			end

			love.graphics.setColor(color)
			love.graphics.rectangle("fill", i*dx, j*dy, dx, dy)
		end
	end
	love.graphics.print("hello", 200, 10)
	btn:draw()
end

function love.mousepressed(x, y, button, istouch)
	params = {x, y, button}
    updateUI('mouse', params)
end