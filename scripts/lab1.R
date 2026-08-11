library(tidyverse)

data_dir <- if (dir.exists("data")) "data" else "../data"
output_dir <- if (dir.exists("data")) "output" else "../output"
dir.create(output_dir, showWarnings = FALSE)


subjects <- read_csv(file.path(data_dir,"subjects.csv"), show_col_types = FALSE)
subjects


visits <- read_csv(file.path(data_dir,"visits.csv"), show_col_types = FALSE)
labvalues <- read_csv2(file.path(data_dir,"labvalues.csv"), show_col_types = FALSE)

glimpse(labvalues)
#View(labvalues)

n_distinct(subjects$subject_id) == nrow(subjects) # eindeutige IDs

# Anzahl fehlender Werte 

colSums(is.na(subjects)) # 2 für Alter, 3 für Raucher 
colSums(is.na(labvalues))
colSums(is.na(visits))

# fünf älteste Personen 

subjects <- subjects %>%
  arrange(desc(age))

head(subjects,5)

subjects[1:5,]
  
# Sortierung nach Randomiesierungsdatum innerhalb der Behandlung 

subjects %>% 
  arrange(behandlung,rand_date) %>%
  select(subject_id,behandlung,rand_date) %>%
  tail(6)

# BMI
# sbp_high (>140)
# bmi_class 

visits2 <- visits %>% 
  mutate(
    bmi = round(weight_kg/height_m^2,1),
    sbp_high = if_else(sbp>=140, "yes", "no"),
    bmi_class = case_when(
      bmi < 25 ~ "normal",
      bmi < 30 ~ "overweight",
      bmi >= 30 ~ "obes",
      TRUE ~ NA_character_ 
    )
  )


visits # aus visits und labvalues nur die ersten Visite herausfiltern 
# Zusammenführen von subject mit beiden Auszügen(visits, labvalues) 
# mutate() z.B. BMI
# Welchen Prüfmöglichkeiten hat man dann?

auszug1 <- visits %>% filter(visit==1) %>% select(-visit, -visit_date)
auszug1

auszug2 <- labvalues %>% filter(visit==1) %>% select(-visit)
auszug2

baseline <- subjects %>%
  left_join(visits %>% filter(visit==1) %>% select(-visit, -visit_date), by="subject_id") %>%
  left_join(labvalues %>% filter(visit==1) %>% select(-visit), by="subject_id") %>%
  mutate(bmi = round(weight_kg/height_m^2,1))

# left_join(left_join(subjects, select(filter(visits, visit == 1), -visit, -visit_date), by = "subject_id"), select(filter(labvalues, visit == 1), -visit), by = "subject_id")

# Pakete laden 

library(labelled)
library(gtsummary)
library(flextable)
library(gt)

baseline <- baseline |>
  mutate(
    behandlung = factor(behandlung, levels = c("A", "B"),
                        labels = c("Behandlung A", "Behandlung B")),
    sex = factor(sex, levels = c("f", "m"),
                 labels = c("weiblich", "männlich")),
    smoker = factor(smoker, levels = c("ja", "nein")),
    center = factor(center, levels = c("Berlin", "Leipzig", "Dresden"))
  ) |>
  set_variable_labels(
    behandlung        = "Behandlungsarm",
    sex        = "Geschlecht",
    age        = "Alter (Jahre)",
    center     = "Studienzentrum",
    smoker     = "Raucherstatus",
    weight_kg  = "Körpergewicht (kg)",
    height_m   = "Körpergröße (m)",
    bmi        = "BMI (kg/m²)",
    sbp        = "Systolischer Blutdruck (mmHg)",
    hba1c      = "HbA1c (%)",
    creatinine = "Kreatinin (mg/dl)"
  )
  
  
tbl_basic <- baseline %>%
  tbl_summary(
    include = c(age, sex, center, smoker, weight_kg, bmi, sbp, hba1c),
    by = behandlung, 
    missing = "no"
  )



tbl_stats <- baseline |>
  tbl_summary(
    include = c(age, sex, center, smoker, weight_kg, bmi, sbp, hba1c),
    by = behandlung,
    statistic = list(
      all_continuous()  ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = list(
      all_continuous()  ~ 1,
      all_categorical() ~ c(0, 1)
    ),
    missing      = "no",
  )


tbl_stats

ft <- as_flex_table(tbl_basic)
save_as_rtf(ft, path = file.path(output_dir, "tabelle_basic.rtf"))

tbl_final <- tbl_stats |>
  add_overall(last = TRUE) |>
  add_n() |>
  add_p() |>
  bold_labels() |>
  modify_header(
    label = "**Merkmal**",
    all_stat_cols() ~ "**{level}** (N = {n})"
  ) |>
  # Kein Markdown in der Beschriftung: flextable übernimmt sie beim RTF- und
  # DOCX-Export wörtlich, dort stünden dann die Sternchen mit im Text.
  modify_caption(
    "Tabelle 1. Ausgangsmerkmale nach Behandlungsarm (synthetische Daten)"
  ) |>
  modify_footnote_header(
    footnote = "Mittelwert (Standardabweichung) bzw. n (%)",
    columns  = all_stat_cols()
  )

save_table_pdf <- function(tbl, path) {
  gt_tbl <- gtsummary::as_gt(tbl) |>
    gt::tab_options(
      latex.use_longtable = TRUE,
      table.font.size     = gt::pct(75)
    )
  tex <- sub("\\.pdf$", ".tex", path)
  writeLines(
    c(
      "\\documentclass[11pt]{article}",
      "\\usepackage[margin=1.5cm,landscape]{geometry}",
      "\\usepackage{booktabs,longtable,array,multirow,caption,graphicx}",
      "\\usepackage{fontspec}",
      "\\begin{document}",
      "\\pagestyle{empty}",
      "\\setlength{\\tabcolsep}{4pt}",
      "\\captionsetup{labelformat=empty}",
      as.character(gt::as_latex(gt_tbl)),
      "\\end{document}"
    ),
    tex,
    useBytes = TRUE
  )
  tinytex::latexmk(tex, engine = "xelatex")
  invisible(path)
}

save_table_pdf(tbl_final, file.path(output_dir, "tabelle_final.pdf"))









