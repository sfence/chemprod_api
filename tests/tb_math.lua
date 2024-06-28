
MINETEST_WORLD_SUBPATH = "world"

dofile("test_api/init.lua")

local other_mods_dir = "../../"

test_api.load_module("..", "chemprod_api")
test_api.load_module("./test_chem", "test_chem")

local graph_structure = {
  ["Temperatures"] = {
    "reactor_temp", --
  },
  ["Amount"] = {
    "gO2_amount", --
    "gH2_amount", --
    "gOH_amount", --
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
local steps = 1000

for i=1,steps do
  print("Index "..index)
  local out = chemprod_api.calc_reaction(reactor_data, 0.1)
  print(dump(out))
  --heatplace_data = heatplace:load_data(pos, my_meta)
  --fireplace:ignite_fuel(pos, my_meta, heatplace_data, init_item, 1, "singleplayer")
  --heatplace:save_data(pos, my_meta, heatplace_data)
  --my_meta:insert_floats(graph_structure, "Tempratures", output, index)
  --my_meta:insert_floats(graph_structure, "Amount", output, index)
  reactor_data.temp = out.temp
  reactor_data.substances = out.substances

  output["Temperatures"].reactor_temp[index] = out.temp
  output["Amount"]["gO2_amount"][index] = out.substances["gO2"]
  output["Amount"]["gH2_amount"][index] = out.substances["gH2"]
  output["Amount"]["gOH_amount"][index] = out.substances["gOH"]

  if out.temp < 2000 then
    reactor_data.temp = out.temp + 10
  end

  index = index + 1
end

return output
