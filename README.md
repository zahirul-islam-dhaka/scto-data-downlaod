## Pratibandhi Shahajjo Seba Kendro (SSK) Data Processing Project

# Overview
This repository contains a suite of Stata do-files designed to manage and process data related to the Pratibandhi Shahajjo Seba Kendro (SSK) project. The scripts facilitate data download, import, cleaning, and export, ensuring a structured workflow for handling survey data collected via SurveyCTO.

# Features
- Automated data download from the SurveyCTO server
- Import and preparation of CSV data into Stata format
- Data cleaning with variable management and labeling
- Export of cleaned data in multiple formats (DTA, SAV, CSV, XLSX)
- Generation of a codebook summary for documentation

# Requirements
- Stata version 15 or higher
- scto package for Stata (installable via SSC)
- Python 3.x (for dependency management, if applicable)

# Installation
- Clone the repository:
  git clone https://github.com/yourusername/your-repo.git
- Navigate to the project directory:
  cd your-repo
- Install the required Stata package:
ssc install scto

# Usage
- Configure the master do-file (0_master.do) by setting the run_* locals to 1 or 0 to control which sub-do-files execute.
- Update global paths in each do-file to match your local directory structure.
- Execute the master do-file:
  do 0_master.do
- The script will sequentially run 1_scto_data_down.do, 2_import.do, and 3_cleaning.do based on the run controls, producing cleaned data in the 4_Clean directory.

# File Structure
- 0_master.do: Orchestrates the execution of all sub-do-files.
- 1_scto_data_down.do: Downloads data from SurveyCTO.
- 2_import.do: Imports and prepares the CSV data.
- 3_cleaning.do: Cleans and exports the dataset.

# Contributing
  Contributions are welcome. Please fork the repository and submit pull requests, adhering to the project’s code of conduct.

# License
Distributed under the MIT License or as otherwise specified.

# Disclaimer
Use this code responsibly, ensuring compliance with SurveyCTO terms, data privacy laws, and institutional policies. Credentials and server details in 1_scto_data_down.do should be secured and updated as needed.
