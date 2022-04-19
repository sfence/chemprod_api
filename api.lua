
local have_tt = minetest.get_modpath("tt")

function chemprod.register_substance(modname, substance_def)
  local description = substance_def.name..""
  if not have_tt then
    description = description.."\n"..substance_def.formula
  end
  minetest.register_craftitem(modname..":"..substance_def.formula, {
      short_desctiption = substance_def.name.."",
      description = description,
      _tt_help = substance_def.formula,
      
      inventory_image = modname.."_"..substance_def.formula..".png",
      
      _melting = substance_def.melting,
      _boiling = substance_def.boiling,
    })
end
