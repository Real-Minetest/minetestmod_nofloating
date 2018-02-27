--    Minetest 沒有浮空
--    Copyright (C) 2017-2018  Zaoqi

--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Affero General Public License as published
--    by the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.

--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Affero General Public License for more details.

--    You should have received a copy of the GNU Affero General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
local delay = 0.1
local perdelay = 1
local block = 1024
local function is_not_air(pos)
	local n = minetest.get_node_or_nil(pos)
	if n == nil then return true end
	local dt = minetest.registered_nodes[n.name].drawtype
	return dt ~= "airlike" and dt ~= "liquid" and dt ~= "flowingliquid"
end
local function near1(p)
	local x, y, z = p.x, p.y, p.z
	return {{x=x-1,y=y,z=z},{x=x+1,y=y,z=z},{x=x,y=y-1,z=z},{x=x,y=y+1,z=z},{x=x,y=y,z=z-1},{x=x,y=y,z=z+1}}
end
local function not_find(poss, n)
	local ps = poss
	local rs = {}
	local len = 0
	local function add(pos)
		local x, y, z = pos.x, pos.y, pos.z
		local a = rs[x]
		if a == nil then
			a = {}
			rs[x] = a
		end
		local b = a[y]
		if b == nil then
			b = {}
			a[y] = b
		end
		if b[z] then
			return false
		else
			b[z] = true
			len = len + 1
			return true
		end
	end
	while #ps ~= 0 do
		if len >= n then return false end
		local new_ps = {}
		for _, p in ipairs(ps) do
			if is_not_air(p) then if add(p) then
				for _, a in ipairs(near1(p)) do
					new_ps[#new_ps+1] = a
				end
			end end
		end
		ps = new_ps
	end
	if len >= n then
		return false
	else
		return rs
	end
end
local function not_find_pos(poss, n)
	local rs = not_find(poss, n)
	if rs then
		local r = {}
		for x, a in pairs(rs) do
			for y, b in pairs(a) do
				for z, _ in pairs(b) do
					r[#r+1] = {x=x,y=y,z=z}
				end
			end
		end
		return r
	else
		return rs
	end
end
local down
local function check(pos)
	if is_not_air(pos) then
		local poss = not_find_pos({pos}, block)
		if poss then
			down(poss)
		end
	end
end
-- map : [y][x][z]
local downing
local temp_show_map
local temp_show_map_remove
local show_map
local remove_map
local map_foreach
down = function(poss)
	local map = {} -- y x z
	for _, p in ipairs(poss) do
		local x, y, z = p.x, p.y, p.z
		local a = map[y] or {}
		map[y] = a
		local b = a[x] or {}
		a[x] = b
		b[z] = minetest.get_node(p)
		minetest.remove_node(p)
	end
	return downing(map)
end
map_foreach = function(map, f)
	for y, a in pairs(map) do
		for x, b in pairs(a) do
			for z, node in pairs(b) do
				f(x, y, z, node)
			end
		end
	end
end
remove_map = function(map)
	return map_foreach(map, function(x, y, z) return minetest.remove_node{x=x,y=y,z=z} end)
end
show_map = function(map)
	return map_foreach(map, function(x, y, z, node) return minetest.set_node({x=x,y=y,z=z}, node) end)
end
temp_show_map = function(map)
	local rs = {}
	map_foreach(map, function(x, y, z, node)
		local p = {x=x,y=y,z=z}
		local o = minetest.add_entity(p, "no_floating:temp_node")
		local e = o:get_luaentity()
		rs[#rs+1] = e
		return e:set_node(node)
	end)
	return rs
end
temp_show_map_remove = function(t)
	for _, e in ipairs(t) do
		e.object:remove()
	end
end
countinue_downing = function(map)
	local t = temp_show_map(map)
	return minetest.after(delay, function()
		temp_show_map_remove(t)
		return downing(map)
	end)
end
downing = function(map)
	local new_map = {}
	local touched = false -- 是否碰到地面
	for y, a in pairs(map) do
		local yd = y-perdelay -- 下降
		local ydd = yd-1 -- 下面的
		new_map[yd] = a
		if not touched then
			for x, b in pairs(a) do
				for z, _ in pairs(b) do
					if is_not_air{x=x, y=ydd, z=z} then
						touched = true
					end
				end
			end
		end
	end
	if touched then
		return show_map(new_map)
	else
		return countinue_downing(new_map)
	end
end
minetest.register_on_dignode(function(pos, oldnode, digger)
	for _, p in ipairs(near1(pos)) do
		check(p)
	end
end)

minetest.register_entity("no_floating:temp_node", {
	initial_properties = {
		visual = "wielditem",
		visual_size = {x = 0.667, y = 0.667},
		textures = {},
		physical = true,
		is_visible = false,
		collide_with_objects = false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},

	node = {},
	meta = {},

	set_node = function(self, node, meta)
		self.node = node
		self.meta = meta or {}
		self.object:set_properties({
			is_visible = true,
			textures = {node.name},
		})
	end,

	get_staticdata = function(self)
		local ds = {
			node = self.node,
			meta = self.meta,
		}
		return core.serialize(ds)
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		
		local ds = core.deserialize(staticdata)
		if ds and ds.node then
			self:set_node(ds.node, ds.meta)
		elseif ds then
			self:set_node(ds)
		elseif staticdata ~= "" then
			self:set_node({name = staticdata})
		end
	end,

	on_step = function(self, dtime)
	end
})
