## -----------------------------------------------------------------------------
# Path were raw data are stored
data_path = file.path(rprojroot::find_root("template-proj.Rproj"),
                      "data")

# Path were processed data are stored
output_dir = file.path(rprojroot::find_root("template-proj.Rproj"),
                       "output")


## -----------------------------------------------------------------------------

subject_db <- read_xlsx(paste0(data_path, "/subject_db.xlsx"), 
                         sheet = 1, 
                         col_names = T,
                         col_types = NULL,
                         na = "NA",
                         trim_ws = T,
                         skip = 0,
                         progress = readxl_progress(),
                         .name_repair = "unique")


## -----------------------------------------------------------------------------
# Convert all "yes" and "no" to "TRUE" or "FALSE" in the table:
subject_db <- subject_db %>% 
  mutate_all(.,str_replace, "^yes$", "TRUE") %>%
  mutate_all(.,str_replace,"^no$", "FALSE")

# Set proper data type (using hablar package)
subject_db <- subject_db %>%
  convert(
    fct(sex),
    lgl(Mig_agenda,
        familial_history_migraine,
        diag_mig_withaura,
        diag_CT),
    dte(date_birth,
        date_inclusion),
    num(poids,
        taille)
    )


## -----------------------------------------------------------------------------

extract.each.patient = function(subject){

# ------ Setup patient-specific environment ------ 
  
# Define (and create if necessary) the patient's output dir :
output_dir_sub = paste0(output_dir,"/",subject)

if (!dir.exists(output_dir_sub)){
  dir.create(output_dir_sub, recursive = TRUE)
  }
  
  
# ------ Access patient-specific data ------

# Check if we can use the patient-specific data
# (Based on the common patients summary table)
if (subject_db %>%
    filter(id_patient == subject) %>%
    select(Mig_agenda) == TRUE) { 

  # If we are allowed to work with this patient's data, then import it's file :
  migraine_agenda_path <- paste0(data_path,"/",
                                 subject,
                                 "/agenda_mig.xlsx")

  migraine_agenda <- read_xlsx(migraine_agenda_path, 
                         sheet = 1, 
                         col_names = T,
                         col_types = NULL,
                         na = "NA",
                         trim_ws = T,
                         skip = 0,
                         progress = readxl_progress(),
                         .name_repair = "unique")

  # If necessary convert all "yes"/"no" to booleans :
  migraine_agenda <- migraine_agenda %>% 
    mutate_all(.,str_replace,"^yes$", "TRUE") %>%
    mutate_all(.,str_replace,"^no$", "FALSE")

  # Clean dates and times as proper datetime objects 
  # (ie. Excel date/time adds "1899-12-31 " strings for hours cells.)
  migraine_agenda <- migraine_agenda %>%
    mutate(time_of_day = str_remove(time_of_day, "1899-12-31 ")) %>%
    mutate(date_time_crisis = paste(date, time_of_day)) %>% 
    mutate(date_time_crisis = ymd_hms(ifelse(is.na(time_of_day),
                                             NA,date_time_crisis))) %>%
    mutate(date = ymd(date))

  
  # Set proper variable type (using hablar package)
  migraine_agenda <- migraine_agenda %>%
    convert(
      fct(intensity_pain,
          type_aura),
      lgl(trigger_fatigue,
          trigger_screen,
          trigger_stress,
          trigger_unknown),
      num(crisis_duration))
  
  # Convert to duration object to handle computation of time/min easily :
  migraine_agenda <- mutate(migraine_agenda, 
                            crisis_duration = dhours(crisis_duration))
  
  # ------ Compute some interesting values ------

  shortest_crisis = dseconds(min(migraine_agenda$crisis_duration))
  longest_crisis = dseconds(max(migraine_agenda$crisis_duration))
  
  # ------ Export patient-specific data and intermediate files ------ 

  ## As CSV files :
  # write_csv2() is more Excel-friendly with french locales (comma vs. dot) 
  # than write_csv().
  write_csv2(migraine_agenda,
             file = paste0(output_dir_sub,"/",
                           subject,"_processed_data.csv"))
  
  ## As .RData file 
  save(migraine_agenda,
       file = paste0(output_dir_sub,"/",
                     subject,"_processed_data.RData"))
  }

# If we can't use that patient's data, print a warning.
else {
  warning(paste0("No migraine agenda available for ", subject,"."))
  }



# ------ Fill one summary line for the subject ------ 

# Extract subject's base line from the common patients table.
# Compute some useful values :
subject_patientdb <- subject_db %>%
  filter(id_patient == subject) %>%
  mutate(age_inclusion = floor(interval(date_birth,
                                        date_inclusion) / years())) %>%
  mutate(imc = poids / (taille / 100) ^ 2)


# Create a summary "subtable" :

if (subject_db %>% filter(id_patient == subject) %>%
    select(Mig_agenda) == TRUE) {
# If we were allowed to use this patient's data, fill the line :  

    crisis_vals <- subject_patientdb %>%
    filter(id_patient == subject) %>%
    mutate(shortest_crisis) %>% # Create columns with previously computed values.
    mutate(longest_crisis)
  } 

else {
# If we were not allowed to use this patient's data, fill with NA :  
  crisis_vals <- subject_patientdb %>%
    filter(id_patient == subject) %>%
    mutate(shortest_crisis = NA) %>%
    mutate(longest_crisis = NA)
  }

# Merge base table with the new "subtable"

complete_line <- subject_patientdb %>%
  left_join(., crisis_vals,
            by = intersect(names(subject_patientdb),
                           names(crisis_vals)))

# Remove personal data if needed
# (name, surname, date of birth after age calculation...)
complete_line <- complete_line %>%
  select(!c(date_birth))

return(complete_line)

}



## ----message=TRUE, warning=TRUE-----------------------------------------------
# Creates a summary table with one line per subject.
# Each line coming from complete_line output of extract.each.patient().

complete_table <- subject_db %>%
  rowwise() %>%
  do(.,extract.each.patient(.$id_patient))
  


## -----------------------------------------------------------------------------
# As Excel-friendly CSV file :
write_csv2(complete_table,
           file = paste0(output_dir,
                         "/complete_extracted_table.csv"))
# As RData :
save(complete_table,
     file = paste0(output_dir,
                   "/complete_extracted_table.RData"))

