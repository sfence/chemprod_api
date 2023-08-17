
local S = chemprod.translator

local reactions = {
  --[[
  {
    inputs = {},
    outputs = {},
    catalyst = {},
    temp_min = ,
    temp_max = ,
  },
  --]]
  --[[
  {
    inputs = {["SO2"]=2,["O2"]=1},
    outputs = {["SO3"]=2},
    catalyst = {"Pt"},
    temp_max = 500,
  },
  {
    inputs = {["SO3"]=2},
    outputs = {["SO2"=2],["O2"=1]},
    temp_min = 800,
  },
  {
    inputs = {["SO3"]=1,["H2O"]=1},
    outputs = {"H2SO4"},
  },
  --]]
  {
    inputs = {["gO2"]=1,["gH2"]=1},
    outputs = {"gOH"=2},
    A = 2.5e12,
    B = 0,
    ["Ea/R"] = 19630,
  },
  {
    inputs = {["gO2"]=1,["gH2"]=1},
    outputs = {"gH2O"=1,["gH"]=1},
    A = 5.5e13,
    B = 0,
    ["Ea/R"] = 29100,
  },
  --[[{
    inputs = {["gO"]=1,["gH2"]=1},
    outputs = {"gOH","gH"},
    A = 1.8e10,
    B = 1,
    ["Ea/R"] = 4480,
  },--]]
  {
    inputs = {["gH2"]=1,["gOH"]=1},
    outputs = {"gH","gH2O"},
    A = 2.2e13,
    B = 0,
    ["Ea/R"] = 2590,
  },
  --[[{
    inputs = {["gOH"]=1,["gH"]=1,["N2"]=1},
    outputs = {"gOH","gH"},
    A = 2.2e22,
    B = -2,
    ["Ea/R"] = 0,
  },--]]
}

local modname = minetest.get_current_modname()

for _,reaction in pairs(reactions) do
  chemprod.register_reaction(modname, reaction)
end

