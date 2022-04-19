
local S = chemprod.translator

chemprod.reactions = {
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
    inputs = {"SO2","O2"},
    outputs = {"SO3"},
    catalyst = {"Pt"},
    temp_max = 500,
  },
  {
    inputs = {"SO3"},
    outputs = {"SO2","O2"},
    temp_min = 800,
  },
  {
    inputs = {"SO3","H2O"},
    outputs = {"H2SO4"},
  },
}

