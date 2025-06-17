/******************************************************************************/ 
/*                                                                            */
/*   Stata Do-File: Master Do-File                                            */
/*                                                                            */
/*   Author : Md. Zahirul Islam                                               */
/*   Email  : zahirul.islam.spa@gmail.com                                     */
/*   Phone  : +8801688831919                                                  */
/*   Date   : June 16, 2025                                                   */
/*                                                                            */
/*   Purpose:                                                                 */
/*   - Acts as the master script to control execution of all sub-do files     */
/*   - Modular execution using 0/1 switches                                   */
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
* C. Do-File Run Controls (0 = Skip, 1 = Run) *
*-------------------------------*
	local run_scto_data_down = 1
	local run_import         = 1
	local run_cleaning       = 1

*-------------------------------* 
* D. Run Do files Conditionally  * 
*-------------------------------*

	if `run_scto_data_down' == 1 {
		display as result "Running: 1_scto_data_down.do"
		do 1_scto_data_down
	}
	else {
		display as text "Skipped: 1_scto_data_down.do"
	}

	if `run_import' == 1 {
		display as result "Running: 2_import.do"
		do 2_import
	}
	else {
		display as text "Skipped: 2_import.do"
	}

	if `run_cleaning' == 1 {
		display as result "Running: 3_cleaning.do"
		do 3_cleaning
	}
	else {
		display as text "Skipped: 3_cleaning.do"
	}

*-------------------------------* 
* E. Completion Message         * 
*-------------------------------*
	display as result "✅ Master do-file execution complete."

/******************************************************************************/
