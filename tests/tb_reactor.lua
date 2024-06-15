
MINETEST_WORLD_SUBPATH = "world"

dofile("test_api/init.lua")

minetest.set_mapgen_setting("chunksize", 5)

local other_mods_dir = "../../"

test_api.load_module(other_mods_dir.."default", "default")
test_api.load_module(other_mods_dir.."appliances", "appliances")
test_api.load_module("..", "chemprod")

test_api.fill_map_block(vector.new(8,24,8), {name="air"})
test_api.fill_map_block(vector.new(8,8,8), {name="default:dirt"})

local graph_structure = {
  ["Tempratures"] = {
    "reactor_temp", --
  },
  ["Amount"] = {
    "gO2_amount", --
    "gH2_amount", --
  },
}
local output = test_api.graph_empty_data(graph_structure)

local reactor_pos = vector.new(8,16,8)
minetest.set_node(reactor_pos, {name="chemprod:test_reactor"})
test_api.active_map_block(reactor_pos)

local player = test_api.PlayerRef:new({_player_name = "testplayer", _pos = vector.add(reactor_pos, vector.new(-1,0,0))})
local phial_stack = ItemStack("chemprod:phial_of_substance")
local phial_meta = phial_stack:get_meta()
phial_meta:set_string("substances", minetest.write_json({
    ["gO2"] = 1000000000000,
    ["gH2"] = 1000000000000,
  }))
player:set_wielded_item(phial_stack)

--print(dump(player._meta.inventory))

for n=1,25 do
  test_api.world_step(0.1)
end

local meta = minetest.get_meta(reactor_pos)
test_api.move_itemstack(player:get_inventory(), player:get_wield_list(), player:get_wield_index(), meta:get_inventory(), "input", 1, player:get_wielded_item(), player);
--print(dump(meta.inventory))
--print(dump(player:get_wielded_item():get_count()))

--print(dump(minetest.get_node_timer(reactor_pos)))

--test_api.debug_node(reactor_pos)
--print(dump(minetest.registered_nodes["chemprod:test_reactor"]))

for n=1,100 do
  test_api.world_step(0.1)
end

meta = minetest.get_meta(reactor_pos)
meta:set_float("temp", 1000.0)
print("SET TEMP TO 1000")

for n=1,20 do
  test_api.world_step(0.1)
end
