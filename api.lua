
local have_tt = minetest.get_modpath("tt")

local Na = 6.022e23 -- pocet molekul v molu
--local WTF = 0.012/Na/12.01115 -- konstanta pro vypocet hmotnosti atomu z relativni atomove/molekularni hmotnosti
--local RM2M = WTF*Na 
local RM2M = 0.012/12.01115

local R = 8.31446261815324 -- plynova konstanta

local sub_ignore_keys = {
    formula = true,
    name = true,
    color = true,
    solid = true,
    liquid = true,
    gaseosum = true,
    M = true,
    RM = true,
    Vm = true,
    Dm3 = true,
    Hf = true,
    cm = true,
    cp = true,
    reactions = true,
    precalc_deltaG = true,
  }

function chemprod_api.register_substance(modname, substance_def, override)
  if not override then
    if chemprod_api.substances[substance_def.key] then
      minetest.log("error", "[chemprod_api] Substance with key "..substance_def.key.." is already registered.")
      return
    end
  end
  
  local substance = {}
  
  substance.formula = substance_def.formula
  substance.name = substance_def.name
  substance.color = substance_def.color
  
  local n = 0
  if substance_def.solid then
    n = n + 1
    substance.solid = true
  end
  if substance_def.liquid then
    n = n + 1
    substance.liquid = true
  end
  if substance_def.gaseosum then
    n = n + 1
    substance.gaseosum = true
  end
  if n~=1 then
    minetest.log("error", "[chemprod_api] Substance "..substance_def.key.." missing/multi state of matter definition.")
    return
  end
  
  -- molar mass
  substance.M = substance_def.M
  if not substance.M then
    if substance_def.RM then
      substance.M = substance_def.RM*RM2M
    else
      minetest.log("error", "[chemprod_api] Substance "..substance_def.key.." molar mass (M [kg/mol]) is not defined and cannot be calculated.")
      return
    end
  end
  
  -- molar volume
  substance.Vm = substance_def.Vm
  if not substance.Vm then
    if substance_def.Dm3 then
      --substance.Vm = 1/(substance_def.Dm3/substance.M)
      substance.Vm = substance.M/substance_def.Dm3
    elseif substance_def.eos_a or substance_def.eos_b or substance_def.gaseosum then
      substance.eos_a = substance_def.eos_a or 1
      substance.eos_b = substance_def.eos_b or 0
      substance.Vm = chemprod_api.calc_gas_molarVolume
    else
      minetest.log("error", "[chemprod_api] Substance "..substance_def.key.." molar volume (Vm [m^3/mol]) is not defined and cannot be calculated.")
      return
    end
  end
  
  -- standard enthalpy of formation
  substance.Hf = substance_def.Hf
  if not substance.Hf then
    minetest.log("error", "[chemprod_api] Substance "..substance_def.key.." standard enthalpy of formation (Hf [J/mol]) is not defined.")
    return
  end
  
  -- standard Gibbs free energy of formation
  --[[
  substance.Gf = substance_def.Gf
  if not substance.Gf then
    minetest.log("error", "[chemprod_api] Substance "..substance_def.key.." standard Gibs free energy of formation (Gf [J/mol]) is not defined.")
    return
  end
  --]]
  
  -- molar heat capacity
  substance.cm = substance_def.cm
  if not substance.cm then
    if substance_def.cp then
      substance.cm = substance_def.cp/substance.M
    else
      minetest.log("error", "[chemprod_api] Substance "..substance_def.key.." molar heat capacity (cm [J/mol/K]) is not defined and cannot be calculated.")
      return
    end
  end
  
  -- empty array
  substance.reactions = {}
  
  -- extra fields
  for key, value in pairs(substance_def) do
    if (not sub_ignore_keys[key]) then
      substance[key] = value
    end
  end
  
  if substance_def.precalc_deltaG then
    substance_def.precalc_deltaG(substance)
  end
  
  chemprod_api.substances[substance_def.key] = substance
  
  minetest.log("warning", "Added substance: "..dump(substance))
  
  if true then
    local description = substance_def.name..""
    if not have_tt then
      description = description.."\n"..substance_def.formula
    end
    minetest.register_craftitem(modname..":"..substance_def.formula, {
        short_desctiption = substance_def.name.."",
        description = description,
        _tt_help = substance_def.formula,
        
        inventory_image = modname.."_"..substance_def.formula..".png",
        
        _chemprod_api = {
          formula = substance_def.formula,
        },
      })
  end
end

function chemprod_api.register_reaction(modname, reaction_def, override)
  if not override then
    if chemprod_api.reactions[reaction_def.key] then
      minetest.log("error", "[chemprod_api] Reaction with key "..reaction_def.key.." is already registered.")
      return
    end
  end
  
  local reaction = {}
  
  -- inputs
  if not reaction_def.inputs then
    minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." inputs is not defined.")
    return
  end
  for input, amount in pairs(reaction_def.inputs) do
    if not chemprod_api.substances[input] then
      minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." input "..input.." is not defined.")
      return
    end
    if amount<=0 then
      minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." input "..input.." has bad amount.")
      return
    end
  end
  reaction.inputs = table.copy(reaction_def.inputs)
  
  -- outputs
  if not reaction_def.outputs then
    minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." outputs is not defined.")
    return
  end
  for output, amount in pairs(reaction_def.outputs) do
    if not chemprod_api.substances[output] then
      minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." output "..output.." is not defined.")
      return
    end
    if amount<=0 then
      minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." output "..output.." has bad amount.")
      return
    end
  end
  reaction.outputs = table.copy(reaction_def.outputs)
  
  -- frequency factor
  reaction.A = reaction_def.A
  if not reaction.A then
    minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." frequency factor is not defined.")
    return
  end
  
  -- expended frequency factor
  reaction.B = reaction_def.B
  if not reaction.B then
    reaction.B = 0
  end
  
  -- activation energy
  reaction.Ea = reaction_def.Ea
  if not reaction.Ea then
    if reaction_def["Ea/R"] then
      reaction.Ea = reaction_def["Ea/R"]*R
    else
      minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." activation energy (Ea [J/mol]) is not defined and cannot be calcualted.")
      return
    end
  end
  
  -- order of reaction
  reaction.order = reaction_def.order or #reaction.inputs
  
  -- hard temp limits allow (optional)
  reaction.minT = reaction_def.minT
  reaction.maxT = reaction_def.maxT
  -- optional speed of reaction directly from ((T-minT)*(maxT-T))/tempV inside allowed temps
  -- replaced by negative Ea
  --reaction.tempV = reaction_def.tempV
  
  --if (reaction.tempV~=nil) then
  --  if (not reaction.minT) or (not reaction.maxT) then
  --    minetest.log("error", "[chemprod_api] Reaction "..reaction_def.key.." definition required minT and maxT, when tempV is used.")
  --    return
  --  end
  --end
  
  -- add info to substances
  for input,_ in pairs(reaction_def.inputs) do
    table.insert(chemprod_api.substances[input].reactions, reaction_def.key)
  end
  
  chemprod_api.reactions[reaction_def.key] = reaction
end

