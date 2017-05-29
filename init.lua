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
local function elem(x, xs)
	if x == nil then return true end
	for _, i in pairs(x) do
		if eq(i, x) then return true end
	end
	return false
end
local function notElem(x, xs)
	return not elem(x, xs)
end
local function filter(f, xs)
	r = {}
	for _, x in pairs(xs) do
		if f(x) then
			r[#r+1] = x
		end
	end
	return r
end

nofloating = {}
