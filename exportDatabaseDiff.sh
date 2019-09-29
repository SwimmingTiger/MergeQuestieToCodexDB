#!/bin/bash
# Export the difference between the Questie database and the ClassicCodex database as Lua scripts
set -e
cd "$(dirname "$0")"

cd lua
lua convertQuestieQuestDB.lua > ../tmp/questie-quests.lua
lua diffQuestDB.lua > ../out/quests-patch.lua
