# Merge Questie To Codex DB
A Wow Classic addon that merge the [Questie](https://github.com/AeroScripts/QuestieDev) database into the [ClassicCodex](https://github.com/project-classic/ClassicCodex) database.

This addon is only used to generate database patches for ClassicCodex addon authors, not for normal players.

# Usage
Install `MergeQuestieToCodexDB`, `ClassicCodex` and `Questie` in your Wow classic client. Then run these command:

```
/run MergeQuestieToCodexDB.run()
/reload
```

Then run these command in bash (Linux or WSL):
```
cd "World of Warcraft/_classic_/Interface/AddOns/ClassicCodex/tools"
./update-db-patches.sh ../../../../WTF/Account/xxxxxxxxxx#xxx/SavedVariables/MergeQuestieToCodexDB.lua
```

Then this file will be updated:
```
World of Warcraft/_classic_/Interface/AddOns/ClassicCodex/db-patches/quests-patch.lua
```

# Codex Database Structure

## Bitmask values
(copied from [Questie wiki](https://github.com/AeroScripts/QuestieDev/wiki/Database-Structure#bitmask-values) and edited)

ClassicCodex stores some information as binary values for some (unknown/historical) reason. The following tables translate the values which you can find in the [database.lua](https://github.com/project-classic/ClassicCodex/blob/1fc3507501bc2584790c9a89a6df17827c354813/database.lua#L20) for example. Combinations of those bitmasks are calcualted via a disjunction (you can use [this JSFiddle](https://jsfiddle.net/o5tu4vn9/2/) for testing combinations).

### Races

| Race     | Value | Comment        |
| ---------|:-----:|--------------- |
| Human    | 1     |                |
| Orc      | 2     |                |
| Dwarf    | 4     |                |
| Nightelf | 8     |                |
| Undead   | 16    |                |
| Tauren   | 32    |                |
| Gnome    | 64    |                |
| Troll    | 128   |                |
| Alliance | 77    | =1+4+8+64      |
| Horde    | 178   | =2+16+32+128   |
| All      | 255   | =1+2+4+...+128 |

### Classes

| Class    | Value |
| ---------|:-----:|
| Warrior  | 1     |
| Paladin  | 2     |
| Hunter   | 4     |
| Rogue    | 8     |
| Priest   | 16    |
| Shaman   | 64    |
| Mage     | 128   |
| Warlock  | 256   |
| Druid    | 1024  |

## Database Structure by Files

### db/quest.lua
```lua
CodexDB["quests"]["data"]={
  [questId] = {
    ["start"] = { -- to get the quest
      ["O"] = {objectId, ...},
      ["U"] = {unitId, ...},
    },
    ["end"] = { -- to turnin the quest
      ["O"] = {objectId, ...},
      ["U"] = {unitId, ...},
    },
    ["obj"] = { -- the quest target
      ["I"] = {itemId, ...},
      ["O"] = {objectId, ...},
      ["U"] = {unitId, ...},
    },

    -- pre/next quest ids
    -- Need to complete one of these quests to pick up the quest
    ["pre"] = preQuestId or {preQuestId1, preQuestId2, ...},
    -- Need to complete all these quests to pick up the quest
    ["preg"] = {preQuestId1, preQuestId2, ...},
    -- if this quest is active/finished, the current quest is not available anymore
    ["next"] = nextQuestId,

    -- Quest ids that are mutually exclusive with the quest.
    -- Once you have completed one of these quests, you will not be able to
    -- pick up the quest.
    ["excl"] = {exclusiveQuestId, ...},

    -- The level of the quest required
    ["lvl"] = questLevel,
    ["min"] = questMinLevel,

    -- Cconditions for taking the quest
    ["class"] = playerClassMask,
    ["race"] = playerRaceMask,
    ["skill"] = requiredSkillId or {["id"]=requiredSkillId, ["min"]=minSkillValue},
    ["repu"] = {["id"]=requiredReputationFactionId, ["min"]=minReputationValue},

    -- Hide the quest because it can't be picked up at the current stage
    -- Also included quests related to WoW festive seasons or PVP
    ["hide"] = true,
  },
  ...
}
```

Each field may not exist. For example, `hide` may not exist to indicate that the quest should not be hidden.

| Variate    | Value Type          |
| -----------|:-------------------:|
| xxx`Id`    | int                 |
| xxx`Level` | int                 |
| xxx`Value` | int                 |
| xxx`Mask`  | int, bitmask values |
