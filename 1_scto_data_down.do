/******************************************************************************/ 
/*                                                                            */
/*   Stata Do-File: Download and Import Data from SurveyCTO Server            */
/*                                                                            */
/*   Author : Md. Zahirul Islam                                               */
/*   Email  : zahirul.islam.spa@gmail.com                                     */
/*   Phone  : +8801688831919                                                  */
/*   Date   : June 16, 2025                                                   */
/*                                                                            */
/*   Purpose:                                                                 */
/*   - Download data from the SurveyCTO server using the `sctoapi` command    */
/*   - Store raw data in the designated folder                                */
/*   - Includes fix for r(102) and uses Unix timestamp for reliable download  */
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
* B. Define Global Paths       	* 
*-------------------------------*
	gl tool   "../2_Tools"
	gl raw   "../3_Raw"
	gl clean "../4_Clean"

*-------------------------------* 
* C. Install Required Package  	* 
*-------------------------------*
	cap ssc install scto

*-------------------------------* 
* D. Download Data             	* 
*-------------------------------*
	sctoapi Pratibandhi_Shahajjo_Seba_Kendro_SSK, ///
		server("https://redoan1234.surveycto.com") ///
		username("theranaredoan@gmail.com") ///
		password("Dhaka527746/?") ///
		date(1750032000) ///
		output("$raw") ///
		media(textaudit)

	display as result "✔️ Successfully, data has been downloaded and saved in $raw"	
/******************************************************************************/ 
/* End of File                                                                */
/******************************************************************************/
