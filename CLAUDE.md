# Janitor — Factorio mod

Factorio 2.0 mod. Press Ctrl+J, configure what to wipe, press Wipe.

## Files

- `info.json` — mod metadata (name, version, author, factorio_version)
- `data.lua` — data stage: defines the `janitor-wipe` custom input (Ctrl+J)
- `control.lua` — runtime stage: GUI and wipe logic
- `locale/en/janitor.cfg`, `locale/ru/janitor.cfg` — localisation

## control.lua structure

1. **Entity type sets** — `CONTAINER_TYPES`, `BELT_TYPES`, `MACHINE_TYPES`, `ROBOT_TYPES`
2. **CATEGORIES** — ordered list of `{id, label}` driving both the GUI checkboxes and wipe dispatch; add new categories here first
3. **Config persistence** — per-player config in `storage.janitor[player.index]`, saved on every GUI close
4. **GUI** — `open_gui` / `close_gui` / `read_gui_config`; surfaces split into Planets | Platforms columns; `read_gui_config` is forward-declared so `close_gui` can call it
5. **Wipe logic** — `wipe_entity` dispatches by `entity.type` against category flags; fluid clearing runs at the end and checks `entity.valid` (robots are destroyed, not cleared)
6. **Events** — `janitor-wipe` input → open GUI; `on_gui_click` → wipe/cancel/select-all/none; `on_gui_closed` → save + close

## Wipe rules

| Category | What happens |
|---|---|
| Containers | `clear_inventories` |
| Belts | `get_transport_line(i).clear()` for lines 1–2 (1–4 for splitters) |
| Inserters | `clear_inventories` + `held_stack.clear()` |
| Machines | `clear_inventories` |
| Train cargo | `clear_inventories` on cargo-wagon |
| Roboports | `clear_inventories` (removes stored robots + repair packs) |
| Robots in flight | `entity.destroy()` |
| Fluids | `fluidbox[i] = nil` on all entities with fluidboxes (orthogonal to other categories) |
| Player inventory | `clear_inventories` skipping armor, guns, ammo slots |

Locomotive fuel is never cleared regardless of settings.

## Localisation

Three sections in each `.cfg`:
- `[controls]` — keybind name shown in Factorio settings
- `[janitor-gui]` — window labels, buttons, done message
- `[janitor-category]` — one key per CATEGORIES entry (id used as key)

When adding a new category: add to `CATEGORIES` in `control.lua`, add handling in `wipe_entity`, add locale keys to both `.cfg` files.
