-- Localization and internationalization module
require "extra/loadwithlove"

local def = "en" -- default locale
local cur = def  -- current locale

local i18n = {
	locales = {} -- locales are loaded automaticly below :
}

-- get and load all custom locale files
local files = love.filesystem.getDirectoryItems("loc/")

for _, file in ipairs(files) do
	if love.filesystem.getInfo("/loc/"..file, "file") and #file < 7 then
		local loc, err = loadfile("/loc/"..file)
		if loc then
			local name = file:sub(1, 2) -- for 'en.lua' it will be 'en'
			i18n.locales[name] = loc() -- get locale table
		else
			print("Error : can't load localization file "..file.." !")
			print("Error : "..tostring(err).." !")
		end
	end
end

-- functions
function i18n.setLocale(new)
	assert(new and i18n.locales[new], "Locale "..tostring(new).." is unknown!")
  loc = new
end

local function getstring(id)
  return i18n.locales[loc] and i18n.locales[loc][id] or "${"..tostring(id).."}"
end

i18n.getString = getstring
setmetatable(i18n, {__call = function(_, id) return getstring(id) end})

return i18n
