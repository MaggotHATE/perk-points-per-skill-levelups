scriptName PerkPointsPerSkillUpsMCM extends SKI_ConfigBase

;-- Properties --------------------------------------

actor property PlayerRef auto
globalvariable property SkillUps auto
globalvariable property SkillUpsPerPerkPoint auto
globalvariable property PerkPointsPerDeposit auto
quest property PerkPointsPerSkillUpsQ auto
string[] property FormulaTypes auto
float[] property FormulaVals auto
int[] property FormulaOpers auto
int idx
int[] property PlayerSkillsStored auto
form property PPPSUMCM auto
;string CurrentSkill

;-- Variables ---------------------------------------
string testfrml = ""
float PPPSUcalculated
String[] formulasLoaded
String[] tagsLoaded
int selectedFileIndex = 0
string selectedFileName = "default"
bool skillLess = false
;"LEVEL_c0.3-SKILL_c0.1+MAGE_max0.1+SAME_max0.2"
;string[] pppsu/system = ["LEVEL","SKILL","MAGE_max","MAGE_min","MAGE_sum","MAGE_legend","WARRIOR_max","WARRIOR_min","WARRIOR_sum","WARRIOR_legend","THIEF_max","THIEF_min","THIEF_sum","THIEF_legend","SAME_max","SAME_min","SAME_sum","SAME_legend"]
; PLANS
; precalc for "flat number only" formulas
; add mult for PP per deposit
; 

;-- Events ------------------------------------------


Event OnGameReload()
	Debug.MessageBox("OnGameReload1")
	parent.OnGameReload() ;Important!
	testfrml = JsonUtil.GetStringValue("../pppsu_presets/"+selectedFileName,"formula")
	GetParsed(testfrml)
	GetParsed1(testfrml, false)
	GetParsed(testfrml, "mage", false)
	GetParsed(testfrml, "warrior", false)
	GetParsed(testfrml, "thief", false)
	
	StoreSkills(SkillUps)
	tagsLoaded = getTagLists("../pppsu/system.json") 
	Debug.Notification("sneak="+ProcessFormula1("sneak"))
	; PageInit()
endEvent

;-- Functions ---------------------------------------

string function GETtestfrml()
	return testfrml
endFunction

function ResetFormula()
	Debug.Notification("Resetting formula...")
	selectedFileName = "default"
	testfrml = JsonUtil.GetStringValue("../pppsu_presets/"+selectedFileName,"formula")
	GetParsed(testfrml)
	GetParsed(testfrml, "mage", false)
	GetParsed(testfrml, "warrior", false)
	GetParsed(testfrml, "thief", false)
endFunction

float function ProcessFormula(string CurrentSkill)
	int x = idx - 1
	float tempPPoints = 0
	;Debug.Notification("CurrentSkill="+CurrentSkill)
	string bySkill = GetSchoolBySkill(CurrentSkill)
	while x >= 0
		float xx = 0
		if FormulaTypes[x] == "X"
			xx += 1
		elseif FormulaTypes[x] == "LEVEL_c"
			xx += PlayerRef.getlevel()
		elseif FormulaTypes[x] == "SKILL_c" && PlayerRef.getav(CurrentSkill)
			xx += PlayerRef.getav(CurrentSkill)
		elseif FormulaTypes[x] == "MAGE_max"
			xx += GetSchool("mage","max")
		elseif FormulaTypes[x] == "MAGE_min"
			xx += GetSchool("mage","min")
		elseif FormulaTypes[x] == "MAGE_sum"
			xx += GetSchool("mage","sum")
		elseif FormulaTypes[x] == "MAGE_legend"
			xx += GetSchool("mage","legend")
		elseif FormulaTypes[x] == "WARRIOR_max"
			xx += GetSchool("warrior","max")
		elseif FormulaTypes[x] == "WARRIOR_min"
			xx += GetSchool("warrior","min")
		elseif FormulaTypes[x] == "WARRIOR_sum"
			xx += GetSchool("warrior","sum")
		elseif FormulaTypes[x] == "WARRIOR_legend"
			xx += GetSchool("warrior","legend")
		elseif FormulaTypes[x] == "THIEF_max"
			xx += GetSchool("thief","max")
		elseif FormulaTypes[x] == "THIEF_min"
			xx += GetSchool("thief","min")
		elseif FormulaTypes[x] == "THIEF_sum"
			xx += GetSchool("thief","sum")
		elseif FormulaTypes[x] == "THIEF_legend"
			xx += GetSchool("thief","legend")
		elseif FormulaTypes[x] == "SAME_max"
			xx += GetSchool(bySkill,"max")
		elseif FormulaTypes[x] == "SAME_min"
			xx += GetSchool(bySkill,"min")
		elseif FormulaTypes[x] == "SAME_sum"
			xx += GetSchool(bySkill,"sum")
		elseif FormulaTypes[x] == "SAME_legend"
			xx += GetSchool(bySkill,"legend")
		elseif GetSchoolBySkill(FormulaTypes[x]) != "EXCEPTION_SCHOOL_NULLPOINTER"
			xx += PlayerRef.getav(FormulaTypes[x])
		endif
		
		tempPPoints += xx*FormulaVals[x]*FormulaOpers[x]
		;Debug.Notification("#"+x+" "+FormulaTypes[x]+" ="+tempPPoints)
		x -= 1
	endwhile
	if tempPPoints < 0.001
		tempPPoints = 0.001
	endif
	return tempPPoints
endFunction

bool function HasMod(string cMod)
	return JsonUtil.StringListHas("../pppsu/system.json", "mods", cMod)
endFunction

bool function HasTag(string cTag)
	string[] tagList = getTagLists("../pppsu/system.json")
	if tagList.Find(cTag) > -1
		return true
	endif
	return false
endFunction

float function ProcessFormula1(string CurrentSkill)
	int x = idx - 1
	float tempPPoints = 0
	;Debug.Notification("CurrentSkill="+CurrentSkill)
	string bySkill = GetSchoolBySkill(CurrentSkill)
	while x >= 0
		float xx = 0
		if FormulaTypes[x] == "X"
			xx += 1
		elseif FormulaTypes[x] == "LEVEL_c"
			xx += PlayerRef.getlevel()
		elseif FormulaTypes[x] == "SKILL_c" && PlayerRef.getav(CurrentSkill)
			xx += PlayerRef.getav(CurrentSkill)	
		elseif GetSchoolBySkill(FormulaTypes[x]) != "EXCEPTION_SCHOOL_NULLPOINTER"
			xx += PlayerRef.getav(FormulaTypes[x])
		else
			int y = StringUtil.Find(FormulaTypes[x], "_")
			string tempTag = StringUtil.Substring(FormulaTypes[x], 0, y)
			string tempMod = StringUtil.Substring(FormulaTypes[x], y+1)
			if HasMod(tempMod)
				if HasTag(tempTag)
					Debug.Notification("PF1: "+tempTag+tempMod)
					xx += GetSchool(tempTag,tempMod)
				elseif tempTag == "SAME"
					xx += GetSchool(bySkill,tempMod)
				endif
			endif
		endif
		
		tempPPoints += xx*FormulaVals[x]*FormulaOpers[x]
		;Debug.Notification("#"+x+" "+FormulaTypes[x]+" ="+tempPPoints)
		x -= 1
	endwhile
	if tempPPoints < 0.001
		tempPPoints = 0.001
	endif
	return tempPPoints
endFunction

int function GetSchool (string school, string method)
	int result = 0
	if method == "max"
		int x = 0
		string xx = JsonUtil.StringListGet("../pppsu/system.json", school,x)
		while xx
			int tempAV = PlayerRef.getav(xx) as int
			if result < tempAV
				result = tempAV
			endif
			x += 1
			xx = JsonUtil.StringListGet("../pppsu/system.json", school,x)
			
		endWhile
		;Debug.Notification("max "+school+" "+result)
	elseif method == "min"
		int x = 0
		string xx = JsonUtil.StringListGet("../pppsu/system.json", school,x)
		result = PlayerRef.getav(xx) as int
		while xx
			int tempAV = PlayerRef.getav(xx) as int
			if result > tempAV
				result = tempAV
			endif
			x += 1
			xx = JsonUtil.StringListGet("../pppsu/system.json", school,x)
		endWhile
		;Debug.Notification("min "+school+" "+result)
	elseif method == "sum"
		int x = 0
		string xx = JsonUtil.StringListGet("../pppsu/system.json", school,x)
		while xx
			result += PlayerRef.getav(xx) as int
			x += 1
			xx = JsonUtil.StringListGet("../pppsu/system.json", school,x)
		endWhile
		;Debug.Notification("sum "+school+" "+result)
	elseif method == "legend"
		int x = 0
		string xx = JsonUtil.StringListGet("../pppsu/system.json", school,x)
		while xx
			result += ActorValueInfo.GetAVIByName(xx).GetSkillLegendaryLevel()
			x += 1
			xx = JsonUtil.StringListGet("../pppsu/system.json", school,x)
		endWhile
		;Debug.Notification("legend "+school+" "+result)
	endif
	;Debug.Notification("#"+idx + " " + school+" "+method+" "+result)
	return result
endFunction

string function GetSchoolBySkill(string theSkill)	
	if JsonUtil.StringListHas("../pppsu/system.json", "mage",theSkill)
		return "mage"
	elseif JsonUtil.StringListHas("../pppsu/system.json", "warrior",theSkill)
		return "warrior"
	elseif JsonUtil.StringListHas("../pppsu/system.json", "thief",theSkill)
		return "thief"
	else
		Debug.MessageBox("Wrong school setup or skill!")
		return "EXCEPTION_SCHOOL_NULLPOINTER"
	endif
endFunction

function GetParsed(string formula, string tags = "TAGS", bool resetIDX = true)
	if resetIDX == true
		idx = 0
		skillLess = true
	endif

	int x = 0
	
	string xx = JsonUtil.StringListGet("../pppsu/system.json", tags,x)
	while xx
		int xxx = StringUtil.Find(formula, xx)
		if xxx != -1
			;Debug.Notification("Found " + xx+ " tag #"+x+" at "+xxx)
			int y = xxx + StringUtil.GetLength(xx) 
			string yy = StringUtil.getNthChar(formula,y)
			string yyy = ""
			;Debug.Notification("symbol " + yy)
			while StringUtil.IsDigit(yy) || (yy == ".")
				yyy += yy
				y += 1
				yy = StringUtil.getNthChar(formula,y)
			endwhile
			;Debug.Notification("Result: "+ xx + "*" + yyy as float)
			FormulaTypes[idx] = xx
			if xx == "SKILL_c" || StringUtil.Find(xx, "SAME")
				skillLess = false
			endif
			FormulaVals[idx] = yyy as float
			if xxx > 0
				if StringUtil.getNthChar(formula,(xxx - 1)) == "-"
					FormulaOpers[idx] = -1
				else 
					FormulaOpers[idx] = 1
				endif
			else 
				FormulaOpers[idx] = 1
			endif
			;Debug.Notification(idx+": " + FormulaOpers[idx] + " " + FormulaTypes[idx] + " * " + FormulaVals[idx])
			idx += 1
		endif
		x += 1
		xx = JsonUtil.StringListGet("../pppsu/system.json", tags,x)
	endWhile
	;Debug.Notification("Finished "+tags)
endFunction

string[] function getTagLists(string path)
	string[] tagList = JsonUtil.PathMembers(path, ".stringList")
	
	;Debug.Notification("tempTagList 0 = "+tagList[0])
	return tagList
endFunction

float function getDigit(string formula, int undscrPos, string getMod)
	int digPos = undscrPos+StringUtil.getLength(getMod)
	string digSym = StringUtil.getNthChar(formula,digPos)
	string digit = ""
	;Debug.Notification("symbol " + yy)
	while StringUtil.IsDigit(digSym) || (digSym == ".")
		digit += digSym
		digPos += 1
		digSym = StringUtil.getNthChar(formula,digPos)
	endwhile
	return digit as float
endFunction

function GetParsed1(string formula, bool resetIDX = true)
	if resetIDX == true
		idx = 0
		skillLess = true
	endif

	int x = 0
	int y = 0
	
	string[] tagList = getTagLists("../pppsu/system.json")
	while y < tagList.Length
		int xxxx = StringUtil.Find(formula, tagList[y])
		if xxxx != -1
			int undscrPos = xxxx+StringUtil.getLength(tagList[y])
			string undscr = StringUtil.getNthChar(formula, undscrPos)
			if undscr == "_"
				int yy = 0
				string getMod = JsonUtil.StringListGet("../pppsu/system.json", "mods",yy)
				while getMod
					if getMod == StringUtil.Substring(formula, undscrPos, StringUtil.getLength(getMod))
						float digit = getDigit(formula, undscrPos, getMod)
						if xxxx > 0 && digit != 0
							if StringUtil.getNthChar(formula,(xxxx - 1)) == "-"
								FormulaOpers[idx] = -1
							else 
								FormulaOpers[idx] = 1
							endif
						else 
							FormulaOpers[idx] = 1
						endif
						Debug.Notification("YES "+tagList[y]+getMod+" * "+digit+"*"+FormulaOpers[idx])
						FormulaTypes[idx] = tagList[y]+getMod
						FormulaVals[idx] = digit
						idx += 1
					endif
					
					yy += 1
					getMod = JsonUtil.StringListGet("../pppsu/system.json", "mods",yy)
				endWhile
			endif
		endif
		y += 1
	endWhile
	
	
endFunction

function StoreSkills(form storeForm)
	StorageUtil.SetIntValue(storeForm, "pppsu_Alteration",PlayerRef.getbaseav("Alteration") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Conjuration",PlayerRef.getbaseav("Conjuration") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Destruction",PlayerRef.getbaseav("Destruction") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Enchanting",PlayerRef.getbaseav("Enchanting") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Restoration",PlayerRef.getbaseav("Restoration") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Illusion",PlayerRef.getbaseav("Illusion") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Marksman",PlayerRef.getbaseav("Marksman") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Block",PlayerRef.getbaseav("Block") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_HeavyArmor",PlayerRef.getbaseav("HeavyArmor") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Onehanded",PlayerRef.getbaseav("Onehanded") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Smithing",PlayerRef.getbaseav("Smithing") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Twohanded",PlayerRef.getbaseav("Twohanded") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Alchemy",PlayerRef.getbaseav("Alchemy") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_LightArmor",PlayerRef.getbaseav("LightArmor") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Lockpicking",PlayerRef.getbaseav("Lockpicking") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Pickpocket",PlayerRef.getbaseav("Pickpocket") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Sneak",PlayerRef.getbaseav("Sneak") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Speechcraft",PlayerRef.getbaseav("Speechcraft") as int)
	;Debug.Notification("Finished StoreSkills. Smithing: "+StorageUtil.GetIntValue(storeForm, "pppsu_"+"Smithing"))
endFunction

function OnConfigInit()

	PageInit()
	if FormulaTypes.Length == 0
		FormulaTypes = new string[128]
	endif
	if FormulaOpers.Length == 0
		FormulaOpers = new int[128]
	endif
	if FormulaVals.Length == 0
		FormulaVals = new float[128]
	endif
	if PlayerSkillsStored.Length == 0
		PlayerSkillsStored = new int[128]
	endif
	
	;PPPSUMCM = Game.GetFormFromFile(0x00000800, "PerkPointsPerSkillUps.esp") as PerkPointsPerSkillUpsMCM
	StoreSkills(SkillUps)

	; testfrml = JsonUtil.GetStringValue("../pppsu_presets/"+selectedFileName,"formula")
	; GetParsed(testfrml)
	; GetParsed(testfrml, "mage")
	; GetParsed(testfrml, "warrior")
	; GetParsed(testfrml, "thief")
	;PPPSUcalculated = ProcessFormula("TwoHanded")
	;Debug.Messagebox("Formula result: "+PPPSUcalculated+" skill points per skill upgrade!")
	;StorageUtil.SetFloatValue(none, "PPPSUcalculated", PPPSUcalculated)
	
	Debug.MessageBox("OnConfigInit")	
endFunction

event OnConfigClose()

endEvent

function PageInit()
	ModName = "$PerkPointsPerSkillUpsMCM_Name"
	Pages = new String[12]
	Pages[0] = "$PerkPointsPerSkillUpsMCM_p0"
	Pages[1] = "$PerkPointsPerSkillUpsMCM_p1"
	Debug.MessageBox("PageInit")
endFunction




Int function GetVersion()

	return 1
endFunction

string function GetJsonFormula()
	JsonUtil.Unload("../pppsu/formula0.json")
	return JsonUtil.GetStringValue("../pppsu/formula0.json","formula")
endFunction

function LoadJsonFormulas()
	formulasLoaded = JsonUtil.JsonInFolder("../pppsu_presets")
endFunction

event OnVersionUpdate(int a_version)
	if (a_version >= 2 && CurrentVersion < 2)
		PageInit()
	endif
endEvent

function OnPageReset(String a_page)

	if a_page == "$PerkPointsPerSkillUpsMCM_p0"
		
		self.SetCursorFillMode(self.LEFT_TO_RIGHT)
		
		self.AddHeaderOption("$pppsu_HEADER0")
		self.AddEmptyOption()
		self.AddSliderOptionST("pppsu_NumberOfPP", "$pppsu_NumberOfPPT", SkillUpsPerPerkPoint.GetValue() as float, "{1}")
		self.AddEmptyOption()
		self.AddSliderOptionST("pppsu_PPperDep", "$pppsu_PPperDepT", PerkPointsPerDeposit.GetValue() as float, "{1} each time")
		self.AddEmptyOption()
		self.AddMenuOptionST("pppsuFormulasMenu", "$pppsu_FM", formulasLoaded[selectedFileIndex])
		
	elseif a_page == "$PerkPointsPerSkillUpsMCM_p1"
		self.SetCursorFillMode(self.LEFT_TO_RIGHT)
		float calc_AVGcalc = 0.0
		;if skillLess == false
		calc_AVGcalc = ProcessFormula("alchemy")
		;else
		;	calc_AVGcalc = ProcessFormula("")
		;endif
		self.AddTextOptionST("pppsu_Current", "$pppsu_CurrentT", SkillUps.GetValue() as float, OPTION_FLAG_NONE)
		self.AddTextOptionST("pppsu_MSUM", "$pppsu_MSUMT", GetSchool("mage","sum") as int, OPTION_FLAG_NONE)
		self.AddEmptyOption()
		self.AddTextOptionST("pppsu_WSUM", "$pppsu_WSUMT", GetSchool("warrior","sum") as int, OPTION_FLAG_NONE)
		self.AddEmptyOption()
		self.AddTextOptionST("pppsu_TSUM", "$pppsu_TSUMT", GetSchool("thief","sum") as int, OPTION_FLAG_NONE)
		self.AddEmptyOption()
		self.AddTextOptionST("pppsu_SKILLESS", "$pppsu_SKILLESS", skillLess, OPTION_FLAG_NONE)
		self.AddEmptyOption()
		if skillLess == true
			self.AddTextOptionST("pppsu_AVGcalc", "$pppsu_AVGcalcT", calc_AVGcalc, OPTION_FLAG_NONE)
		else
			self.AddTextOptionST("pppsu_AVGcalcT", "$pppsu_AVGcalcThiefT", calc_AVGcalc, OPTION_FLAG_NONE)
			self.AddEmptyOption()
			self.AddTextOptionST("pppsu_AVGcalcW", "$pppsu_AVGcalcWarT", ProcessFormula("onehanded"), OPTION_FLAG_NONE)
			self.AddEmptyOption()
			self.AddTextOptionST("pppsu_AVGcalcM", "$pppsu_AVGcalcMageT", ProcessFormula("destruction"), OPTION_FLAG_NONE)			
		endif
		int xx = 0
		while FormulaTypes[xx]
			self.AddTextOptionST("pppsu_AVGcalcT"+xx, FormulaTypes[xx], FormulaVals[xx]*FormulaOpers[xx], OPTION_FLAG_NONE)
			self.AddEmptyOption()
			xx += 1
		endWhile
	endIf
endFunction


; Skipped compiler generated GotoState

;-- State -------------------------------------------
state pppsu_NumberOfPP

	event OnSliderOpenST() 
		SetSliderDialogStartValue(SkillUpsPerPerkPoint.GetValue())
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(1.0, 10)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float value)
		SetSliderOptionValueST(value, "{1}")
		SkillUpsPerPerkPoint.SetValue(value)
	endEvent
endState

state pppsu_PPperDep

	event OnSliderOpenST() 
		SetSliderDialogStartValue(PerkPointsPerDeposit.GetValue())
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 10)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float value)
		SetSliderOptionValueST(value, "{1} each time")
		PerkPointsPerDeposit.SetValue(value)
	endEvent
endState

state pppsu_Current
	event OnSelectST()
			Debug.MessageBox("Reloading data...")
			ForcePageReset()
	endEvent
endState

state pppsuFormulasMenu

	event OnMenuOpenST() 
		LoadJsonFormulas()
		SetMenuDialogStartIndex(selectedFileIndex)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(formulasLoaded)
	endEvent

	event OnMenuAcceptST(int value)
		selectedFileIndex = value
		selectedFileName = formulasLoaded[selectedFileIndex]
		SetMenuOptionValueST(selectedFileName)
		JsonUtil.Unload("../pppsu_presets/"+selectedFileName)
		if JsonUtil.JsonExists("../pppsu_presets/"+selectedFileName)
			testfrml = JsonUtil.GetStringValue("../pppsu_presets/"+selectedFileName,"formula")
			GetParsed(testfrml)
			GetParsed1(testfrml, false)
			GetParsed(testfrml, "mage", false)
			GetParsed(testfrml, "warrior", false)
			GetParsed(testfrml, "thief", false)
			
			ForcePageReset()
		else
			Debug.MessageBox("File does not exist!")
		endif
	endEvent
endState

;-- State -------------------------------------------

