
local S = chemprod.translator

chemprod.substances = {
  {
    formula = "H2O",
    name = "Water",
    color = {r=0,g=0,b=0,a=255},
    melting = 0,
    boiling = 100,
  },
}

local modname = minetest.get_current_modname()

for _,substance in pairs(chemprod.substances) do
  chemprod.register_substance(modname, substance)
end
