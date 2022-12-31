-- some extra useful functions for your games

function readfile(filename)
	local chunk, err = love.filesystem.read(filename)
	if not chunk then
		print(err);
		return nil, err -- reading error
	end
	return chunk, nil
end
