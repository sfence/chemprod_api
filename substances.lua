
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
    key = "sH2O", -- solid H2O
    formula = "H2O",
    name = "Water Ice",
    color = {r=0,g=0,b=0,a=255},
    solid = true,
    M = 0.01801528,
    Dm3 = 999.97,
    Hf = -320830,
    Gf = -220000,
    cm = 75.385,
    
    precalc_deltaG = chemprod.precalc_deltaG_solid,
    calc_deltaG = chemprod.calc_deltaG_solid,
    dH0 = -100295280+200,
    dH_coef = 1,
    dS = 35,
    
    pV_coef = -0.5,
    
    coefs = {
      {A=1,B=1,temp=100},
      {A=1,B=1,temp=150},
      {A=1,B=1,temp=200},
      {A=100,B=1,temp=300},
      {A=1,B=1,temp=600},
    },
  },
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
    
    precalc_deltaG = chemprod.precalc_deltaG_liquid,
    calc_deltaG = chemprod.calc_deltaG_liquid,
    dH0 = -100285830,
    dH_coef = -1,
    dS = 70,
    
    pV_coef = 0.0,
    
    coefs = {},
    buf = {
      {A=1,B=1,temp=50},
      {A=1,B=1,temp=100},
      {A=1,B=1,temp=150},
      {A=1,B=1,temp=200},
      {A=200,B=1,temp=300},
    },
  },
  {
    key = "gH2O", -- gas H2O
    formula = "H2O",
    name = "Water Vapor",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    M = 0.01801528,
    Dm3 = 999.97,
    Hf = -241819,
    Gf = -237240,
    cm = 75.385,
    
    precalc_deltaG = chemprod.precalc_deltaG_gas,
    calc_deltaG = chemprod.calc_deltaG_gas,
    dH0 = -100238819+35000,
    dH_coef = 0,
    dS = 189,
    
    pV_coef = 1,
    
    coefs = {
      {A=1,B=1,temp=0},
      {A=1,B=1,temp=50},
      {A=1,B=1,temp=100},
      {A=1,B=1,temp=150},
      {A=1,B=1,temp=200},
    },
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
    
    coefs = {
      {A=1,B=1,temp=100},
      {A=1,B=1,temp=150},
      {A=1,B=1,temp=200},
      {A=1,B=1,temp=300},
      {A=1,B=1,temp=600},
    },
  },
  --[[
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
  --]]
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
    
    eos_a = 1, -- equation of state coeficient
    eos_b = 0, -- equation of state coeficient
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
    
    eos_a = 1, -- equation of state coeficient
    eos_b = 0, -- equation of state coeficient
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
    
    eos_a = 1, -- equation of state coeficient
    eos_b = 0, -- equation of state coeficient
  },
  --[[{
    key = "gO", -- gas O
    formula = "O",
    name = "oxygen radical",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    RM = 1.00794,
    Hf = , -- energy of chemical bound of H2 / 2
    S = ,
    cp = 291002,
    
    eos_a = 1, -- equation of state coeficient
    eos_b = 0, -- equation of state coeficient
  },--]]
  {
    key = "gOH", -- gas OH
    formula = "OH",
    name = "hydrogen radical",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    RM = 1.00794,
    Hf = 38.99,
    S = -10.75,
    --Gf = ,
    cp = 28836/2,
    
    eos_a = 1, -- equation of state coeficient
    eos_b = 0, -- equation of state coeficient
  },
  --[[{
    key = "gHO2", -- gas HO2
    formula = "HO2",
    name = "hydroperoxyl radical",
    color = {r=0,g=0,b=0,a=255},
    gaseosum = true,
    RM = ,
    Hf = ,
    S = ,
    --Gf = ,
    cp = ,
    
    eos_a = 1, -- equation of state coeficient
    eos_b = 0, -- equation of state coeficient
  },--]]
}

local modname = minetest.get_current_modname()

for _,substance in pairs(substances) do
  chemprod.register_substance(modname, substance)
end

