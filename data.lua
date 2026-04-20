local orange = {r=1.0, g=0.5, b=0.0, a=1.0}

data:extend({
  {
    type           = "custom-input",
    name           = "janitor-wipe",
    key_sequence   = "CONTROL + J",
    localised_name = {"controls.janitor-wipe"},
  },

  -- Safe chest entity (immune to janitor wipe)
  {
    type               = "container",
    name               = "janitor-safe-chest",
    icons              = {{icon = "__base__/graphics/icons/requester-chest.png", tint = orange}},
    flags              = {"placeable-player", "player-creation"},
    minable            = {mining_time = 0.1, result = "janitor-safe-chest"},
    max_health         = 350,
    corpse             = "small-remnants",
    collision_box      = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box      = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size     = 48,
    impact_category    = "metal",
    open_sound         = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
    close_sound        = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
    picture = {
      filename   = "__base__/graphics/entity/logistic-chest/requester-chest.png",
      priority   = "extra-high",
      width      = 66,
      height     = 74,
      frame_count = 1,
      shift      = {0, -0.0625},
      scale      = 0.5,
      tint       = orange,
    },
  },

  -- Item
  {
    type       = "item",
    name       = "janitor-safe-chest",
    icons      = {{icon = "__base__/graphics/icons/requester-chest.png", tint = orange}},
    subgroup   = "logistic-network",
    order      = "b[storage]-f[janitor-safe-chest]",
    place_result = "janitor-safe-chest",
    stack_size = 50,
  },

  -- Recipe
  {
    type           = "recipe",
    name           = "janitor-safe-chest",
    enabled        = true,
    energy_required = 2,
    ingredients    = {
      {type = "item", name = "steel-chest",        amount = 1},
      {type = "item", name = "electronic-circuit", amount = 1},
    },
    results        = {{type = "item", name = "janitor-safe-chest", amount = 1}},
  },
})
