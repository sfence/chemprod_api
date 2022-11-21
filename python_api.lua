
chemprod = {}

minetest = {}

function minetest.get_current_modname()
  return "chemprod"
end

function minetest.get_modpath()
  return
end
function minetest.register_craftitem()
  return
end

function minetest.log(lvl, msg)
  print("["..lvl.."] "..msg)
end

function dump(var)
  return "no dump aviable"
end

function reload(dir)
  -- reaload all
  chemprod = {
    translate = function(text) return text end,
  }

  dofile(dir.."/functions.lua")
  dofile(dir.."/api.lua")
  dofile(dir.."/substances.lua")
end

function print_substances()
  for key,_ in pairs(chemprod.substances) do
    print(key)
  end
end

function get_substance(name)
  return chemprod.substances[name]
end
  
function calc_deltaG(name, T, p, V)
  local substance = chemprod.substances[name]
  if substance then
    local calc = substance.calc_deltaG or chemprod.calc_deltaG_solid
    return calc(substance, T, p, V)
  end
  return 0
end
