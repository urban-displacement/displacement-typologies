sc_vars <-
c(
### AMI Variables
	'HHInc_Total' = 'B19001_001', # Total HOUSEHOLD INCOME
	'HHInc_10' = 'B19001_002', # Less than $10,000 HOUSEHOLD INCOME
	'HHInc_15' = 'B19001_003', # $10,000 to $14,999 HOUSEHOLD INCOME
	'HHInc_20' = 'B19001_004', # $15,000 to $19,999 HOUSEHOLD INCOME
	'HHInc_25' = 'B19001_005', # $20,000 to $24,999 HOUSEHOLD INCOME
	'HHInc_30' = 'B19001_006', # $25,000 to $29,999 HOUSEHOLD INCOME
	'HHInc_35' = 'B19001_007', # $30,000 to $34,999 HOUSEHOLD INCOME
	'HHInc_40' = 'B19001_008', # $35,000 to $39,999 HOUSEHOLD INCOME
	'HHInc_45' = 'B19001_009', # $40,000 to $44,999 HOUSEHOLD INCOME
	'HHInc_50' = 'B19001_010', # $45,000 to $49,999 HOUSEHOLD INCOME
	'HHInc_60' = 'B19001_011', # $50,000 to $59,999 HOUSEHOLD INCOME
	'HHInc_75' = 'B19001_012', # $60,000 to $74,999 HOUSEHOLD INCOME
	'HHInc_100' = 'B19001_013', # $75,000 to $99,999 HOUSEHOLD INCOME
	'HHInc_125' = 'B19001_014', # $100,000 to $124,999 HOUSEHOLD INCOME
	'HHInc_150' = 'B19001_015', # $125,000 to $149,999 HOUSEHOLD INCOME
	'HHInc_200' = 'B19001_016', # $150,000 to $199,999 HOUSEHOLD INCOME
	'HHInc_250' = 'B19001_017', # $200,000 or more HOUSEHOLD INCOME
### Renting household variables
	'totten' = 'B25003_001', # Total # households
	'totrent' = 'B25003_003', # total # renting households
### POC variables
	'race_tot' = 'B03002_001',
	'race_White' = 'B03002_003',
	'race_Black' = 'B03002_004',
	'race_Asian' = 'B03002_006',
	'race_Latinx' = 'B03002_012',
### Median Rent
	'medrent' = 'B25064_001',
### Students
	'st_totenroll' = 'B14007_001',
	'st_colenroll' = 'B14007_017',
	'st_proenroll' = 'B14007_018',
	'st_pov_under' = 'B14006_009', 
	'st_pov_grad' = 'B14006_010', 
### Additional Pop-up Variables
	# Overall rent-burden
	'rb_tot' = 'B25070_001',
	'rb_34.9' = 'B25070_007',
	'rb_39.9' = 'B25070_008',
	'rb_49.9' = 'B25070_009',
	'rb_55' = 'B25070_010',
	# On public assistance
	'welf_tot' = 'B19057_001',
	'welf' = 'B19057_002',
	# Poverty
	'pov_tot' = 'B17017_001',
	'pov_famh' = 'B17017_003',
	'pov_nonfamh' = 'B17017_020',
	# Unemployed
	'unemp_tot' = 'B23025_001',
	'unemp' = 'B23025_005',
	# female headed households
	'fhh_tot' = 'B11005_001',
	'fhh_famheadch' = 'B11005_007',
	'fhh_nonfamheadch' = 'B11005_010',
	# Median household income
	'mhhinc' = 'B19013_001')

# Rent burden by LI status
ir_var <- c(
	'ir_tot_tot' = 'B25074_001',# Estimate!!Total
	'ir_tot_9999' = 'B25074_002', # Estimate!!Total!!Less than $10 000
	'ir_19_9999' = 'B25074_003', # Estimate!!Total!!Less than $10 000!!Less than 20.0 percent
	'ir_249_9999' = 'B25074_004', # Estimate!!Total!!Less than $10 000!!20.0 to 24.9 percent
	'ir_299_9999' = 'B25074_005', # Estimate!!Total!!Less than $10 000!!25.0 to 29.9 percent
	'ir_349_9999' = 'B25074_006', # Estimate!!Total!!Less than $10 000!!30.0 to 34.9 percent
	'ir_399_9999' = 'B25074_007', # Estimate!!Total!!Less than $10 000!!35.0 to 39.9 percent
	'ir_499_9999' = 'B25074_008', # Estimate!!Total!!Less than $10 000!!40.0 to 49.9 percent
	'ir_5plus_9999' = 'B25074_009', # Estimate!!Total!!Less than $10 000!!50.0 percent or more
	'ir_x_9999' = 'B25074_010', # Estimate!!Total!!Less than $10 000!!Not computed
	'ir_tot_19999' = 'B25074_011', # Estimate!!Total!!$10 000 to $19 999
	'ir_19_19999' = 'B25074_012', # Estimate!!Total!!$10 000 to $19 999!!Less than 20.0 percent
	'ir_249_19999' = 'B25074_013', # Estimate!!Total!!$10 000 to $19 999!!20.0 to 24.9 percent
	'ir_299_19999' = 'B25074_014', # Estimate!!Total!!$10 000 to $19 999!!25.0 to 29.9 percent
	'ir_349_19999' = 'B25074_015', # Estimate!!Total!!$10 000 to $19 999!!30.0 to 34.9 percent
	'ir_399_19999' = 'B25074_016', # Estimate!!Total!!$10 000 to $19 999!!35.0 to 39.9 percent
	'ir_499_19999' = 'B25074_017', # Estimate!!Total!!$10 000 to $19 999!!40.0 to 49.9 percent
	'ir_5plus_19999' = 'B25074_018', # Estimate!!Total!!$10 000 to $19 999!!50.0 percent or more
	'ir_x_19999' = 'B25074_019', # Estimate!!Total!!$10 000 to $19 999!!Not computed
	'ir_tot_34999' = 'B25074_020', # Estimate!!Total!!$20 000 to $34 999
	'ir_19_34999' = 'B25074_021', # Estimate!!Total!!$20 000 to $34 999!!Less than 20.0 percent
	'ir_249_34999' = 'B25074_022', # Estimate!!Total!!$20 000 to $34 999!!20.0 to 24.9 percent
	'ir_299_34999' = 'B25074_023', # Estimate!!Total!!$20 000 to $34 999!!25.0 to 29.9 percent
	'ir_349_34999' = 'B25074_024', # Estimate!!Total!!$20 000 to $34 999!!30.0 to 34.9 percent
	'ir_399_34999' = 'B25074_025', # Estimate!!Total!!$20 000 to $34 999!!35.0 to 39.9 percent
	'ir_499_34999' = 'B25074_026', # Estimate!!Total!!$20 000 to $34 999!!40.0 to 49.9 percent
	'ir_5plus_34999' = 'B25074_027', # Estimate!!Total!!$20 000 to $34 999!!50.0 percent or more
	'ir_x_34999' = 'B25074_028', # Estimate!!Total!!$20 000 to $34 999!!Not computed
	'ir_tot_49999' = 'B25074_029', # Estimate!!Total!!$35 000 to $49 999
	'ir_19_49999' = 'B25074_030', # Estimate!!Total!!$35 000 to $49 999!!Less than 20.0 percent
	'ir_249_49999' = 'B25074_031', # Estimate!!Total!!$35 000 to $49 999!!20.0 to 24.9 percent
	'ir_299_49999' = 'B25074_032', # Estimate!!Total!!$35 000 to $49 999!!25.0 to 29.9 percent
	'ir_349_49999' = 'B25074_033', # Estimate!!Total!!$35 000 to $49 999!!30.0 to 34.9 percent
	'ir_399_49999' = 'B25074_034', # Estimate!!Total!!$35 000 to $49 999!!35.0 to 39.9 percent
	'ir_499_49999' = 'B25074_035', # Estimate!!Total!!$35 000 to $49 999!!40.0 to 49.9 percent
	'ir_5plus_49999' = 'B25074_036', # Estimate!!Total!!$35 000 to $49 999!!50.0 percent or more
	'ir_x_49999' = 'B25074_037', # Estimate!!Total!!$35 000 to $49 999!!Not computed
	'ir_tot_74999' = 'B25074_038', # Estimate!!Total!!$50 000 to $74 999
	'ir_19_74999' = 'B25074_039', # Estimate!!Total!!$50 000 to $74 999!!Less than 20.0 percent
	'ir_249_74999' = 'B25074_040', # Estimate!!Total!!$50 000 to $74 999!!20.0 to 24.9 percent
	'ir_299_74999' = 'B25074_041', # Estimate!!Total!!$50 000 to $74 999!!25.0 to 29.9 percent
	'ir_349_74999' = 'B25074_042', # Estimate!!Total!!$50 000 to $74 999!!30.0 to 34.9 percent
	'ir_399_74999' = 'B25074_043', # Estimate!!Total!!$50 000 to $74 999!!35.0 to 39.9 percent
	'ir_499_74999' = 'B25074_044', # Estimate!!Total!!$50 000 to $74 999!!40.0 to 49.9 percent
	'ir_5plus_74999' = 'B25074_045', # Estimate!!Total!!$50 000 to $74 999!!50.0 percent or more
	'ir_x_74999' = 'B25074_046', # Estimate!!Total!!$50 000 to $74 999!!Not computed
	'ir_tot_99999' = 'B25074_047', # Estimate!!Total!!$75 000 to $99 999
	'ir_19_99999' = 'B25074_048', # Estimate!!Total!!$75 000 to $99 999!!Less than 20.0 percent
	'ir_249_99999' = 'B25074_049', # Estimate!!Total!!$75 000 to $99 999!!20.0 to 24.9 percent
	'ir_299_99999' = 'B25074_050', # Estimate!!Total!!$75 000 to $99 999!!25.0 to 29.9 percent
	'ir_349_99999' = 'B25074_051', # Estimate!!Total!!$75 000 to $99 999!!30.0 to 34.9 percent
	'ir_399_99999' = 'B25074_052', # Estimate!!Total!!$75 000 to $99 999!!35.0 to 39.9 percent
	'ir_499_99999' = 'B25074_053', # Estimate!!Total!!$75 000 to $99 999!!40.0 to 49.9 percent
	'ir_5plus_99999' = 'B25074_054', # Estimate!!Total!!$75 000 to $99 999!!50.0 percent or more
	'ir_x_99999' = 'B25074_055', # Estimate!!Total!!$75 000 to $99 999!!Not computed
	'ir_tot_100000' = 'B25074_056', # Estimate!!Total!!$100 000 or more
	'ir_19_100000' = 'B25074_057', # Estimate!!Total!!$100 000 or more!!Less than 20.0 percent
	'ir_249_100000' = 'B25074_058', # Estimate!!Total!!$100 000 or more!!20.0 to 24.9 percent
	'ir_299_100000' = 'B25074_059', # Estimate!!Total!!$100 000 or more!!25.0 to 29.9 percent
	'ir_349_100000' = 'B25074_060', # Estimate!!Total!!$100 000 or more!!30.0 to 34.9 percent
	'ir_399_100000' = 'B25074_061', # Estimate!!Total!!$100 000 or more!!35.0 to 39.9 percent
	'ir_499_100000' = 'B25074_062', # Estimate!!Total!!$100 000 or more!!40.0 to 49.9 percent
	'ir_5plus_100000' = 'B25074_063', # Estimate!!Total!!$100 000 or more!!50.0 percent or more
	'ir_x_100000' = 'B25074_064' # Estimate!!Total!!$100 000 or more!!Not computed
	)