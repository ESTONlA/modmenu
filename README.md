# Sir We Have A Mod Menu

A clean in-game mod menu for **Sir, We Have an Orc Problem Playtest**, built for **OrcKit / Orc mod loader**.

Press **F1** in-game to open or close the menu.

## Features

- F1 toggleable overlay menu
- Add upgrade marks, level-finished marks, and perfect/all-killed marks
- Heal base during battle
- Toggle battle pause
- Start wave
- Win battle
- Clear enemies
- Reload current level
- Change game speed: 0.5x, 1x, 2x, 5x
- Enable dev flags such as cheats, refunds, and skip battle end
- Unlock all levels
- Max currently ready upgrades

## Requirements

- Sir, We Have an Orc Problem Playtest
- OrcKit / Orc mod loader installed
- The packaged mod file: `SirWeHaveAModMenu-1.0.2.vmz`

## Install

1. Download `SirWeHaveAModMenu-1.0.2.vmz`.
2. Open the game install folder.
3. Open or create the `mods` folder next to the game executable.
4. Put the `.vmz` file in that folder.

Example Steam path:

```text
C:\Program Files (x86)\Steam\steamapps\common\Sir, We Have an Orc Problem Playtest\mods
```

Your folder should look like this:

```text
Sir, We Have an Orc Problem Playtest/
  Sir, We Have an Orc Problem Playtest.exe
  mods/
    SirWeHaveAModMenu-1.0.2.vmz
```

5. Launch the game with OrcKit installed.
6. Open the OrcKit Mods menu.
7. Enable **Sir We Have A Mod Menu**.
8. Launch with mods.
9. Press **F1** after the game loads.

## Package Layout

The `.vmz` is a zip-compatible archive. It must not contain an extra parent folder.

Correct archive layout:

```text
mod.txt
README.md
scripts/mod_menu.gd
```

Incorrect archive layout:

```text
SirWeHaveAModMenu/mod.txt
SirWeHaveAModMenu/scripts/mod_menu.gd
```

The autoload in `mod.txt` points to:

```ini
[autoload]
SirWeHaveAModMenu="res://scripts/mod_menu.gd"
```

## Troubleshooting

If the menu does not open:

- Fully close and restart the game.
- Confirm the enabled mod version is `1.0.2`.
- Confirm the file is inside the game's `mods` folder.
- Remove older copies such as `SirWeHaveAModMenu.vmz` or `SirWeHaveAModMenu-1.0.1.vmz`.
- If OrcKit keeps loading an old copy, clear the matching `vmz_mount_cache` entry from the game's Godot user data folder.

Common cache folder:

```text
C:\Users\<you>\AppData\Roaming\Sir, We Have an Orc Problem Playtest\vmz_mount_cache
```

Delete only old `SirWeHaveAModMenu*.zip` cache files while the game is closed.

## Development

Loose source layout:

```text
SirWeHaveAModMenu/
  mod.txt
  README.md
  scripts/
    mod_menu.gd
```

When packaging, zip the contents of `SirWeHaveAModMenu/`, not the folder itself, then rename the zip to `.vmz`.

## Notes

This is an autoload-only mod. It does not replace vanilla game scripts.
