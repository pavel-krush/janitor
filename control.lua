-- janitor
-- Press the button, wipe all the stuff and see how it goes.

---------------------------------------------------------------------------
-- Entity type sets
---------------------------------------------------------------------------

local CONTAINER_TYPES = {
  ["container"]          = true,
  ["logistic-container"] = true,
  ["linked-container"]   = true,
  ["infinity-container"] = true,
}

local BELT_TYPES = {
  ["transport-belt"]   = true,
  ["underground-belt"] = true,
  ["splitter"]         = true,
  ["linked-belt"]      = true,
}

local ROBOT_TYPES = {
  ["construction-robot"] = true,
  ["logistic-robot"]     = true,
}

local MACHINE_TYPES = {
  ["assembling-machine"] = true,
  ["furnace"]            = true,
  ["rocket-silo"]        = true,
  ["lab"]                = true,
  ["mining-drill"]       = true,
}

---------------------------------------------------------------------------
-- Categories shown in the GUI
---------------------------------------------------------------------------

local CATEGORIES = {
  { id = "containers",       label = {"janitor-category.containers"}    },
  { id = "belts",            label = {"janitor-category.belts"}         },
  { id = "inserters",        label = {"janitor-category.inserters"}     },
  { id = "machines",         label = {"janitor-category.machines"}      },
  { id = "train_cargo",      label = {"janitor-category.train_cargo"}   },
  { id = "fluids",           label = {"janitor-category.fluids"}        },
  { id = "roboports",        label = {"janitor-category.roboports"}       },
  { id = "robots",           label = {"janitor-category.robots"}          },
  { id = "player_inventory", label = {"janitor-category.player_inventory"} },
}

---------------------------------------------------------------------------
-- Config persistence
---------------------------------------------------------------------------

local function default_config()
  local cfg = { surfaces = {}, categories = {} }
  for _, cat in pairs(CATEGORIES) do
    cfg.categories[cat.id] = true
  end
  return cfg
end

local function get_config(player)
  storage.janitor = storage.janitor or {}
  storage.janitor[player.index] = storage.janitor[player.index] or default_config()
  return storage.janitor[player.index]
end

---------------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------------

local GUI_NAME = "janitor_config"

local function open_gui(player)
  if player.gui.screen[GUI_NAME] then
    player.gui.screen[GUI_NAME].destroy()
  end

  local cfg = get_config(player)
  for _, surface in pairs(game.surfaces) do
    if cfg.surfaces[surface.name] == nil then
      cfg.surfaces[surface.name] = true
    end
  end

  local frame = player.gui.screen.add{
    type      = "frame",
    name      = GUI_NAME,
    caption   = {"janitor-gui.title"},
    direction = "vertical",
  }
  frame.auto_center = true
  player.opened = frame

  -- Surfaces
  local surf_header = frame.add{ type = "flow", direction = "horizontal" }
  local surf_label = surf_header.add{ type = "label", caption = {"janitor-gui.surfaces"} }
  surf_label.style.font = "default-bold"
  surf_label.style.horizontally_stretchable = true
  surf_header.add{ type = "button", name = "janitor_surfaces_all",   caption = {"janitor-gui.all"},  style = "mini_button" }
  surf_header.add{ type = "button", name = "janitor_surfaces_none",  caption = {"janitor-gui.none"}, style = "mini_button" }
  local surf_flow = frame.add{ type = "flow", name = "surfaces", direction = "horizontal" }

  local planets, platforms = {}, {}
  for _, surface in pairs(game.surfaces) do
    if surface.platform then
      table.insert(platforms, surface)
    else
      table.insert(planets, surface)
    end
  end

  local function add_surface_group(group_label, surfaces)
    if #surfaces == 0 then return end
    local col = surf_flow.add{ type = "flow", direction = "vertical" }
    local lbl = col.add{ type = "label", caption = group_label }
    lbl.style.font = "default-semibold"
    for _, surface in pairs(surfaces) do
      local caption = surface.platform
        and surface.platform.name
        or (surface.name:sub(1, 1):upper() .. surface.name:sub(2))
      col.add{
        type    = "checkbox",
        name    = "janitor_surface_" .. surface.name,
        caption = caption,
        state   = cfg.surfaces[surface.name] ~= false,
      }
    end
  end

  add_surface_group({"janitor-gui.planets"},   planets)
  add_surface_group({"janitor-gui.platforms"}, platforms)

  frame.add{ type = "line" }

  -- Categories
  local cat_header = frame.add{ type = "flow", direction = "horizontal" }
  local cat_label = cat_header.add{ type = "label", caption = {"janitor-gui.wipe"} }
  cat_label.style.font = "default-bold"
  cat_label.style.horizontally_stretchable = true
  cat_header.add{ type = "button", name = "janitor_categories_all",  caption = {"janitor-gui.all"},  style = "mini_button" }
  cat_header.add{ type = "button", name = "janitor_categories_none", caption = {"janitor-gui.none"}, style = "mini_button" }
  local cat_flow = frame.add{ type = "flow", name = "categories", direction = "vertical" }
  for _, cat in pairs(CATEGORIES) do
    cat_flow.add{
      type    = "checkbox",
      name    = "janitor_cat_" .. cat.id,
      caption = cat.label,
      state   = cfg.categories[cat.id] ~= false,
    }
  end

  frame.add{ type = "line" }

  -- Buttons
  local btn_flow = frame.add{ type = "flow", direction = "horizontal" }
  btn_flow.add{ type = "button", name = "janitor_wipe",   caption = {"janitor-gui.wipe"},   style = "red_button" }
  btn_flow.add{ type = "button", name = "janitor_cancel", caption = {"janitor-gui.cancel"} }
end

local function close_gui(player)
  if player.gui.screen[GUI_NAME] then
    player.gui.screen[GUI_NAME].destroy()
  end
end

local function read_gui_config(player)
  local frame = player.gui.screen[GUI_NAME]
  if not frame then return nil end

  local cfg = { surfaces = {}, categories = {} }

  local function read_checkboxes(flow, prefix, out)
    for _, child in pairs(flow.children) do
      if child.type == "checkbox" then
        local key = child.name:match("^" .. prefix .. "(.+)$")
        if key then out[key] = child.state end
      elseif child.type == "flow" then
        read_checkboxes(child, prefix, out)
      end
    end
  end
  read_checkboxes(frame.surfaces, "janitor_surface_", cfg.surfaces)

  for _, cb in pairs(frame.categories.children) do
    local id = cb.name:match("^janitor_cat_(.+)$")
    if id then cfg.categories[id] = cb.state end
  end

  return cfg
end

---------------------------------------------------------------------------
-- Wipe logic
---------------------------------------------------------------------------

local CHAR_SKIP = {
  [defines.inventory.character_armor] = true,
  [defines.inventory.character_guns]  = true,
  [defines.inventory.character_ammo]  = true,
}

local function clear_inventories(entity, skip)
  for _, inv_index in pairs(defines.inventory) do
    if not (skip and skip[inv_index]) then
      local inv = entity.get_inventory(inv_index)
      if inv then inv.clear() end
    end
  end
end

local function clear_inventories_keep_modules(entity)
  local module_inv = entity.get_module_inventory()
  local skip = nil
  if module_inv then
    skip = { [module_inv.index] = true }
  end
  clear_inventories(entity, skip)
end

local function clear_fluids(entity)
  for i = 1, #entity.fluidbox do
    entity.fluidbox[i] = nil
  end
end

local function wipe_entity(entity, cfg)
  if not entity.valid then return end
  if entity.name == "janitor-safe-chest" then return end
  local t = entity.type

  if CONTAINER_TYPES[t] and cfg.categories.containers then
    clear_inventories(entity)

  elseif BELT_TYPES[t] and cfg.categories.belts then
    for i = 1, entity.get_max_transport_line_index() do
      entity.get_transport_line(i).clear()
    end

  elseif t == "inserter" and cfg.categories.inserters then
    clear_inventories(entity)
    if entity.held_stack then entity.held_stack.clear() end

  elseif MACHINE_TYPES[t] and cfg.categories.machines then
    clear_inventories_keep_modules(entity)

  elseif t == "cargo-wagon" and cfg.categories.train_cargo then
    clear_inventories(entity)

  elseif t == "roboport" and cfg.categories.roboports then
    clear_inventories(entity)

  elseif ROBOT_TYPES[t] and cfg.categories.robots then
    entity.destroy()

  elseif t == "character" and cfg.categories.player_inventory then
    clear_inventories(entity, CHAR_SKIP)
  end

  -- fluids are orthogonal: apply to anything with fluidboxes
  if cfg.categories.fluids and t ~= "locomotive" and entity.valid then
    clear_fluids(entity)
  end
end

local function run_wipe(player, cfg)
  for surface_name, selected in pairs(cfg.surfaces) do
    if selected then
      local surface = game.surfaces[surface_name]
      if surface then
        for _, entity in pairs(surface.find_entities()) do
          wipe_entity(entity, cfg)
        end
      end
    end
  end
  player.print({"janitor-gui.done"})
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

script.on_event("janitor-wipe", function(event)
  open_gui(game.players[event.player_index])
end)

local function set_all_checkboxes(flow, state)
  for _, child in pairs(flow.children) do
    if child.type == "checkbox" then
      child.state = state
    elseif child.type == "flow" then
      set_all_checkboxes(child, state)
    end
  end
end

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  local name   = event.element.name
  local frame  = player.gui.screen[GUI_NAME]

  if name == "janitor_wipe" then
    local cfg = read_gui_config(player)
    if cfg then
      storage.janitor[player.index] = cfg
      close_gui(player)
      run_wipe(player, cfg)
    end

  elseif name == "janitor_cancel" then
    close_gui(player)

  elseif name == "janitor_surfaces_all" and frame then
    set_all_checkboxes(frame.surfaces, true)

  elseif name == "janitor_surfaces_none" and frame then
    set_all_checkboxes(frame.surfaces, false)

  elseif name == "janitor_categories_all" and frame then
    set_all_checkboxes(frame.categories, true)

  elseif name == "janitor_categories_none" and frame then
    set_all_checkboxes(frame.categories, false)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == GUI_NAME then
    close_gui(game.players[event.player_index])
  end
end)
