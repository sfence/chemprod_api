
local substances = {
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
}

local modname = minetest.get_current_modname()

for _,substance in pairs(substances) do
  chemprod_api.register_substance(modname, substance)
end

