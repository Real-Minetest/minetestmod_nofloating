local function eq(x, y)
	if type(x) == "table" then
		if type(y) ~= "table" then return false end
		for k, v in pairs(x) do
			if not eq (v, y[k]) then return false end
		end
		for k, v in pairs(y) do
			if not eq (v, x[k]) then return false end
		end
		return true
	else
		return x == y
	end
end
