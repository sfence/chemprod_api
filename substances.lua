
local S = chemprod.translator

local substances = {
  --[[
  {
    key = "", -- liquid H2O
    formula = "",
    name = "",
    color = {r=0,g=0,b=0,a=255},
    liquid = true,
    M = ,
    Dm3 = ,
    Hf = ,
    Gf = ,
    cm = ,
  },
  --]]
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
    S = 69.91,
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
    S = 109.2,
    --cm = 75.385,
    cp = 626,
  },
  {
    key = "gH2O", -- gas H2O
    formula = "H2O",
    name = "Watar gas",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    M = 0.01801528,
    Hf = -285830,
    Gf = -237240,
    S = 188.825,
    cp = 1864,
  },
  {
    key = "gH2", -- gas H2
    formula = "H2",
    name = "hydrogen",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    M = 0.01801528,
    Hf = 0,
    Gf = 0,
    S = 130.684,
    cp = 28836,
  },
  {
    key = "gO2", -- gas O2
    formula = "O2",
    name = "Oxigen",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    RM = 15.9994*2,
    Hf = 0,
    Gf = 0,
    cp = 29378,
  },
  {
    key = "gH", -- gas H
    formula = "H",
    name = "hydrogen radical",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    RM = 1.00794,
    Hf = 436000/2, -- energy of chemical bound of H2 / 2
    S = 114.713,
    cp = 28836/2,
  },
  {
    key = "gOH", -- gas OH
    formula = "OH",
    name = "hydrogen radical",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    RM = 1.00794+,
    Hf = 38.99,
    S = -10.75,
    --Gf = ,
    cp = 28836/2,
  },
}

local modname = minetest.get_current_modname()

for _,substance in pairs(substances) do
  chemprod.register_substance(modname, substance)
end

