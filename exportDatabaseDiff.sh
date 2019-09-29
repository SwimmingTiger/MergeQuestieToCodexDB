#!/bin/bash
# Export the difference between the Questie database and the ClassicCodex database as Lua scripts
set -e
cd "$(dirname "$0")"
BASEDIR=$PWD

cd ../ClassicCodex
codexVersion=$(git describe --always --tag --long)

cd ../QuestieDev
questieVersion=$(git describe --always --tag --long)

cd "$BASEDIR/lua"

lua convertQuestieQuestDB.lua > ../tmp/questie-quests.lua
lua diffQuestDB.lua "$codexVersion" "$questieVersion" > ../out/quests-patch.lua
