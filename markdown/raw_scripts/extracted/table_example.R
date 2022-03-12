## ----message=FALSE, warning=FALSE---------------------------------------------
complete_table %>%
  select(sex, age_inclusion, poids, taille, imc, Mig_agenda) %>%
  tbl_summary(by = sex,
              type = list(age_inclusion ~ "continuous",
                          Mig_agenda ~ "categorical",
                          poids ~ "continuous",
                          taille ~ "continuous",
                          imc ~ "continuous",
                          sex ~ "dichotomous"),
              statistic = list(imc ~ "{median} ({p25}, {p75})"),
              digits = list(poids ~ c(1, 2),
                            age_inclusion ~ c(0, 0),
                            imc ~ c(0, 0))) %>%
  add_n() %>% # add column with total number of non-missing observations
  add_p() %>% # test for a difference between groups
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels()
  

