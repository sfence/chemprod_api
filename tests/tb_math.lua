
MINETEST_WORLD_SUBPATH = "world"

dofile("test_api/init.lua")

local other_mods_dir = "../../"

test_api.load_module(other_mods_dir.."appliances", "appliances")
test_api.load_module("..", "chemprod")

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

local reactor_data = {
  temp = 273+500,
  V = 1,
  substances = {
    ["gO2"] = 1000000000000,
    ["gH2"] = 1000000000000,
  },
}

local index = 1
local steps = 10

for i=1,steps do
  print("Index "..index)
  local out = chemprod.calc_reaction(reactor_data, 0.1)
  print(dump(out))
  --heatplace_data = heatplace:load_data(pos, my_meta)
  --fireplace:ignite_fuel(pos, my_meta, heatplace_data, init_item, 1, "singleplayer")
  --heatplace:save_data(pos, my_meta, heatplace_data)
  --my_meta:insert_floats(graph_structure, "Tempratures", output, index)
  --my_meta:insert_floats(graph_structure, "Amount", output, index)
  reactor_data.temp = out.temp
  reactor_data.substances = out.substances
  index = index + 1
end

