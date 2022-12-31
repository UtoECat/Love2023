local D = love.graphics

-- constants
local elka = D.newImage("res/tree.png");
local elkadec = D.newImage("res/tree_dec.png");
snezinka = D.newImage("res/snezinka.png");
ball = D.newImage("res/ball.png");
sugrob = D.newImage("res/snowball.png");
winnoise = love.audio.newSource("res/winter_noise.ogg", "static");
databoom = love.sound.newSoundData("res/boom.ogg");

winnoise:setLooping(true);
winnoise:setVolume(0);

local snezsize = 1/snezinka:getWidth()

local snow_count = 75

local function drawsnowball(x, y, s)
	local sz = snezsize * s 
	D.draw(snezinka, x - sz/2, y - sz/2, 0, sz, sz);
end

-- variables
local veter = 1
local snow = {}
local snow_bg = {}
local sugrobs = {}
local sugrobs_bg = {}
local sugrobs_bbg = {}
local list = {}
local fireworks = {}

-- globals
colors = {
	{1, 0, 0},
	{1, 1, 0},
	{1, 0, 1},
	{0, 1, 1},
	{0, 1, 0},
	{0, 0, 1},
	{1, 1, 1}
}

-- useful functions

local function resetsnowi(v) 
	v.s = math.random(10, 90) / 10
	v.x = math.random(-v.s, D.getWidth() + v.s)
	v.y = -v.s * 2
	v.i = math.random(1, 10) / 5
end

local function gensugrobs(sug, cnt)
	for i = 1, cnt, 1 do
		sug[i] = {x = D:getWidth()/(cnt + 5) * (i-1), y = math.random(1, 120)}
	end
end

function loadvis()
	local h = D.getHeight()
	
	-- play noise
	winnoise:play()
	-- generate snow
	for i = 1, snow_count, 1 do
		snow[i] = {}
		snow_bg[i] = {}
		resetsnowi(snow[i])
		resetsnowi(snow_bg[i])
		snow[i].y = love.math.random(0, h)
		snow_bg[i].y = love.math.random(0, h)
	end

	-- generate ground :D
	gensugrobs(sugrobs, 15);
	gensugrobs(sugrobs_bg, 25);
	gensugrobs(sugrobs_bbg, 30);
end

local function updatesnow(snow)
	local max = D.getHeight()
	local maxx = D.getWidth()

	for k, v in ipairs(snow) do
		v.y = v.y + v.s/3
		if v.y > max + v.s then
			resetsnowi(v)
		else
			v.x = v.x + veter
			if v.x > maxx + v.s then
				v.x = -v.s + 1
			elseif v.x < -v.s then
				v.x = maxx + v.s - 1
			end
			v.i = v.i + v.s/3
		end
	end

end

local PI = 3.1415

function updatevis(dt)
	-- update veter
	local time = love.timer.getTime()
	local sin = math.sin
	local cos = math.cos
	veter = (
		sin(time/PI) + sin(time/(PI*2)) * cos(time/(PI*1.5)) - cos(time/(PI*3))
	) / 2
	winnoise:setVolume(math.abs(veter)+0.1);
	-- update snow
	updatesnow(snow);
	updatesnow(snow_bg);
	-- update list
	for k, v in ipairs(list) do
		if v.update then v:update() end
	end
	-- update fireworks
	proc_fw_particles(dt)
end

function drawvis()
	local h = D.getHeight()
	-- bgg
	D.setColor(0.5, 0.5, 0.5);
	for k, v in ipairs(sugrobs_bbg) do
		D.draw(sugrob, v.x, h - v.y, 0, 0.6, 0.6);
	end
	D.setColor(1, 1, 1);
	-- bg snow
	for k, v in ipairs(snow_bg) do
		drawsnowball(v.x, v.y, v.s)
	end
	-- bg sugrobs
	D.setColor(0.7, 0.7, 0.7);
	for k, v in ipairs(sugrobs_bg) do
		D.draw(sugrob, v.x, h - v.y, 0, 0.8, 0.8);
	end
	-- fireworks
	draw_fw_particles()
	-- bg
	D.setColor(1, 1, 1);
	D.draw(elka, 200, h - elka:getHeight()+20, 0, 0.9, 0.9);
	D.draw(elkadec, 200, h - elkadec:getHeight(), 0, 0.9, 0.9);
	-- snow
	for k, v in ipairs(snow) do
		drawsnowball(v.x, v.y, v.s)
	end
	-- sugrobs
	for k, v in ipairs(sugrobs) do
		D.draw(sugrob, v.x, h - v.y, 0, 1, 1);
	end
	for k, v in ipairs(list) do
		local sz = 1/v.texture:getWidth() * v.sz
		local t = colors[v.col]
		D.setColor(t[1], t[2], t[3])
		D.draw(v.texture, v.x - v.sz/2, v.y - v.sz/2, 0, sz, sz);
	end
end

function newVisItem(xval, yval, tval, updf)
	local t = {x = xval, y = yval, update = updf, texture = tval}
	list[#list + 1] = t
	return t
end

function spawnFirework(x, y, color, pow, kx, ky)
	local power = pow or 6
	local t

	-- ищем место под частицу
	for k, v in ipairs(fireworks) do
		if v.time <= 0 then
			t = v
			break;
		end
	end

	-- иначе добавляемся в конец
	if not t then
		t = {}
		fireworks[#fireworks + 1] = t
	end

	t.power = power
	t.x = x
	t.y = y
	t.kx = kx or 0
	t.ky = ky or -4
	t.color = color or 1
	t.time = 2*t.power/32
	t.maxtime = t.time
	return t
end

function math.sqrtex(val, cnt) 
	for i = 2, cnt, 1 do
		val = math.sqrt(val)
	end
	return val
end

function proc_fw_particles(dt)
	local maxpow = 0
	for k, v in ipairs(fireworks) do
		if v.time > 0 then
			v.time = v.time - dt/2
			v.x = v.x + v.kx
			v.y = v.y + v.ky

			local pow = v.power
			-- called once per particle
			if v.time <= 0 and v.power > 1 then
				local step = (PI*2) / (v.power)
				for i = 0, PI*2, step do
					local x = v.x
					local y = v.y
					local col = v.color
					maxpow = pow
					v.power = 0
					if math.random(1, 10) == 1 then
						col = math.random(1, #colors)
					end	
					spawnFirework(x, y, 
						col, pow - 1,
						math.cos(i) * pow/3, math.sin(i) * pow/3
					)
				end

			end
			-- end of paritcle processing
		end
		-- end of loop
	end
	if maxpow > 0 then
		local f = love.audio.newSource(databoom, "static")
		f:setVolume(maxpow/8)
		f:play()
	end
end

function draw_fw_particles()
	for k,v in ipairs(fireworks) do
		if v.time > 0 then
			local k = v.time/v.maxtime
			D.setColor(
				colors[v.color][1],
				colors[v.color][2],
				colors[v.color][3],
				k + 0.1
			)
			drawsnowball(v.x, v.y, v.power * 5);
		end
	end
end
