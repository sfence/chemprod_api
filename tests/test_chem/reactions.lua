
local reactions = {
  {
    key = "gO2+gH2->gOH",
    inputs = {["gO2"]=1,["gH2"]=1},
    outputs = {["gOH"]=2},
    A = 2.5e12,
    B = 0,
    ["Ea/R"] = 19630,
  },
}

local modname = minetest.get_current_modname()

for _,reaction in pairs(reactions) do
  chemprod_api.register_reaction(modname, reaction)
end

