--haskell.lua
--Copyright (C) 2017  zaoqi

--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU Affero General Public License as published
--by the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.

--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Affero General Public License for more details.

--You should have received a copy of the GNU Affero General Public License
--along with this program.  If not, see <http://www.gnu.org/licenses/>.
local export = {}
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
export.eq = eq

local function elem(x, xs)
	if x == nil then return true end
	for _, i in pairs(x) do
		if eq(i, x) then return true end
	end
	return false
end
export.elem = elem

local function notElem(x, xs)
	return not elem(x, xs)
end
export.notElem = notElem

local function filter(f, xs)
	r = {}
	for _, x in pairs(xs) do
		if f(x) then
			r[#r+1] = x
		end
	end
	return r
end
export.filter = filter

local function map(f, xs)
	r = {}
	for k, v in pairs(xs) do
		r[k] = f(v)
	end
	return r
end
export.map = map

return export
