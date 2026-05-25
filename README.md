# Janitor

A Factorio 2.0 mod that wipes stuff. Useful when you want a clean slate without nuking your save: clear out belts after a refactor, empty every chest before a redesign, dump all the fluids stuck in your spaghetti, kill the swarm of robots circling the screen at 5 fps.

Press a key, tick the boxes for what you want gone, hit Wipe. That's it.

## Install

**From a release zip:**

1. Drop `janitor_<version>.zip` into your Factorio `mods/` folder.
   - Windows: `%APPDATA%\Factorio\mods\`
   - macOS: `~/Library/Application Support/factorio/mods/`
   - Linux: `~/.factorio/mods/`
2. Start Factorio, make sure the mod is enabled, load your save.

**From source:**

```sh
./build.sh
```

Produces `janitor_<version>.zip` in the project root. Copy it into `mods/` as above.

## Usage

1. In-game, press **Ctrl + J** (rebindable in *Settings → Controls → Mod controls → Janitor: Wipe*).
2. A window pops up with two sections:
   - **Surfaces** — which planets and space platforms to wipe. New surfaces are auto-selected the first time you open the GUI.
   - **Wipe** — which categories of stuff to wipe.
3. Use **All** / **None** to bulk-toggle either list.
4. Click **Wipe** to do the deed. **Cancel** (or Esc) closes the window without doing anything.

Your selections are saved per player, per save — next time you open the GUI you get the same boxes ticked.

## What gets wiped

Each category is independent. Tick whatever you need.

| Category | What it does |
|---|---|
| **Chests & containers** | Empties every chest, logistic chest, linked chest, infinity chest. |
| **Transport belts & splitters** | Clears items on belts, undergrounds, splitters, linked belts. |
| **Inserters** | Empties inserter hands and any inserter inventory. |
| **Machines & furnaces** | Empties input/output/fuel slots of assemblers, furnaces, rocket silos, labs, mining drills. **Module slots are kept** — your expensive prod 3s stay in place. |
| **Train cargo wagons** | Empties cargo wagons. Locomotive fuel is **never** touched. |
| **Fluids** | Empties every fluidbox in the game — pipes, tanks, fluid wagons, chem plants, refineries, etc. Orthogonal to the categories above: you can wipe fluids without wiping items, or vice versa. Locomotives are skipped. |
| **Roboports** | Empties roboport storage: removes stored bots and repair packs. |
| **Robots (in flight)** | Destroys construction and logistic robots that are currently in the air. |
| **Player inventory** | Clears the player's main inventory. **Armor, guns, and ammo slots are kept** — you won't end up naked and unarmed on Gleba. |

### What is never wiped

- **Locomotive fuel.** Trains keep running.
- **Module slots** in machines. Modules stay where you put them.
- **Armor, guns, ammo** on the player.
- **Safe Chest** contents (see below).

## Safe Chest

Janitor adds one new item: the **Safe Chest** (orange-tinted requester-chest sprite).

- Recipe: 1 steel chest + 1 electronic circuit, 2s craft time, available from the start.
- 48 slots.
- **Its contents are immune to Janitor wipes**, regardless of the "Chests & containers" setting.

Use it to stash things you want to survive a wipe: blueprint books, spare equipment, the last legendary fish.

## Surfaces

Janitor works per-surface. The GUI splits selections into two columns:

- **Planets** — Nauvis, Vulcanus, Fulgora, Gleba, Aquilo, any modded planets.
- **Platforms** — your space platforms, shown by platform name.

Wipe only the surfaces you tick. Forgetting to untick a platform you didn't mean to clean is on you.

## Warnings

This mod **deletes things**. There is no undo. Read the box before clicking Wipe.

- "Robots (in flight)" *destroys* the robots — they don't return to a roboport. They're gone.
- "Fluids" can leave reactor loops empty mid-tick. Make sure you actually want that.
- On large bases the wipe iterates every entity on every selected surface. Expect a noticeable pause.

If something important got wiped: that's what saves are for.

## Files

- `info.json` — mod metadata.
- `data.lua` — registers the Ctrl+J keybind and the Safe Chest entity/item/recipe.
- `control.lua` — GUI and wipe logic.
- `locale/en/janitor.cfg`, `locale/ru/janitor.cfg` — localisation (English, Russian).
- `build.sh` — packages the mod into a release zip.

