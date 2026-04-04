-- janitor
-- Press the button, wipe all the stuff and see how it goes.

local BELT_TYPES = {
  ["transport-belt"]  = true,
  ["underground-belt"] = true,
  ["splitter"]        = true,
  ["linked-belt"]     = true,
}

local function wipe_surface(surface)
  for _, entity in pairs(surface.find_entities()) do
    if not entity.valid then goto continue end

    -- clear every known inventory slot with per-entity exceptions
    local skip = {
      [defines.inventory.character_armor] = true,
      [defines.inventory.character_guns]  = true,
      [defines.inventory.character_ammo]  = true,
    }
    if entity.type == "locomotive" then
      skip[defines.inventory.fuel] = true
    end
    for _, inv_index in pairs(defines.inventory) do
      if not skip[inv_index] then
        local inv = entity.get_inventory(inv_index)
        if inv then inv.clear() end
      end
    end

    -- clear fluids (pipes, tanks, machines, etc.)
    for i = 1, #entity.fluidbox do
      entity.fluidbox[i] = nil
    end

    -- clear transport lines (belts carry items outside of inventories)
    if BELT_TYPES[entity.type] then
      local n = entity.type == "splitter" and 4 or 2
      for i = 1, n do
        entity.get_transport_line(i).clear()
      end
    end

    -- clear inserter hand
    if entity.type == "inserter" and entity.held_stack then
      entity.held_stack.clear()
    end

    ::continue::
  end
end

script.on_event("janitor-wipe", function(event)
  for _, surface in pairs(game.surfaces) do
    wipe_surface(surface)
  end
  game.players[event.player_index].print("[janitor] done.")
end)
