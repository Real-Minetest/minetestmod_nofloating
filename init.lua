--<one line to give the program's name and a brief idea of what it does.>
--Copyright (C) <year>  <name of author>

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
	for _, i in pairs(xs) do
		if eq(i, x) then return true end
	end
	return false
end
z={eq=eq,elem=elem}
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/api.lua")

local n = 64
nofloating = {}
function nofloating.find(max, ...)
	local r = {}
	local n = {...}
	while #n ~= 0 do
		local a = {}
		for _, x in ipairs(n) do
			local name = minetest.get_node(x).name
			if not (name == "air" or name == "ignore" or elem(x, r)) then
				if #r >= max then return r end
				r[#r+1] = x
				a[#a+1] = {x=x.x+1,y=x.y,z=x.z}
				a[#a+1] = {x=x.x-1,y=x.y,z=x.z}
				a[#a+1] = {x=x.x,y=x.y+1,z=x.z}
				a[#a+1] = {x=x.x,y=x.y-1,z=x.z}
				a[#a+1] = {x=x.x,y=x.y,z=x.z+1}
				a[#a+1] = {x=x.x,y=x.y,z=x.z-1}
			end
		end
		n = a
	end
	return r
end

function nofloating.check(...)
	local x = nofloating.find(n, ...)
	if #x < n then
		for _, pos in ipairs(x) do
			minetest.spawn_falling_node(pos)
		end
		return true
	else
		return false
	end
end

local old_check_single_for_falling = minetest.check_single_for_falling
function minetest.check_single_for_falling(pos)
	return nofloating.check(pos) or minetest.check_single_for_falling(pos)
end
