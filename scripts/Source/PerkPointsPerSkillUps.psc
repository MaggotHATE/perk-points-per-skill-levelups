scriptName PerkPointsPerSkillUps extends Quest

;-- Properties --------------------------------------

actor property PlayerRef auto
globalvariable property SkillUps auto
globalvariable property SkillUpsPerPerkPoint auto
globalvariable property PPPSU_reset auto
globalvariable property PerkPointsPerDeposit auto
sound property UISkillsBackward auto
objectReference playerOR
PerkPointsPerSkillUpsMCM PPPSU_1
;quest property PerkPointsPerSkillUpsMCM auto
;form PPPSUMCM


;-- Events ------------------------------------------

Event OnStoryIncreaseSkill(string asSkill)
	Debug.StartScriptProfiling("PerkPointsPerSkillUpsMCM")
	;PPPSUMCM = Game.GetFormFromFile(0x00000800, "PerkPointsPerSkillUps.esp")
	;PPPSU = PerkPointsPerSkillUpsMCM.getPPPSU()
	PPPSU_1 = Game.GetFormFromFile(0x00000C40, "PerkPointsPerSkillUps.esp") as PerkPointsPerSkillUpsMCM
	if PPPSU_reset.getvalue() == 1
		Debug.Notification("Reset!")
		PPPSU_1.ResetFormula()
		PPPSU_reset.setvalue(0)
	endif
	float PPPSUcalculated = 0
	int SkillLvlDiff = PlayerRef.getbaseactorvalue(asSkill) as int - StorageUtil.GetIntValue(SkillUps, "pppsu_"+asSkill)
	;Debug.Notification("SkillLvlDiff="+SkillLvlDiff)
	playerOR = PlayerRef as objectReference
	;Debug.Notification(PPPSU_1.GETtestfrml())
	if SkillLvlDiff > 1
		int x = SkillLvlDiff
		bool isGivenPerkPint = false
		while x > 0
			PPPSUcalculated = PPPSU_1.ProcessFormula2(asSkill)
			if PPPSUcalculated < 0.001
				PPPSUcalculated = 0.001
			endif
			if ResolvePerkPoints(PPPSUcalculated) == true
				playSFX(playerOR)
			endif
			;Debug.Notification("isGivenPerkPint="+isGivenPerkPint)
			x -= 1
		endwhile
		;playSFX(playerOR)
		;PlayerRef.placeAtMe(upgradeSND)	
		Debug.Notification(asSkill+ " skill increased, "+SkillLvlDiff+" levels total, last is "+PPPSUcalculated)
	else
		PPPSUcalculated = PPPSU_1.ProcessFormula2(asSkill)
		;StorageUtil.GetFloatValue(none, "PPPSUcalculated")
		if ResolvePerkPoints(PPPSUcalculated) == true
			playSFX(playerOR)
		endif
		
		;PlayerRef.placeAtMe(upgradeSND)
		Debug.Notification(asSkill+ " skill increased, "+SkillUps.getvalue() as float+" total, " + PPPSUcalculated + " now")
		
	endif
	;PPPSU_1.StoreSkills(SkillUps)
	PPPSU_1.StoreSkill(SkillUps, asSkill)
	
	self.stop()
endEvent

;-- Functions ---------------------------------------

bool function ResolvePerkPoints(float toPerkPointProgress)
	bool wasPerkGiven = false
	float PerXperks = SkillUpsPerPerkPoint.GetValue() as float
	SkillUps.setvalue(SkillUps.getvalue() + toPerkPointProgress)
	float depositPP = PerkPointsPerDeposit.GetValue() as float
	if SkillUps.getvalue() >= PerXperks
		float tempPP = PerXperks*depositPP + pppsu_1.realPerkPoints
		int perkPointsGivenActual = tempPP as int
		Debug.Notification(tempPP + " - "+perkPointsGivenActual)
		PPPSU_1.realPerkPoints = tempPP - perkPointsGivenActual
		Debug.Notification("Change: "+PPPSU_1.realPerkPoints)
		Game.AddPerkPoints(perkPointsGivenActual)
		
		SkillUps.setvalue(SkillUps.getvalue() - PerXperks)
		wasPerkGiven = true
		
		;upgradeSND.play(PlayerRef)
	endif
	return wasPerkGiven
endFunction

function playSFX(objectReference target)
		int instanceID = UISkillsBackward.play((PlayerRef as objectReference))
		;Debug.Notification("instanceID = "+instanceID)
		sound.SetInstanceVolume(instanceID, 40.9)
endFunction

