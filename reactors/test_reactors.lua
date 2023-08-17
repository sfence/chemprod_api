------------------------
-- Electric Composter --
------------------------
------- Ver 1.0 --------
-----------------------
-- Initial Functions --
-----------------------
local S = chemprod.translator;

chemprod.test_reactor = appliances.appliance:new(
    {
      node_name_inactive = "composting:test_reactor",
      node_name_active = "composting:test_reactor_active",
      
      node_description = S("Test chemical reactor"),
      node_help = S("Space for chemical reactions.."),
      
      usage_stack = 0,
      have_usage = false,
    })

local test_reactor = composting.test_reactor

test_reactor:item_data_register(
  {
    ["tube_item"] = {
      },
    ["techage_item"] = {
      },
    ["minecart_item"] = {
      },
  })
test_reactor:power_data_register(
  {
    ["time_power"] = {
        run_speed = 1,
        disable = {}
      },
  })

--------------
-- Formspec --
--------------

---------------
-- Callbacks --
---------------

local compost_per_clod = composting.settings.clod_cost
local test_reactor_time = composting.settings.test_reactor_time

local function input_on_done(self, timer_step, output)
  local compost = timer_step.meta:get_int("compost")
  compost = compost + timer_step.use_input.amount
  if compost>=compost_per_clod then
    timer_step.meta:set_int("compost", compost-compost_per_clod)
    return {"composting:compost_clod"}
  end
  timer_step.meta:set_int("compost", compost)
  return {""}
end

function test_reactor:recipe_aviable_input(inventory)
  local input_stack = inventory:get_stack(self.input_stack, 1)
  local input_def = input_stack:get_definition()
  
  if input_def._compost then
    local input = {
        inputs = 1,
        outputs = {"composting:compost_clod"},
        on_done = input_on_done,
        production_time = input_def._compost.amount*test_reactor_time,
        amount = input_def._compost.amount,
      }
    return input, nil
  end
  return nil, nil
end

function test_reactor:recipe_inventory_can_put(pos, listname, index, stack, player)
  local input_def = stack:get_definition()
  if input_def._compost then
    return stack:get_count()
  end
  return 0
end

function test_reactor:recipe_inventory_can_take(pos, listname, index, stack, player_name)
  if player_name then
    if minetest.is_protected(pos, player_name) then
      return 0
    end
  end
  local count = stack:get_count();
  local meta = minetest.get_meta(pos);
  if (listname==self.input_stack) then
    if count>0 then
      local production_time = meta:get_int("production_time")
      if (production_time>0) then
        return count-1
      end
    end
  end
  return count
end

----------
-- Node --
----------

local node_sounds = nil
if minetest.get_modpath("default") then
  node_sounds = default.node_sound_metal_defaults();
end
if minetest.get_modpath("hades_sounds") then
  node_sounds = hades_sounds.node_sound_metal_defaults();
end
if minetest.get_modpath("sounds") then
  node_sounds = sounds.node_metal();
end

-- node box {x=0, y=0, z=0}
local node_box = {
  type = "fixed",
  fixed = {
    {-0.4375,-0.375,-0.4375,0.4375,0.25,0.4375},
    {-0.4375,0.375,-0.4375,0.4375,0.5,0.4375},
    {-0.375,-0.5,-0.375,0.375,-0.375,0.375},
    {-0.375,0.25,-0.375,0.375,0.375,0.375},
    {-0.5,-0.1875,-0.1875,-0.4375,0.1875,0.1875},
    {0.4375,-0.1875,-0.1875,0.5,0.1875,0.1875},
    {-0.0625,-0.0625,0.4375,0.0625,0.0625,0.5},
  },
}

local node_def = {
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = node_sounds,
    drawtype = "mesh",
    mesh = "composting_test_reactor.obj",
    use_texture_alpha = "blend",
    collision_box = node_box,
    selection_box = node_box,
 }

local node_inactive = {
    tiles = {
        "composting_test_reactor_body.png",
        "composting_test_reactor_body2.png",
        "composting_test_reactor_power.png",
        "composting_test_reactor_tube.png",
    },
  }

local node_active = {
    tiles = {
        {
          image = "composting_test_reactor_body_active.png",
          animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 2
          }
        },
        "composting_test_reactor_body2.png",
        "composting_test_reactor_power.png",
        "composting_test_reactor_tube.png",
    },
  }

test_reactor:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

--[[
appliances.register_craft_type("composting_test_reactor", {
    description = S("Composting"),
    icon = "composting_composting_craft_type_icon.png",
    width = 1,
    height = 1,
  })

test_reactor:recipe_register_input(
	"",
	{
		inputs = 1,
		outputs = {"composting:compost_clod"},
		consumption_time = 76,
		consumption_step_size = 1,
	});

  test_reactor:register_recipes("composting_test_reactor", "composting_test_reactor_usage")
  )
--]]

