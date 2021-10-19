scriptName PerkPointsPerSkillUpsMCM extends SKI_ConfigBase

;-- Properties --------------------------------------

actor property PlayerRef auto
globalvariable property SkillUps auto
globalvariable property SkillUpsPerPerkPoint auto
globalvariable property PerkPointsPerDeposit auto
quest property PerkPointsPerSkillUpsQ auto
string[] property FormulaTypes auto
string[] property FormulaMods auto
float[] property FormulaVals auto
int[] property FormulaOpers auto
int idx
String[] property tagList auto
form property PPPSUMCM auto
string property formulaPresetsPath = "../pppsu_formulas/" auto
string property rulePresetsPath = "../pppsu/" auto
float property realPerkPoints auto
;string CurrentSkill

;-- Variables ---------------------------------------
string testfrml = ""
float PPPSUcalculated
String[] formulasLoaded
String[] rulesLoaded
String[] tagsLoaded
int selectedFileIndex = 0
int selectedFileIndex1 = 0
string selectedFileName = "skill-based.json"
string selectedRuleName = "Vanilla.json"

bool skillLess = false

;"LEVEL_c0.3-SKILL_c0.1+MAGE_max0.1+SAME_max0.2"
;string[] pppsu/system = ["LEVEL","SKILL","MAGE_max","MAGE_min","MAGE_sum","MAGE_legend","WARRIOR_max","WARRIOR_min","WARRIOR_sum","WARRIOR_legend","THIEF_max","THIEF_min","THIEF_sum","THIEF_legend","SAME_max","SAME_min","SAME_sum","SAME_legend"]
; PLANS
; precalc for "flat number only" formulas
; add mult for PP per deposit
; 

;-- Events ------------------------------------------


Event OnGameReload()
	;Debug.MessageBox("OnGameReload1")
	;formulaPresetsPath = "../pppsu_formulas/"
	;rulePresetsPath = "../pppsu/"
	parent.OnGameReload() ;Important!
	
	;GetParsed(testfrml)
	;GetParsed(testfrml, "mage", false)
	;GetParsed(testfrml, "warrior", false)
	;GetParsed(testfrml, "thief", false)
	
	StoreSkills(SkillUps)
	;tagsLoaded = getTagLists(rulePresetsPath+systemPreset) 
	;Debug.Notification("Alchemy="+ProcessFormula2("Alchemy"))
	; PageInit()
	if tagList.Length == 0
		tagList = getTagLists(rulePresetsPath+selectedRuleName)
	endif
	
endEvent

;-- Functions ---------------------------------------

string function GETtestfrml()
	return testfrml
endFunction

function ResetFormula()
	Debug.Notification("Resetting formula...")
	selectedFileName = "default"
	testfrml = JsonUtil.GetStringValue(formulaPresetsPath+selectedFileName,"formula")
	GetParsed(testfrml)
	;GetParsed(testfrml, "mage", false)
	;GetParsed(testfrml, "warrior", false)
	;GetParsed(testfrml, "thief", false)
	;GetParsed1(testfrml, false)
endFunction

function resetArrays()
	FormulaTypes = new string[128]
	FormulaMods = new string[128]	
	FormulaOpers = new int[128]
	FormulaVals = new float[128]
endFunction

bool function HasMod(string cMod)
	return JsonUtil.StringListHas(rulePresetsPath+selectedRuleName, "mods", cMod)
endFunction

bool function HasTag(string cTag)
	if tagList.Find(cTag) > -1
		return true
	endif
	return false
endFunction

float function ProcessFormula2(string CurrentSkill)
	Debug.StartStackProfiling()
	int x = idx - 1
	;Debug.Notification("Starting from "+x)
	float tempPPoints = 0
	;Debug.Notification("CurrentSkill="+CurrentSkill)
	while x >= 0
		float xx = 0
		if FormulaTypes[x] == "X" ;the simplest
			xx += 1
		elseif FormulaTypes[x] == "LEVEL_c" ;second simplest
			xx += PlayerRef.getlevel()
		elseif FormulaTypes[x] == "SKILL_c" ;&& PlayerRef.getbaseactorvalue(CurrentSkill), probably not necessary, since it's called with skills only    
			xx += PlayerRef.getbaseactorvalue(CurrentSkill)
		elseif HasMod(FormulaMods[x]) && HasTag(FormulaTypes[x]) ;make sure we have both
			string skillSchool = FormulaTypes[x] ;unifying checks
			if skillSchool == "SAME"
				skillSchool = GetSchoolBySkill1(CurrentSkill)
			endif			
			xx += GetBySchool1(skillSchool,FormulaMods[x]) ;additional checks are not necessary if parsing works correctly (it does for now)
		elseif GetSchoolBySkill1(FormulaTypes[x]) != "EXCEPTION_SCHOOL_NULLPOINTER" ;now we need to check
			xx += PlayerRef.getbaseactorvalue(FormulaTypes[x])
		endif
		
		tempPPoints += xx*FormulaVals[x]*FormulaOpers[x]
		;Debug.Notification("#"+x+" "+FormulaTypes[x]+" ="+tempPPoints)
		x -= 1
	endwhile
	if tempPPoints < 0.001
		tempPPoints = 0.001 ;prevents negative values 
	endif
	Debug.StopStackProfiling()
	return tempPPoints
endFunction

int function getBySchoolMax1(string[] schoolElems)
	int result = 0
	int x = 0
	while x < schoolElems.length
		int tmpAV = PlayerRef.getbaseactorvalue(schoolElems[x]) as int
		if result < tmpAV
			result = tmpAV
		endif
		x += 1 
	endWhile
	return result
endFunction

int function getBySchoolMin1(string[] schoolElems)
	int x = 0
	int result = 300 ;since it's the largest value according to the Uncapper
	while x < schoolElems.length
		int tmpAV = PlayerRef.getbaseactorvalue(schoolElems[x]) as int
		if result > tmpAV
			result = tmpAV
		endif
		x += 1
	endWhile
	return result
endFunction

int function getBySchoolLeg1(string[] schoolElems)
	int result = 0
	int x = 0
	while x < schoolElems.length
		result += ActorValueInfo.GetActorValueInfoByName(schoolElems[x]).GetSkillLegendaryLevel()
		x += 1
	endWhile
	return result
endFunction

int function getBySchoolSum1(string[] schoolElems)
	int result = 0
	int x = 0
	while x < schoolElems.length
		result += PlayerRef.getbaseactorvalue(schoolElems[x]) as int
		x += 1 
	endWhile
	return result
endFunction

int function GetBySchool1(string school, string method)
	;int result = 0
	string[] schoolElems = JsonUtil.StringListToArray(rulePresetsPath+selectedRuleName, school)
	if method == "_max"
		return GetBySchoolMax1(schoolElems)
		;Debug.Notification("max "+school+" "+result)
	elseif method == "_min"
		return GetBySchoolMin1(schoolElems)
		;Debug.Notification("min "+school+" "+result)
	elseif method == "_sum"
		return GetBySchoolSum1(schoolElems)
		;Debug.Notification("sum "+school+" "+result)
	elseif method == "_legend"
		return GetBySchoolLeg1(schoolElems)
		;Debug.Notification("legend "+school+" "+result)
	endif
	;Debug.Notification("#"+idx + " " + school+" "+method+" "+result)
	return 0
endFunction

string function GetSchoolBySkill(string theSkill)
	if JsonUtil.StringListHas(rulePresetsPath+selectedRuleName, "mage",theSkill)
		return "mage"
	elseif JsonUtil.StringListHas(rulePresetsPath+selectedRuleName, "warrior",theSkill)
		return "warrior"
	elseif JsonUtil.StringListHas(rulePresetsPath+selectedRuleName, "thief",theSkill)
		return "thief"
	else
		;Debug.MessageBox("Wrong school setup or skill!")
		return "EXCEPTION_SCHOOL_NULLPOINTER"
	endif
endFunction

string function GetSchoolBySkill1(string theSkill)
	int y = 0
	while y < tagList.Length
		if  tagList[y] != "mods" && tagList[y] != "tags" && tagList[y] != "SAME" && JsonUtil.StringListHas(rulePresetsPath+selectedRuleName, tagList[y],theSkill)
				;Debug.MessageBox(theSkill+" in " + tagList[y])
				return tagList[y]
		endif
		y += 1
	endwhile
	return "EXCEPTION_SCHOOL_NULLPOINTER"
endFunction

function GetParsed(string formula, string tags = "TAGS", bool resetIDX = true)
	tagList = getTagLists(rulePresetsPath+selectedRuleName)
	;Debug.StartStackProfiling()
	if resetIDX == true
		resetArrays()
		idx = 0
		skillLess = true
	endif

	int x = 0
	
	string xx = JsonUtil.StringListGet(rulePresetsPath+selectedRuleName, tags,x)
	while xx
		int xxx = StringUtil.Find(formula, xx)
		if xxx != -1
			;Debug.Notification("Found " + xx+ " tag #"+x+" at "+xxx)
			int y = xxx + StringUtil.GetLength(xx) 
			string yy = StringUtil.getNthChar(formula,y)
			float digit = getDigit(formula, y)
			FormulaTypes[idx] = xx
			FormulaMods[idx] = "_"
			FormulaVals[idx] = digit
			FormulaOpers[idx] = getSign(formula, xxx)
			idx += 1
			
			if xx == "SKILL_c"
				skillLess = false
			endif			
			;Debug.Notification(idx+": " + FormulaOpers[idx] + " " + FormulaTypes[idx] + " * " + FormulaVals[idx])
			
		endif
		x += 1
		xx = JsonUtil.StringListGet(rulePresetsPath+selectedRuleName, tags,x)
	endWhile
	if tags == "TAGS"
		GetParsed3(testfrml)
		int y = 0
		while y < tagList.Length
			if tagList[y] != "mods" && tagList[y] != "tags" && tagList[y] != "same"
				;Debug.Notification("Parsing "+tagList[y])
				GetParsed(testfrml, tagList[y], false)
			endif
			y += 1
		endwhile
	Debug.MessageBox("Finished loading "+selectedFileName)
	endif
	;Debug.StopStackProfiling()
endFunction

string[] function getTagLists(string path)
	string[] tList = JsonUtil.PathMembers(path, ".stringList")
	
	;Debug.Notification("tempTagList 0 = "+tagList[0])
	return tList
endFunction

float function getDigit(string formula, int digPos)
	string digSym = StringUtil.getNthChar(formula,digPos)
	string digit = ""
	
	while StringUtil.IsDigit(digSym) || (digSym == ".")
		digit += digSym
		digPos += 1
		digSym = StringUtil.getNthChar(formula,digPos)
	endwhile
	;Debug.MessageBox("digit " + digit)
	if digit == ""
		return -1
	else
		return digit as float
	endif
endFunction

int function getSign(string formula, int tagPos)
	if tagPos > 0
		;Debug.Notification("SIGN "+ tagPos + StringUtil.getNthChar(formula,tagPos - 1))
		if StringUtil.getNthChar(formula,tagPos - 1) == "-"
			return -1
		else 
			return 1
		endif
	else 
		return 1
	endif
endFunction

int function getSignByStr(string symbol)
	if symbol == "-"
		return -1
	else
		return 1
	endif
endFunction

int function closestSign(string formula, int i = 0)
	int plus = StringUtil.Find(formula, "+",i)
	int minus = StringUtil.Find(formula, "-",i)
	if plus == -1
		return minus
	elseif minus == -1
		return plus
	elseif plus > minus 
		return minus
	else
		return plus
	endif
endFunction

function GetParsed3(string formula)
	string formulaTemp = formula
	string tempTagDig = ""
	int sign = closestSign(formulaTemp,1)
	while sign > -1 || closestSign(formulaTemp) > -1
		tempTagDig = StringUtil.Substring(formulaTemp,0,sign)
		formulaTemp = StringUtil.Substring(formulaTemp,StringUtil.getLength(tempTagDig))
		sign = closestSign(formulaTemp,1)
		;Debug.MessageBox("sign1 = "+sign+": "+tempTagDig)
		GetParsed2(tempTagDig)		
	endWhile
endFunction

function GetParsed2(string formula)
	; if resetIDX == true
		; idx = 0
		; skillLess = true
	; endif

	int x = 0
	int y = 0
	
	;Debug.MessageBox("tagList loaded")
	;int numTags = tagList.Length
	;tagList[numTags] = "SAME"
		while y < tagList.Length
			if  tagList[y] != "mods" && tagList[y] != "tags"
				int xxxx = StringUtil.Find(formula, tagList[y])
				;Debug.MessageBox("Finding "+tagList[y]+" at "+xxxx)
				if xxxx != -1
					int undscrPos = xxxx+StringUtil.getLength(tagList[y])
					string undscr = StringUtil.getNthChar(formula, undscrPos)
					if undscr == "_"
						int yy = 0
						string getMod = JsonUtil.StringListGet(rulePresetsPath+selectedRuleName, "mods",yy)
						while getMod
							if getMod == StringUtil.Substring(formula, undscrPos, StringUtil.getLength(getMod))
								int digPos = undscrPos+StringUtil.getLength(getMod)
								;Debug.MessageBox("mod? "+getMod+" at "+digPos)
								float digit = getDigit(formula, digPos)
								if digit != -1
									FormulaOpers[idx] = getSign(formula, xxxx)
									FormulaTypes[idx] = tagList[y]
									FormulaMods[idx] = getMod
									FormulaVals[idx] = digit
									
									;Debug.MessageBox("GP2 "+FormulaTypes[idx]+FormulaMods[idx]+" * "+FormulaVals[idx]+"*"+FormulaOpers[idx])
									
									idx += 1
									if tagList[y] == "SAME"
										skillLess = false
									endif
									
								endif
							endif
							
							yy += 1
							getMod = JsonUtil.StringListGet(rulePresetsPath+selectedRuleName, "mods",yy)
						endWhile
					endif
				endif
			endif
			y += 1
		endWhile
	
endFunction

function StoreSkills(form storeForm)
	StorageUtil.SetIntValue(storeForm, "pppsu_Alteration",PlayerRef.getbaseactorvalue("Alteration") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Conjuration",PlayerRef.getbaseactorvalue("Conjuration") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Destruction",PlayerRef.getbaseactorvalue("Destruction") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Enchanting",PlayerRef.getbaseactorvalue("Enchanting") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Restoration",PlayerRef.getbaseactorvalue("Restoration") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Illusion",PlayerRef.getbaseactorvalue("Illusion") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Marksman",PlayerRef.getbaseactorvalue("Marksman") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Block",PlayerRef.getbaseactorvalue("Block") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_HeavyArmor",PlayerRef.getbaseactorvalue("HeavyArmor") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Onehanded",PlayerRef.getbaseactorvalue("Onehanded") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Smithing",PlayerRef.getbaseactorvalue("Smithing") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Twohanded",PlayerRef.getbaseactorvalue("Twohanded") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Alchemy",PlayerRef.getbaseactorvalue("Alchemy") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_LightArmor",PlayerRef.getbaseactorvalue("LightArmor") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Lockpicking",PlayerRef.getbaseactorvalue("Lockpicking") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Pickpocket",PlayerRef.getbaseactorvalue("Pickpocket") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Sneak",PlayerRef.getbaseactorvalue("Sneak") as int)
	StorageUtil.SetIntValue(storeForm, "pppsu_Speechcraft",PlayerRef.getbaseactorvalue("Speechcraft") as int)
	;Debug.Notification("Finished StoreSkills. Smithing: "+StorageUtil.GetIntValue(storeForm, "pppsu_"+"Smithing"))
endFunction

function StoreSkill(form storeForm, string asSkill)
	StorageUtil.SetIntValue(storeForm, "pppsu_"+asSkill,PlayerRef.getbaseactorvalue(asSkill) as int)
	;Debug.Notification("Finished StoreSkill "+asSkill+": "+StorageUtil.GetIntValue(storeForm, "pppsu_"+asSkill))
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
	
	if tagList.Length == 0
		tagList = getTagLists(rulePresetsPath+selectedRuleName)
	endif
	
	;PPPSUMCM = Game.GetFormFromFile(0x00000800, "PerkPointsPerSkillUps.esp") as PerkPointsPerSkillUpsMCM
	testfrml = JsonUtil.GetStringValue(formulaPresetsPath+selectedFileName,"formula")
	GetParsed(testfrml)
	StoreSkills(SkillUps)

	; testfrml = JsonUtil.GetStringValue(formulaPresetsPath+selectedFileName,"formula")
	; GetParsed(testfrml)
	; GetParsed(testfrml, "mage")
	; GetParsed(testfrml, "warrior")
	; GetParsed(testfrml, "thief")
	;PPPSUcalculated = ProcessFormula("TwoHanded")
	;Debug.Messagebox("Formula result: "+PPPSUcalculated+" skill points per skill upgrade!")
	;StorageUtil.SetFloatValue(none, "PPPSUcalculated", PPPSUcalculated)
	
	Debug.Notification("Perk Points Per Skill Levelups initialized")	
endFunction

event OnConfigClose()

endEvent

function PageInit()
	ModName = "$PerkPointsPerSkillUpsMCM_Name"
	Pages = new String[2]
	Pages[0] = "$PerkPointsPerSkillUpsMCM_p0"
	Pages[1] = "$PerkPointsPerSkillUpsMCM_p1"
	;Debug.MessageBox("PageInit")
endFunction




Int function GetVersion()

	return 1
endFunction

function LoadJsonFormulas()
	formulasLoaded = JsonUtil.JsonInFolder(formulaPresetsPath)
endFunction

String[] function LoadJsons(string path)
	return JsonUtil.JsonInFolder(path)
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
		self.AddMenuOptionST("pppsuRulesMenu", "$pppsu_RM", selectedRuleName)
		self.AddSliderOptionST("pppsu_PPperDep", "$pppsu_PPperDepT", PerkPointsPerDeposit.GetValue() as float, "{1} each time")
		
		self.AddMenuOptionST("pppsuFormulasMenu", "$pppsu_FM", selectedFileName)
		self.AddEmptyOption()
		
		
		
	elseif a_page == "$PerkPointsPerSkillUpsMCM_p1"
		self.SetCursorFillMode(self.LEFT_TO_RIGHT)
		;if skillLess == false
		string tSkill = "sneak"
		string wSkill = "onehanded"
		string mSkill = "destruction"
		string testSkill = "Marksman"
		;else
		;	calc_AVGcalc = ProcessFormula("")
		;endif
		self.AddHeaderOption("$pppsu_HEADER1")
		self.AddHeaderOption(" ")
		self.AddTextOptionST("pppsu_Current", "$pppsu_CurrentT", SkillUps.GetValue() as float, OPTION_FLAG_NONE)
		if skillLess == true
			self.AddEmptyOption()
			self.AddTextOptionST("pppsu_AVGcalc", "$pppsu_AVGcalcT", ": " +ProcessFormula2(tSkill), OPTION_FLAG_NONE)
			self.AddTextOptionST("pppsu_TSUM", "$pppsu_TSUMT", GetBySchool1("thief","_sum") as int, OPTION_FLAG_NONE)
			self.AddEmptyOption()
			self.AddTextOptionST("pppsu_MSUM", "$pppsu_MSUMT", GetBySchool1("mage","_sum") as int, OPTION_FLAG_NONE)
			self.AddTextOptionST("pppsu_WSUM", "$pppsu_WSUMT", GetBySchool1("warrior","_sum") as int, OPTION_FLAG_NONE)
			self.AddTextOptionST("pppsu_SKILLESS", "$pppsu_SKILLESS", skillLess, OPTION_FLAG_NONE)	
			self.AddEmptyOption()
		else
			self.AddEmptyOption()
			self.AddTextOptionST("pppsu_AVGcalcT", "$pppsu_AVGcalcT", tSkill + ":    " + ProcessFormula2(tSkill), OPTION_FLAG_NONE)
			self.AddTextOptionST("pppsu_TSUM", "$pppsu_TSUMT", GetBySchool1("thief","_sum") as int, OPTION_FLAG_NONE)
			self.AddTextOptionST("pppsu_AVGcalcW", "$pppsu_AVGcalcT", wSkill + ":    " +ProcessFormula2(wSkill), OPTION_FLAG_NONE)
			self.AddTextOptionST("pppsu_WSUM", "$pppsu_WSUMT", GetBySchool1("warrior","_sum") as int, OPTION_FLAG_NONE)
			self.AddTextOptionST("pppsu_AVGcalcM", "$pppsu_AVGcalcT", mSkill + ":    " +ProcessFormula2(mSkill), OPTION_FLAG_NONE)
			self.AddTextOptionST("pppsu_MSUM", "$pppsu_MSUMT", GetBySchool1("mage","_sum") as int, OPTION_FLAG_NONE)
			;self.AddTextOptionST("pppsu_SKILLESS", "$pppsu_SKILLESS", skillLess, OPTION_FLAG_NONE)	
		endif
		self.AddHeaderOption(" ")
		self.AddHeaderOption("$pppsu_HEADER2")
		self.AddTextOptionST("pppsu_AVGcalcTest", "$pppsu_AVGcalcTestT", testSkill + " in " + GetSchoolBySkill1(testSkill) + ":  " + ProcessFormula2(testSkill), OPTION_FLAG_NONE)
		int xx = 0
		while FormulaTypes[xx]
			self.AddTextOptionST("pppsu_AVGcalcT"+xx, FormulaTypes[xx]+FormulaMods[xx], FormulaVals[xx]*FormulaOpers[xx], OPTION_FLAG_NONE)
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

; state pppsu_Current
	; event OnSelectST()
			; Debug.MessageBox("Reloading data...")
			; ForcePageReset()
	; endEvent
; endState

state pppsuFormulasMenu

	event OnMenuOpenST() 
		;LoadJsonFormulas()
		formulasLoaded = JsonUtil.JsonInFolder(formulaPresetsPath)
		SetMenuDialogStartIndex(selectedFileIndex)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(formulasLoaded)
	endEvent

	event OnMenuAcceptST(int value)
		selectedFileIndex = value
		selectedFileName = formulasLoaded[selectedFileIndex]
		SetMenuOptionValueST(selectedFileName)
		JsonUtil.Unload(formulaPresetsPath+selectedFileName)
		if JsonUtil.JsonExists(formulaPresetsPath+selectedFileName)
			testfrml = JsonUtil.GetStringValue(formulaPresetsPath+selectedFileName,"formula")
			GetParsed(testfrml)
			;GetParsed(testfrml, "mage", false)
			;GetParsed(testfrml, "warrior", false)
			;GetParsed(testfrml, "thief", false)
			;GetParsed1(testfrml, false)
			
			ForcePageReset()
		else
			Debug.MessageBox("File does not exist!")
		endif
	endEvent
endState

state pppsuRulesMenu

	event OnMenuOpenST() 
		;LoadJsonFormulas()
		rulesLoaded = JsonUtil.JsonInFolder(rulePresetsPath)
		SetMenuDialogStartIndex(selectedFileIndex1)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(rulesLoaded)
	endEvent

	event OnMenuAcceptST(int value)
		selectedFileIndex1 = value
		JsonUtil.Unload(rulePresetsPath+selectedRuleName)
		if JsonUtil.JsonExists(rulePresetsPath+selectedRuleName)
			selectedRuleName = rulesLoaded[selectedFileIndex1]
			SetMenuOptionValueST(selectedRuleName)
			GetParsed(testfrml)
			ForcePageReset()
		else
			Debug.MessageBox("File does not exist!")
		endif
	endEvent
endState
;-- State -------------------------------------------

