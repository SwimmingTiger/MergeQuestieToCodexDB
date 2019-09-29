#!/bin/bash
# Export the difference between the Questie database and the ClassicCodex database as Lua scripts

set -e

cd lua
lua convertQuestieQuestDB.lua > ../tmp/quests.lua
