-- required modules
local i18n = require "extra/locale"
require "extra/funcs"
local var = require "extra/settings"
local D = love.graphics

require "visuals"

-- constants
local font_title = D.newFont("res/vela_sans.otf", 30) 
local font_default = D.newFont("res/vela_sans.otf", 15) 
local snd_taskdone = love.audio.newSource("res/levelup.ogg", "static")

snd_taskdone:setVolume(0.5)

-- options 
var.heloo = "custom option"

function love.load()
	i18n.setLocale("ru");
	math.randomseed(os.clock())
	reloadSettings()
	-- setup snow
	loadvis()
end

-- girlanda
local girlanda_func = function (self)
	local newt = love.timer.getTime()
	if self.time + 0.5 < newt then
		self.time = newt
		self.col = math.random(1, #colors)
	end
end

local tasks = {
	{name = "elka_girland", value = 30},
	{name = "elka_balls", value = 15},
	{name = "fireworks", value = 10},
	{name = "wait_ny"},
	{name = "wait_nny"}
}

local current_task = 1

local old_one = false
local clicks = 0

local function checktime()
	local t = os.date("*t")
	return t.day == 1 and t.month == 1 and t.hour == 0 and t.min <= 5
end

local old_timing = love.timer.getTime()

function love.update(dt)
	-- update visuals
	updatevis(dt);

	if checktime() and old_timing < love.timer.getTime() then
		old_timing = love.timer.getTime() + love.math.random(4, 10) / 5
		spawnFirework(math.random(1, D.getWidth()), D.getHeight()/3*2, math.random(1, #colors))
		current_task = 5
	end

	local d = love.mouse.isDown(1)
	if d and d ~= old_one then
		clicks = clicks + 1
		local x = love.mouse.getX()
		local y = love.mouse.getY()

		if current_task == 3 then
			spawnFirework(x, y, math.random(1, #colors))
		elseif current_task == 2 then
			local t = newVisItem(x, y, ball, nil);
			t.sz = 55
			t.col = math.random(1, #colors)
		elseif current_task == 1 then
			local t = newVisItem(x, y, snezinka, girlanda_func);
			t.sz = 55
			t.col = math.random(1, #colors)
			t.time = love.timer.getTime()
		end

		if tasks[current_task].value and tasks[current_task].value <= clicks then
			current_task = current_task + 1
			clicks = 0
			--snd_taskdone:setPosition(1)
			snd_taskdone:play()
		end
	end

	old_one = d
end

local function checkdate()
	return os.date("*t").month == 1
end

function status()
	if tasks[current_task].value then
		return "("..tostring(clicks).." / "..tostring(tasks[current_task].value)..")"
	else
		return ""
	end
end

function love.draw()
	local h = D.getHeight()

	D.reset()
	-- draw visuals
	D.setFont(font_default)
	drawvis()
	-- draw text
	D.setColor(1,1,1);
	D.setFont(font_title)
	D.print(i18n(checkdate() and "newy" or "oldy"), 0, 0, 0, 1, 1)
	D.setFont(font_default)
	D.print(i18n("task")..i18n(tasks[current_task].name)..status(), 0, 40, 0, 1, 1)

end
