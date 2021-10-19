### Gain skill points for leveling skills. Configurable formulas, standardized parsing, MCM. 

This mod adds an option to gain skill points as you improve skills - not just character level.

REQUIREMENTS:

SKSE64  
PapyrusUtil  

### What & why:  
 
This mod is meant to go along with Time-Based Enemy Scaling (Automatic) https://www.nexusmods.com/skyrimspecialedition/mods/27203 mod.  
However, PPPSU doesn't require it, and all you need is skill levelup events to happen.  
In general, this mod allows you to have more specific progression towards the next perk point instead of flat "new level - new perk".  

### Features:
	Multiple formulas  
	Different basic rules (archery in Warrior or Sneak, for example)  
	Configurable number of perk points given  
	Configurable progress value needed.  

### How to use:  
Install SKSE64 and PapyrusUtil,  
Install the mod,  
Go to MCM menu and choose a preset  

There are 6 presets so far:  
	early-learner: more perk points at the beginning, less and less with time;  
	schools-based: more points from schools, less point as your character level increases;  
	skill-based: greater skill levels = more perk points, default preset;  
	speciality-all: specialize in one school and get more perks from it, less perks from other schools;  
	speciality-best: same as previous, but less restrictive;  
	speciality-SkyRe: SkyRe-specific version of "speciality-all", less influence from Wayfarer skill;  

### Performance:  
	The formula itself is loaded only when you choose it in MCM (or at the start of the game - default.json is loaded), or switch rulesets.  
	Calculations happen every time you get a skill level.  
	The load depends on formula complexity, but it's fast for a single level (or a few levels at once).
	Getting many skill levels at a time will not affect performance, but calculations may take some time (~4s for 14 levels, for example).    

### Additional information:  

If you get multiple levels at once, calculations will take some time (depends on formula complexity), as they are taking each gained level one by one.  

*Technically, skill are just actor values, so you can put any existing AV into a category and use it in calculations.  

### Advanced settings:  
  
The idea itself is pretty simple, so I decided to expand it with configurable formulas, stored in .json files at "\SKSE\Plugins\pppsu_formulas" and loaded through MCM.  

Formulas can have elements of "TagValue", i.e. MAGE_min0.01  
In this example, tag consists of a school (MAGE) and a modifier (_min).  

Modifiers are: 
_max and _min - the most and least developed skills in a school; 
_sum - the sum of all skills levels in a school; 
_legendary - the sum of all legendary levels in a school. 

These can be applied together with any defined school, i.e. WARRIOR_sum, THIEF_max, etc.  
There's also a specific SAME category, which takes the same school as of the skill we've just upgraded.  
So, for example, if we've just leveled up OneHanded skill, SAME_sum will be equal to WARRIOR_sum.  

The exact categories are defined by rulesets in separate .json files in "\SKSE\Plugins\pppsu".  
Such system allows you to change categories by swapping skills between schools  
(i.e. marksmanship can be a warrior skill, or a thief skill - see "Vanilla" and "Vanilla_fixed" rulesets, accordingly),  
or even add your own categories to exclude some skills from calculations (see "Craft" ruleset).  

Additionally, there are specific tags: 
-Flat number (X),  
-Current skill level (SKILL_c),  
-Current player level (LEVEL_c),  
-Any player skill *(see "Additional information" below).  
These don't support any modifiers, i.e. SKILL_c0.001 or destruction0.0023, etc.  

In the end, every skill level up gives you a progress value, and reaching a certain value (1 by default, configurable in MCM) is gieves you a perk point. You can define how many perk points are given and what progress value do you need to reach, allowing you to balance easier. 

Example:  

"X0.5+SAME_sum0.005-SKILL_c0.0025-WARRIOR_max0.0031-MAGE_min0.0031-THIEF_sum0.0032+Lockpicking0.001" 

+Flat 0.5,  
+(sum of all skills in the same school as the skill we've just leveled up) * 0.005, 
-(that skill's level) * 0.0025,  
-(Warrior school: the most developed skill level) * 0.0031,  
-(Mage school: the least developed skill level) * 0.0031,  
-(Thief school: sum of all skills in that school) * 0.0032,  
+(Lockpicking skill level) * 0.001.  