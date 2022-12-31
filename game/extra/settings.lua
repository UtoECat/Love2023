require "extra/loadwithlove"

local settings = {}
local proxy = newproxy(true)
local meta = getmetatable(proxy)
local filename = "game_settings.lua"

-- serialization
local function serialize(v, stackwas)
	local stack = stackwas or {}
	local tp = type(v)
	
	if tp == "table" then
		if stack[v] then -- anti-recursion
			if stack[v] == true then error("recursion :o") end
			return stack[v] -- hehe
		end
		stack[v] = true -- add to stack
		-- dirty table to string without key serialization
		local str = "{"
		for a, b in pairs(v) do
			str = str.."["..serialize(a).."]".." = "..serialize(b)
			if next(v, a) then
					str = str..", "
			end
		end
		str = str.."}"
		stack[v] = str -- allow duplication now
		return str
	elseif tp == "string" then 
		return string.format('%q', v)
	elseif tp == "number" or tp=="integer" then
		return tostring(v)
	else
		error("Cannot serialize type "..tp.." "..tostring(v))
	end
end

-- save all settings
meta.__gc = function()
	love.filesystem.write(filename, "return "..serialize(settings).." ")
end

-- load settings
function reloadSettings()
	local env = {} -- yeah :D
	local fun, err = loadfile(filename, 't', env)
	if not fun then
		print("Error : Can't open and parse settings properly ("..tostring(err)..")!")
	else
		local suc, res = pcall(fun)
		if not suc or type(res) ~= "table" then
			print("Error : Can't load(execute) settings properly ("..tostring(res)..")!")
			return
		end
		-- this is very dirty... VERY dirty. I know :p
		for k, v in pairs(res) do
			settings[k] = v
		end
	end
end

return settings
