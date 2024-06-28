
chemprod_api.substances = {}
chemprod_api.reactions = {}

local R = 8.31446261815324 -- plynova konstanta

function chemprod_api.calc_gas_molarVolume(substance, T, V, n)
  return V/n
end

function chemprod_api.calc_gas_preasure(substance, T, V, n)
  --p = RT/((a/Vm^2)*(Vm-b))
  
  local Vm = V/n
  return (R*T*Vm^2)/(substance.eos_a*(Vm-substanmce.eos_b))
end

function chemprod_api.calc_deltaG_solid(self, T, p, V)
  -- G = H - TS
  V = self["Vm"]
  
  local dH_coef = 0
  for _, coefs in pairs(self.coefs) do
    dH_coef = dH_coef + coefs.A/(1+math.exp(-(T-coefs.temp)*coefs.B))
    --print(coefs.temp.." -> "..dH_coef.." exp "..math.exp(-(T-coefs.temp)*coefs.B))
  end
  dH_coef = dH_coef*self["dH_coef"]
  return self["dH0"]+dH_coef*T+self.pV_coef*p*V - self["dS"]*T
end

function chemprod_api.calc_deltaG_liquid(self, T, p, V)
  -- G = H - TS
  V = self["Vm"]
  
  local dH_coef = 0
  for _, coefs in pairs(self.coefs) do
    dH_coef = dH_coef + coefs.A/(1+math.exp(-(T-coefs.temp)*coefs.B))
  end
  dH_coef = dH_coef*self["dH_coef"]
  return self["dH0"]+dH_coef*T+self.pV_coef*p*V - self["dS"]*T
end

function chemprod_api.calc_deltaG_gas(self, T, p, V)
  -- G = H - TS
  V = self["Vm"]
  
  local n = 0
  for _, coefs in pairs(self.coefs) do
    n = n + coefs.A/(1+math.exp(-(T-coefs.temp)*coefs.B))
  end
  return self["dH0"]+n*R*T*math.log(p/10e5) - self["dS"]*T
end

function chemprod_api.reactor_volumes(reactor)
  
  local inputs = reactor.substances
  
  -- solid + liquids volume (mixed)
  local Vs = 0
  local Vf = 0 -- free space in solid, can be occupied by liquids or gases
  local Vl = 0
  local Vg = 0
  
  for input, amount in pairs(inputs) do
    local check = chemprod_api.substances[input]
    local in_V = check.Vm*amount
    
    if check.solid then
      Vs = Vs + in_V
      Vf = Vf + in_V*chemprod_api.substances[input].Vf
    elseif check.liquid then
      Vl = Vl + in_V
    elseif check.gaseosum then
      Vg = Vg + in_V
    else
      minetest.log("error", "[chemprod_api] Unknown type of substance.")
    end
  end
  
  reactor.Vs = Vs
  reactor.Vl = Vl
  reactor.Vg = Vg
  if Vl<Vf then
    reactor.Vsl = Vl
    reactor.Vsg = Vf-Vl
  else
    reactor.Vsl = Vf
    reactor.Vsg = 0
  end
  reactor.Vg = reactor.V - Vs - Vl + Vsl + Vsg
  
  if (reactor.Vg<=0) and (Vg>0) then
    minetest.log("error", "[chemprod_api] Bad gas volume.")
  end
end

function chemprod_api.reactor_update(reactor, dtime)
  local inputs = reactor.substances
  
  local Vs = 0
  local Vf = 0
  local Vl = 0
  local Vg = 0
  local gas_amount = 0
  
  for input, amount in pairs(inputs) do
    local in_type = input:sub(1,1)

    if in_type=="s" then
      local in_V = chemprod_api.substances[input].Vm*amount
      Vs = Vs + in_V
      Vf = Vf + in_V*chemprod_api.substances[input].Vf
    elseif in_type=="l" then
      local in_V = chemprod_api.substances[input].Vm*amount
      Vl = Vl + in_V
    elseif in_type=="g" then
      gas_amount = gas_amount + amount
    else
      minetest.log("error", "[chemprod_api] Unknown type of substance.")
    end
  end
  
  local Vsl = Vf
  local Vsg = 0
  
  if Vl<Vf then
    Vsl = Vl
    Vsg = Vf-Vl
  end
  
  if reactor.broken then
    Vg = 0
  end
  
  if (Vg<=0) and (gas_amount>0) then
    -- pV = nRT
    local p = gas_amount*R*reactor.temp/Vg
    local new_amount = gas_amount
    
    if reactor.safety_valve and (p>reactor.safety_valve) then
      -- reduce gas?
      new_amount = new_amount - (p-reactor.safety_valve)*reactor.safety_S*dtime
      new_amount = max(new_amount, 0)
      p = new_amount*R*reactor.temp/Vg
    end
    
    if p>reactor.break_p then
      -- explode
      new_amount = 0
      reactor.broken = true
      -- reduce also liquids?
    end
    
    if new_amount<gas_amount then
      -- reduce gases
      local substances = {}
      for input, amount in pairs(inputs) do
        local in_type = input:sub(1,1)
        if in_type=="g" then
          if new_amount>0 then
            substances[input] = amount*new_amount/gas_amount
          end
        elseif (in_type=="l") and reactor.broken then
          -- nasakavost?
        else
          substances[input] = amount
        end
      end
    end
  end
end

function chemprod_api.calc_reaction(reactor, dtime)
  -- inputs = {input_key = amount}
  
  local inputs = reactor.substances
  local temp = reactor.temp
  
  -- normal reactions
  -- melting, boiling reactions
  -- soliding reactions (liquid to ice) opposite to temp
  
  local substances = {}
  local reactions = {}
  local checked = {}
  
  -- look for aviable reactions
  for input, amount in pairs(inputs) do
    substances[input] = amount
    local substance = chemprod_api.substances[input]
    print("Substance "..input..": "..dump(substance))
    for _, reaction in pairs(substance.reactions) do
      if not checked[reaction] then
        checked[reaction] = true
        print("Reaction "..reaction.." checking")
        local check_r = chemprod_api.reactions[reaction]
        if      ((not check_r.minT) or (check_r.minT<temp))
            and ((not check_r.maxT) or (check_r.maxT>temp)) then
          -- check if all inputs is aviable
          local valid = true
          for r_in,_ in pairs(check_r.inputs) do
            if not inputs[r_in] then
              print("Reaction "..reaction.." input "..r_in.." not found.")
              valid = false
              break
            end
          end
          if valid then
            reactions[reaction] = check_r
          end
        end
      end
    end
  end
  
  local outputs = {}
  local deltaE = 0
  
  -- do aviable reactions
  for key,reaction in pairs(reactions) do
    print("Reaction "..key)
    print(dump(reaction))
    -- v =k*...
    local v = reaction.A * (temp^reaction.B) * math.exp(-reaction.Ea/(R*temp))
    print("v = "..v)
    for input,_ in pairs(reaction.inputs) do
      local X = substances[input]/reactor.V
      v = v * X^reaction.order
    end
    v = v * dtime * chemprod_api.reaction_speed_multiplier
    
    -- effect of mixing etc
    v = v*1
    
    -- round
    local rv = math.floor(v)
    v = v - rv
    if (v>0) then
      if v>=math.random() then
        rv = rv + 1
      end
    end
    
    -- limit speed to prevent consume more then aviable inputs
    for input,amount in pairs(reaction.inputs) do
      if substances[input]<(amount*rv) then
        rv = substances[input]/amount
      end
    end
    
    -- remove inputs, add outputs
    if rv>0 then
      for input,amount in pairs(reaction.inputs) do
        substances[input] = substances[input] - rv*amount
      end
      for output,amount in pairs(reaction.outputs) do
        outputs[output] = (outputs[output] or 0) + rv*amount
      end
    end
    --deltaE = deltaE + v*reaction.deltaE
  end
  
  -- add substances to outputs
  for substance, amount in pairs(substances) do
    if amount>0 then
      outputs[substance] = (outputs[substance] or 0) + amount
    end
  end
  
  -- deltaT = deltaE/sum(cm*n)
  local sumCmN = 0
  for output, amount in pairs(outputs) do
    sumCmN = sumCmN + chemprod_api.substances[output].cm*amount
  end
  
  local out_temp
  if sumCmN > 0 then
    out_temp = reactor.temp + deltaE/sumCmN
  else
    out_temp = reactor.temp
  end
  
  return {
      substances = outputs,
      temp = out_temp,
    }
end

