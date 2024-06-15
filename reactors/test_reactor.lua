---------------------------
-- Test Chemical Reactor --
---------------------------
--------- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = chemprod.translator;

chemprod.test_reactor = appliances.appliance:new(
    {
      node_name_inactive = "chemprod:test_reactor",
      node_name_active = "chemprod:test_reactor_active",
      
      node_description = S("Test chemical reactor"),
      node_help = S("Space for chemical reactions."),
      
      use_stack_size = 0,
      have_usage = false,
    })

local test_reactor = chemprod.test_reactor

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

function test_reactor:recipe_inventory_can_put(pos, listname, index, stack, player_name)
  if player_name then
    if (minetest.is_protected(pos, player_name)) then
      return 0
    end
    if (listname==self.input_stack) then
      if (stack:get_name()=="chemprod:phial_of_substance") then
        return 1
      end
    end
  end
  return 0
end

function test_reactor:recipe_aviable_input(inv)
  local input_stack = inv:get_stack(self.input_stack, 1)
  print("Called for item stack: "..input_stack:to_string())
  if (input_stack:get_name() == "") then
    local input = {
      inputs = 1,
      outputs = {""},
      production_time = 1,
      consumption_step_size = 1,
    }
    print("HERE no input")
    return input, nil
  elseif (input_stack:get_name() == "chemprod:phial_of_substance") then
    local input = {
      inputs = 1,
      outputs = {"chemprod:phial_of_substance"},
      production_time = 10,
      consumption_step_size = 1,
      on_done = function (self, step, outputs)
        outputs[1] = input_stack
        print("HERE done")
        return outputs
      end,
    }
    print("HERE phial")
    return input, nil
  end
  return nil, nil
end

function test_reactor:recipe_room_for_output()
  return true
end

function test_reactor:cb_on_production(timer_step)
  local temp = tonumber(timer_step.meta:get("temp") or "293")
  minetest.log("warning", "Test Reactor production at temperature "..temp)
  local input_stack = timer_step.inv:get_stack(self.input_stack, 1)
  local stack_meta = input_stack:get_meta()
  local substances, msg = minetest.parse_json(stack_meta:get("substances") or "[]")
  if msg then
    print("Json parse error: "..msg)
  end
  local reactor_data = {
    temp = temp,
    V = 1,
    substances = minetest.parse_json(stack_meta:get("substances") or "[]")
    --substances = minetest.deserialize(stack_meta:get("substances") or "return {}")
  }
  local out = chemprod.calc_reaction(reactor_data, timer_step.elapsed)
  print(dump(out))
  timer_step.meta:set_float("temp", out.temp)
  stack_meta:set_string(minetest.write_json(out.substances))
  --stack_meta:set_string(minetest.serialize(out.substances))
  timer_step.inv:set_stack(self.input_stack, 1, input_stack)
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
    mesh = "chemprod_test_reactor.obj",
    use_texture_alpha = "blend",
    collision_box = node_box,
    selection_box = node_box,
 }

local node_inactive = {
    tiles = {
        "chemprod_test_reactor_body.png",
        "chemprod_test_reactor_body2.png",
    },
  }

local node_active = {
    tiles = {
        {
          image = "chemprod_test_reactor_body_active.png",
          animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 2
          }
        },
        "chemprod_test_reactor_body2.png",
    },
  }

test_reactor:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

--[[
appliances.register_craft_type("chemprod_test_reactor", {
    description = S("Composting"),
    icon = "chemprod_chemprod_craft_type_icon.png",
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

  test_reactor:register_recipes("chemprod_test_reactor", "chemprod_test_reactor_usage")
  )
--]]

