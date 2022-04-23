
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
}

