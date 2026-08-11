# ===========================================================================
# Generator für den synthetischen Studien-Beispieldatensatz
# ===========================================================================
# Erzeugt drei Dateien in data/:
#   subjects.csv    Stammdaten pro Person, ein Datensatz je subject_id
#   visits.csv      Messungen pro Visite, mehrere Datensätze je subject_id
#   labvalues.csv   Laborwerte, Schlüssel ist subject_id UND visit
#
# Die Daten sind frei erfunden. Sie ahmen nur die Form einer klinischen
# Studie nach (zwei Behandlungsarme A und B), damit sich Key-Joins,
# Datumsdifferenzen, Labels und Table-1-Tabellen realistisch üben lassen.
# Keine echten Personen, keine echten Messwerte.
#
# Aufruf aus dem Projektwurzel-Verzeichnis:
#   source("data/make_clinical_data.R")
# ===========================================================================

library(dplyr)
library(readr)
library(tidyr)

set.seed(2024)

n_subjects <- 120

centers <- c("Berlin", "Leipzig", "Dresden")

# --- Stammdaten -----------------------------------------------------------
# behandlung wird blockweise zugeteilt, damit beide Arme gleich groß sind.
subjects <- tibble(
  subject_id = sprintf("S%03d", seq_len(n_subjects)),
  behandlung        = rep(c("A", "B"), length.out = n_subjects),
  sex        = sample(c("f", "m"), n_subjects, replace = TRUE, prob = c(0.52, 0.48)),
  age        = round(pmin(pmax(rnorm(n_subjects, mean = 63, sd = 10), 40), 85)),
  center     = sample(centers, n_subjects, replace = TRUE, prob = c(0.45, 0.30, 0.25)),
  smoker     = sample(c("ja", "nein"), n_subjects, replace = TRUE, prob = c(0.28, 0.72)),
  # Randomisierung verteilt über das erste Halbjahr 2024
  rand_date  = as.Date("2024-01-15") + sample(0:165, n_subjects, replace = TRUE)
) |>
  mutate(
    # Tagesdosis hängt am Arm: A = 10 mg, B = 20 mg
    dose_mg_per_day = if_else(behandlung == "A", 10, 20)
  ) |>
  arrange(subject_id)

# Ein paar fehlende Werte, damit NA-Behandlung im Lab vorkommt.
subjects$smoker[c(7, 41, 88)] <- NA
subjects$age[c(15, 102)] <- NA

# --- Visiten --------------------------------------------------------------
# Drei geplante Visiten nach ca. 14, 42 und 84 Tagen, jeweils mit Streuung.
visit_offsets <- c(14, 42, 84)

visits <- subjects |>
  select(subject_id, behandlung, rand_date) |>
  cross_join(tibble(visit = 1:3)) |>
  mutate(
    visit_date = rand_date + visit_offsets[visit] + sample(-3:3, n(), replace = TRUE),
    height_m   = round(rep(rnorm(n_subjects, 1.72, 0.09), each = 3), 2),
    # Gewicht sinkt leicht über die Visiten, Arm B etwas stärker
    weight_kg  = round(
      rep(rnorm(n_subjects, 82, 14), each = 3) -
        (visit - 1) * if_else(behandlung == "B", 1.4, 0.6) +
        rnorm(n(), 0, 1.2),
      1
    ),
    # Systolischer Blutdruck sinkt unter Behandlung, Arm B stärker
    sbp = round(
      rep(rnorm(n_subjects, 148, 13), each = 3) -
        (visit - 1) * if_else(behandlung == "B", 6.5, 3.0) +
        rnorm(n(), 0, 5)
    )
  ) |>
  select(subject_id, visit, visit_date, height_m, weight_kg, sbp) |>
  arrange(subject_id, visit)

# Zwei ausgefallene Messungen
visits$sbp[c(23, 200)] <- NA
visits$weight_kg[310] <- NA

# --- Laborwerte -----------------------------------------------------------
# Eigene Datei, damit der Join über zwei Schlüsselspalten geübt werden kann.
labvalues <- visits |>
  select(subject_id, visit) |>
  mutate(
    hba1c      = round(rnorm(n(), 7.4, 0.8), 1),
    creatinine = round(rnorm(n(), 0.95, 0.18), 2)
  )

labvalues$hba1c[c(5, 77, 150)] <- NA

# --- Schreiben ------------------------------------------------------------
# subjects und visits als Standard-CSV (Punkt als Dezimaltrennzeichen).
write_csv(subjects, "data/subjects.csv")
write_csv(visits, "data/visits.csv")

# labvalues absichtlich im deutschen Excel-Stil: Semikolon plus Komma-Dezimal.
# Damit lässt sich read_csv2() gegen read_csv() abgrenzen.
write_csv2(labvalues, "data/labvalues.csv")

cat("subjects.csv ", nrow(subjects), "Zeilen\n")
cat("visits.csv   ", nrow(visits), "Zeilen\n")
cat("labvalues.csv", nrow(labvalues), "Zeilen\n")
