Gain skill points for leveling skills. Configurable formulas, standardized parsing, MCM. 

This mod adds an ability to gain skill points as you improve skills and was meant to go along with Time-Based Enemy Scaling (Automatic) https://www.nexusmods.com/skyrimspecialedition/mods/27203 mod. 
However, this mod is independent, and you can use it with or without mods that change leveling - all it need is vanilla skill level gain event to happen.

The idea is pretty simple, so I decided to develop it further by adding configurable formulas, that suppor: 
-Flat number
-Current skill level
-Current player level
-Any particular skill
-Any school or group of skills (see below) with modifiers.

Example:

"X0.5+SAME_sum0.005-SKILL_c0.0025-WARRIOR_max0.0031-MAGE_min0.0031-THIEF_sum0.0032+Lockpicking0.001"
Flat number, 
same school as the skill we've just leveled up - sum of all skills,
that skill's level,
Warrior school - the 
Mage school
Thief school - 

These formulas can be added in .json files and loaded during the game - all calculations happen when the event fires, so there's no problem changing formulas in-between.