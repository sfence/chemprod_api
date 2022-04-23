
local S = chemprod.translator

local substances = {
  {
    key = "lH2O", -- liquid H2O
    formula = "H2O",
    name = "Water",
    color = {r=0,g=0,b=0,a=255},
    liquid = true,
    M = 0.01801528,
    Dm3 = 999.97,
    Hf = -285830,
    Gf = -237240,
    cm = 75.385,
  },
  
  {
    key = "sCuSO4", -- solid CuSO4
    formula = "CuSO4",
    name = "Copper II Sulfate",
    color = {r=0,g=0,b=0,a=255},
    solid = true,
    M = 0.158610,
    Dm3 = 3603,
    Hf = -771100,
    Gf = -661900,
    --cm = 75.385,
    cp = 626,
  },
}

local modname = minetest.get_current_modname()

for _,substance in pairs(substances) do
  chemprod.register_substance(modname, substance)
end
