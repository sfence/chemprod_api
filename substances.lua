
local S = chemprod.translator

local substances = {
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
}

local modname = minetest.get_current_modname()

for _,substance in pairs(substances) do
  chemprod.register_substance(modname, substance)
end
