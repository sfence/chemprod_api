
chemprod_api = {
  translator = minetest.get_translator("chemprod_api")
}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/settings.lua")

dofile(modpath.."/functions.lua")
dofile(modpath.."/api.lua")

