-- lua loadfile function does NOT works in archieves, so let's fix this
-- TODO: may be fixed in newest love versions
function loadfile(filename, mode, env) 
	local chunk, err = love.filesystem.read(filename)
	if not chunk then
		return nil, err -- reading error
	end
	chunk, err = load(chunk, filename, mode, env)
	return chunk, err
end

-- and dofile() too
function dofile(filename)
	local fun, msg = loadfile(filename)
	if not fun then
		error(msg)
	end
	return fun()
end


