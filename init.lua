
chemprod = {
  translator = minetest.get_translator("chemprod")
}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/settings.lua")

dofile(modpath.."/functions.lua")
dofile(modpath.."/api.lua")

dofile(modpath.."/substances.lua")
dofile(modpath.."/reactions.lua")

dofile(modpath.."/reactors/reactors.lua")

