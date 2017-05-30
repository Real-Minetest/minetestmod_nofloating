core.spawn_falling_node = core.spawn_falling_node or function(pos)
	local node = core.get_node(pos)
	if node.name == "air" or node.name == "ignore" then
		return false
	end
	local obj = core.add_entity(pos, "__builtin:falling_node")
	if obj then
		obj:get_luaentity():set_node(node)
		core.remove_node(pos)
		return true
	end
	return false
end
