/******************************************************************************/ 
/*                                                                            */
/*   Stata Do-File: Cleaning Do-File                                          */
/*                                                                            */
/*   Author : Md. Zahirul Islam                                               */
/*   Email  : zahirul.islam.spa@gmail.com                                     */
/*   Phone  : +8801688831919                                                  */
/*   Date   : June 16, 2025                                                   */
/*                                                                            */
/*   Purpose:                                                                 */
/*   - Open the cleaned dataset                                               */
/*   - Drop unnecessary variables                                             */
/*   - Reorder variables and relabel                                          */
/*   - Generate a codebook summary                                            */
/*   - Save cleaned dataset in multiple formats                               */
/*                                                                            */
/******************************************************************************/ 

*-------------------------------* 
* A. Initial Setup              * 
*-------------------------------*
	clear all
	cap log close
	version 15
	set more off
	pause on
	set niceness 1
	set sortseed 8341
	set maxvar 32000

*-------------------------------* 
* B. Define Global Paths        * 
*-------------------------------*
	global tool   "../2_Tools"
	global raw    "../3_Raw"
	global clean  "../4_Clean"

*-------------------------------* 
* C. Open Cleaned Dataset       * 
*-------------------------------*
	use "${clean}/SSK_clean.dta", clear

*-------------------------------* 
* D. Drop Unnecessary Variables * 
*-------------------------------*
	drop note_title note_org note_intro note_1 note_2 note_3 note_4 ///
		 formdef_version review_quality review_status

*-------------------------------* 
* E. Variable Reorder & Labels  * 
*-------------------------------*
	label variable comment "Additional comments"
	order q6_other, after(q6_staff_capacity)

*-------------------------------* 
* F. Generate Codebook Summary  * 
*-------------------------------*
	putexcel set "${clean}/SSK_Survey_codebook.xlsx", replace

		putexcel A1 = "Variable"
		putexcel B1 = "Obs"
		putexcel C1 = "Miss obs"
		putexcel D1 = "Ques."
		putexcel E1 = "Label"

		loc i = 2

		foreach var of varlist _all {
			qui count if  !mi(`var')
			qui putexcel A`i' = "`var'"
			qui putexcel B`i' = `r(N)'
			qui putexcel C`i' = `=_N - `r(N)''
			qui putexcel D`i' = `"``var'[note1]'"'
			qui putexcel E`i' = `"`: var lab `var''"'
				loc ++i
			}   

*-------------------------------* 
* G. Save Cleaned Dataset       * 
*-------------------------------*
	save "${clean}/SSK_clean_final.dta", replace
	savespss "${clean}/SSK_clean_final.sav", replace
	export delimited "${clean}/SSK_clean_final.csv", replace
	export excel "${clean}/SSK_clean_final.xlsx", replace nolabel firstrow(var)

*-------------------------------* 
* H. Completion Message         * 
*-------------------------------*
	display as result "✅ Data cleaning and export completed successfully."

/******************************************************************************/
