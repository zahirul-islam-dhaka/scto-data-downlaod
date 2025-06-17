/******************************************************************************/ 
/*                                                                            */
/*   Stata Do-File: import_Pratibandhi_Shahajjo_Seba_Kendro_SSK.do            */
/*                                                                            */
/*   Author  : Md. Zahirul Islam                                              */
/*   Email   : zahirul.islam.spa@gmail.com                                    */
/*   Date    : June 17, 2025                                                  */
/*                                                                            */
/*   Purpose:                                                                 */
/*   - Import and prepare data from SurveyCTO CSV export                      */
/*   - Based on form: "Questionnaire For Collecting Information on Services   */
/*     and Human Resources of Pratibandhi Shahajjo & Seba Kendro (SSK)"      */
/*                                                                            */
/*   Input :                                                                  */
/*     - Pratibandhi_Shahajjo_Seba_Kendro_SSK_WIDE.csv                        */
/*   Output:                                                                  */
/*     - SSK_clean.dta                                                        */
/*                                                                            */
/******************************************************************************/

* initialize Stata
	clear all
	set more off
	set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
	local overwrite_old_data 0

* initialize form-specific parameters
	local csvfile "$raw/Pratibandhi_Shahajjo_Seba_Kendro_SSK_WIDE.csv"
	local dtafile "$clean/SSK_clean.dta"
	local corrfile "$raw/Pratibandhi_Shahajjo_Seba_Kendro_SSK_WIDE_corrections.csv"
	local note_fields1 ""
	local text_fields1 "respondent_name collection_location respondent_designation collector_name collector_designation q3_option_a q3_option_b q3_option_c q3_option_d q3_option_e q5_other q6_other q7_other q8_other q9_other"
	local text_fields2 "q10_other q11_other q12_other q15_other q16_other q17_other q19_other q21_other q22_other q23_other q24_other q25_other q26_other q29_other q30_other q31_other q32_other q33_additional_services"
	local text_fields3 "comment instanceid"
	local date_fields1 "collection_date"
	local datetime_fields1 "submissiondate"

	disp
	disp "Starting import of: `csvfile'"
	disp

* import data from primary .csv file
	insheet using "`csvfile'", names clear

* drop extra table-list columns
	cap drop reserved_name_for_field_*
	cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable uid "Survey ID"
	note uid: "Survey ID"

	label variable respondent_name "Respondent Name"
	note respondent_name: "Respondent Name"

	label variable collection_location "Place of Data Collection"
	note collection_location: "Place of Data Collection"

	label variable respondent_designation "Respondent Designation"
	note respondent_designation: "Respondent Designation"

	label variable collection_date "Interview Data"
	note collection_date: "Interview Data"

	label variable collector_name "Interviewer Name"
	note collector_name: "Interviewer Name"

	label variable collector_designation "Interviewer Designation"
	note collector_designation: "Interviewer Designation"

	label variable q1_daily_beneficiaries "On average, how many service recipients visit your center daily?"
	note q1_daily_beneficiaries: "On average, how many service recipients visit your center daily?"
	label define q1_daily_beneficiaries 1 "1–5 persons" 2 "6–10 persons" 3 "More than 10 persons" 4 "None"
	label values q1_daily_beneficiaries q1_daily_beneficiaries

	label variable q2_reason_low_attendance "If the number of service recipients is very low, what do you think is the main r"
	note q2_reason_low_attendance: "If the number of service recipients is very low, what do you think is the main reason for this?"
	label define q2_reason_low_attendance 1 "There are some limitations in service delivery" 2 "There may be fewer persons with disabilities in the area" 3 "People in the area are not well informed about the center" 4 "General public awareness about these services is low"
	label values q2_reason_low_attendance q2_reason_low_attendance

	label variable q3_option_a "A."
	note q3_option_a: "A."

	label variable q3_option_b "B."
	note q3_option_b: "B."

	label variable q3_option_c "C."
	note q3_option_c: "C."

	label variable q3_option_d "D."
	note q3_option_d: "D."

	label variable q3_option_e "E."
	note q3_option_e: "E."

	label variable q4_payment_for_services "Do recipients pay for the services?"
	note q4_payment_for_services: "Do recipients pay for the services?"
	label define q4_payment_for_services 1 "Yes" 2 "No" 3 "Some do"
	label values q4_payment_for_services q4_payment_for_services

	label variable q5_limitation_reason "What do you think is the main limitation in providing services at your center cu"
	note q5_limitation_reason: "What do you think is the main limitation in providing services at your center currently?"
	label define q5_limitation_reason 1 "Lack of sufficient therapists" 2 "Lack of necessary therapy equipment" 3 "Infrastructure limitations" 4 "Weakness in providing necessary information/referral services" 5 "(Any other, please specify)"
	label values q5_limitation_reason q5_limitation_reason

	//label variable q5_other "Others Specify here"
	//note q5_other: "Others Specify here"

	label variable q6_staff_capacity "How capable is your center’s current staffing structure in meeting the service d"
	note q6_staff_capacity: "How capable is your center’s current staffing structure in meeting the service demands?"
	label define q6_staff_capacity 1 "Fully capable" 2 "Partially capable" 3 "Limited capability" 4 "Not capable" 5 "(Any other, please specify)"
	label values q6_staff_capacity q6_staff_capacity

	label variable q6_other "Others Specify here"
	note q6_other: "Others Specify here"

	label variable q7_staff_shortage_reason "What do you think is the most important reason for the staffing shortage?"
	note q7_staff_shortage_reason: "What do you think is the most important reason for the staffing shortage?"
	label define q7_staff_shortage_reason 1 "Delay in recruitment" 2 "Lack of trained personnel" 3 "Budget constraints" 4 "Lack of adequate monitoring from central level" 5 "(Any other, please specify)"
	label values q7_staff_shortage_reason q7_staff_shortage_reason

	//label variable q7_other "Others Specify here"
	//note q7_other: "Others Specify here"

	label variable q8_most_demanded_service "Among the currently provided services, which one is most in demand?"
	note q8_most_demanded_service: "Among the currently provided services, which one is most in demand?"
	label define q8_most_demanded_service 1 "Physiotherapy" 2 "Speech and language therapy" 3 "Occupational therapy" 4 "Counseling and advisory services" 5 "(Any other, please specify)"
	label values q8_most_demanded_service q8_most_demanded_service

	//label variable q8_other "Others Specify here"
	//note q8_other: "Others Specify here"

	label variable q9_challenges "What challenge do you most frequently face in delivering services?"
	note q9_challenges: "What challenge do you most frequently face in delivering services?"
	label define q9_challenges 1 "Ensuring regular attendance of recipients" 2 "Timely availability of materials" 3 "Overburdened staff" 4 "Lack of supervision to ensure quality" 5 "(Any other, please specify)"
	label values q9_challenges q9_challenges

	label variable q9_other "Others Specify here"
	note q9_other: "Others Specify here"

	label variable q10_intervention_needed "At which level is urgent intervention needed to improve service quality?"
	note q10_intervention_needed: "At which level is urgent intervention needed to improve service quality?"
	label define q10_intervention_needed 1 "Training and skill development" 2 "Supply of technical and medical equipment" 3 "Management and monitoring system" 4 "Budget allocation and timely expenditure" 5 "(Any other, please specify)"
	label values q10_intervention_needed q10_intervention_needed

	//label variable q10_other "Others Specify here"
	//note q10_other: "Others Specify here"

	label variable q11_feedback "What is the general reaction of service recipients regarding the services?"
	note q11_feedback: "What is the general reaction of service recipients regarding the services?"
	label define q11_feedback 1 "Very satisfied" 2 "Satisfied" 3 "Moderately satisfied" 4 "Dissatisfied" 5 "(Any other, please specify)"
	label values q11_feedback q11_feedback

	//label variable q11_other "Others Specify here"
	//note q11_other: "Others Specify here"

	label variable q12_expected_support "What types of additional support do service recipients generally expect?"
	note q12_expected_support: "What types of additional support do service recipients generally expect?"
	label define q12_expected_support 1 "Regular therapy services" 2 "Free assistive devices" 3 "Professional/vocational training" 4 "Participation in inclusive community activities" 5 "(Any other, please specify)"
	label values q12_expected_support q12_expected_support

	//label variable q12_other "Others Specify here"
	//note q12_other: "Others Specify here"

	label variable q13_skill_barrier "What are the barriers to enhancing staff skills?"
	note q13_skill_barrier: "What are the barriers to enhancing staff skills?"
	label define q13_skill_barrier 1 "Lack of training" 2 "Lack of supervision" 3 "Lack of professional motivation" 4 "Unfavorable work environment" 5 "Lack of positive attitude"
	label values q13_skill_barrier q13_skill_barrier

	label variable q14_improvement_suggestion "What is the most essential proposal to improve service quality?"
	note q14_improvement_suggestion: "What is the most essential proposal to improve service quality?"
	label define q14_improvement_suggestion 1 "Increasing service provider capacity" 2 "Increasing staff numbers" 3 "Expanding scope and frequency of services" 4 "Regular service evaluation" 5 "Extensive local promotion of service activities"
	label values q14_improvement_suggestion q14_improvement_suggestion

	label variable q15_referral_issues "What problems do you face regarding referral services?"
	note q15_referral_issues: "What problems do you face regarding referral services?"
	label define q15_referral_issues 1 "Lack of connections with institutions" 2 "Delay in referrals" 3 "Lack of necessary information" 4 "Unavailability of suitable services" 5 "(Any other, please specify)"
	label values q15_referral_issues q15_referral_issues

	//label variable q15_other "Others Specify here"
	//note q15_other: "Others Specify here"

	label variable q16_local_admin_involvement "How do local administration or representatives intervene or recommend in service"
	note q16_local_admin_involvement: "How do local administration or representatives intervene or recommend in service delivery?"
	label define q16_local_admin_involvement 1 "Very often" 2 "Moderately" 3 "Not at all" 4 "(Any other, please specify)"
	label values q16_local_admin_involvement q16_local_admin_involvement

	//label variable q16_other "Others Specify here"
	//note q16_other: "Others Specify here"

	label variable q17_awareness_law "How well are you informed about the Rights and Protection of Persons with Disabi"
	note q17_awareness_law: "How well are you informed about the Rights and Protection of Persons with Disabilities Act, 2013?"
	label define q17_awareness_law 1 "Fully informed" 2 "Partially informed" 3 "Know a little" 4 "Not aware" 5 "(Any other, please specify)"
	label values q17_awareness_law q17_awareness_law

	//label variable q17_other "Others Specify here"
	//note q17_other: "Others Specify here"

	label variable q18_parent_communication "How is communication with parents/guardians of persons with disabilities?"
	note q18_parent_communication: "How is communication with parents/guardians of persons with disabilities?"
	label define q18_parent_communication 1 "Regular and effective" 2 "As needed" 3 "Irregular" 4 "Very minimal"
	label values q18_parent_communication q18_parent_communication

	label variable q19_training_status "What is the training level of the officials/employees in your center?"
	note q19_training_status: "What is the training level of the officials/employees in your center?"
	label define q19_training_status 1 "Mostly trained" 2 "Some trained" 3 "Very few trained" 4 "Not trained" 5 "(Any other, please specify)"
	label values q19_training_status q19_training_status

	//label variable q19_other "Others Specify here"
	//note q19_other: "Others Specify here"

	label variable q20_training_relevance "How relevant is the training to the services?"
	note q20_training_relevance: "How relevant is the training to the services?"
	label define q20_training_relevance 1 "Necessary and modern" 2 "Somewhat timely" 3 "Outdated and less relevant" 4 "Irrelevant"
	label values q20_training_relevance q20_training_relevance

	label variable q21_workload "How do you perceive the workload?"
	note q21_workload: "How do you perceive the workload?"
	label define q21_workload 1 "Manageable" 2 "Moderate" 3 "Excessive and harmful" 4 "(Any other, please specify)"
	label values q21_workload q21_workload

	//label variable q21_other "Others Specify here"
	//note q21_other: "Others Specify here"

	label variable q22_staff_motivation "How would you describe employee motivation in service delivery?"
	note q22_staff_motivation: "How would you describe employee motivation in service delivery?"
	label define q22_staff_motivation 1 "High" 2 "Moderate" 3 "Low" 4 "Unmotivated" 5 "(Any other, please specify)"
	label values q22_staff_motivation q22_staff_motivation

	//label variable q22_other "Others Specify here"
	//note q22_other: "Others Specify here"

	label variable q23_support_needed "What type of support would make your work more productive as an officer?"
	note q23_support_needed: "What type of support would make your work more productive as an officer?"
	label define q23_support_needed 1 "Regular training" 2 "Financial incentives" 3 "Supportive technical team" 4 "Leadership and policy support" 5 "Information exchange using ICT (WhatsApp, email, etc.)"
	label values q23_support_needed q23_support_needed

	//label variable q23_other "Others Specify here"
	//note q23_other: "Others Specify here"

	label variable q24_infrastructure "How suitable is the current infrastructure for providing services?"
	note q24_infrastructure: "How suitable is the current infrastructure for providing services?"
	label define q24_infrastructure 1 "Fully suitable" 2 "Somewhat suitable" 3 "Limited suitability" 4 "Unsuitable" 5 "(Any other, please specify)"
	label values q24_infrastructure q24_infrastructure

	//label variable q24_other "Others Specify here"
	//note q24_other: "Others Specify here"

	label variable q25_technology_use "How is technology contributing to improving service quality?"
	note q25_technology_use: "How is technology contributing to improving service quality?"
	label define q25_technology_use 1 "Used effectively" 2 "Used to a limited extent" 3 "Not used" 4 "Don’t know" 5 "(Any other, please specify)"
	label values q25_technology_use q25_technology_use

	//label variable q25_other "Others Specify here"
	//note q25_other: "Others Specify here"

	label variable q26_supply_issues "What problems do you see in supplying assistive materials?"
	note q26_supply_issues: "What problems do you see in supplying assistive materials?"
	label define q26_supply_issues 1 "Insufficient stock" 2 "Delayed supply" 3 "Poor quality" 4 "Mismatch with demand" 5 "(Any other, please specify)"
	label values q26_supply_issues q26_supply_issues

	//label variable q26_other "Others Specify here"
	//note q26_other: "Others Specify here"

	label variable q27_autism_corner "How effective is the Autism Corner/Toy Library?"
	note q27_autism_corner: "How effective is the Autism Corner/Toy Library?"
	label define q27_autism_corner 1 "Very effective" 2 "Somewhat effective" 3 "Not very effective" 4 "Not yet operational"
	label values q27_autism_corner q27_autism_corner

	label variable q28_women_services "Are there separate services for women and adolescent girls with disabilities?"
	note q28_women_services: "Are there separate services for women and adolescent girls with disabilities?"
	label define q28_women_services 1 "Available and effective" 2 "Available but limited" 3 "Not available" 4 "Don’t know"
	label values q28_women_services q28_women_services

	label variable q29_parent_awareness "What initiatives are taken to raise awareness among parents of persons with disa"
	note q29_parent_awareness: "What initiatives are taken to raise awareness among parents of persons with disabilities?"
	label define q29_parent_awareness 1 "Regular meetings and counseling" 2 "Occasional sessions" 3 "Irregular campaigns" 4 "No initiatives" 5 "(Any other, please specify)"
	label values q29_parent_awareness q29_parent_awareness

	//label variable q29_other "Others Specify here"
	//note q29_other: "Others Specify here"

	label variable q30_disabled_staff "Are persons with disabilities included among the staff at your center?"
	note q30_disabled_staff: "Are persons with disabilities included among the staff at your center?"
	label define q30_disabled_staff 1 "Yes, actively" 2 "Partially" 3 "Nominally" 4 "No" 5 "(Any other, please specify)"
	label values q30_disabled_staff q30_disabled_staff

	//label variable q30_other "Others Specify here"
	//note q30_other: "Others Specify here"

	label variable q31_child_preparation "Are there any special preparations needed for providing services to children wit"
	note q31_child_preparation: "Are there any special preparations needed for providing services to children with disabilities?"
	label define q31_child_preparation 1 "Yes, special preparation" 2 "Somewhat needed" 3 "No" 4 "Don’t know" 5 "(Any other, please specify)"
	label values q31_child_preparation q31_child_preparation

	//label variable q31_other "Others Specify here"
	//note q31_other: "Others Specify here"

	label variable q32_capacity_building "In your opinion, what is the most urgent step needed to enhance the center’s cap"
	note q32_capacity_building: "In your opinion, what is the most urgent step needed to enhance the center’s capacity?"
	label define q32_capacity_building 1 "Increased budget" 2 "Recruitment of staff" 3 "Technical assistance" 4 "Alternative or partnership-based models" 5 "Promotion and awareness"
	label values q32_capacity_building q32_capacity_building

	//label variable q32_other "Others Specify here"
	//note q32_other: "Others Specify here"

	label variable q33_additional_services "In your opinion, what additional services should be included in the center?"
	note q33_additional_services: "In your opinion, what additional services should be included in the center?"

	label variable comment "-"
	note comment: "-"






	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  Questionnaire For Collecting Information on Services and Human Resources of Pratibandhi Shahajjo & Seba Kendro (SSK)_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
