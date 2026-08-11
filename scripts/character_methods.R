

name <- "    Anna Meier \n\t\r"

nchar(name) # Anzahl der Zeichen (inkl. Leerzeichen)
name2 <- trimws(name) # Leerzeichen an Rändern entfernen
toupper(name2) # alles groß
tolower(name2) # alles klein 

# Gleichheit prüfen 
tolower("Anna") == tolower("ANNA")


substr("Statistik", 1,4) # Zeichen von 1 bis 4


paste("Umsatz", 2026) # zusammenführen, Trenner = Leerzeichen 
paste("Umsatz", 2026, sep = "_") # eigener Trenner
paste0("Umsatz", 2026) # ohne Trenner 

paste("Teilnehmer", 1:5)
paste0("Teilnehmer", 1:5)


sub("n", "N", "Bananen") # ersetzt NUR das erste n
gsub("n", "N", "Bananen") # ersetzt ALLE

library(tidyverse)

dog <- "The quick brown dog"

str_to_title(dog) # die ersten Buchstaben groß 

cities <- c("Berlin", "Bonn", "München", "Bremen")
cities == "München"
cities != "München"

"München" %in% cities 
cities %in% c("Bonn", "Berlin", "Hamburg") # Maske: welche Elemente aus cities sind dabei?

identical("Anna", "Anna")
identical(c("a","b"), c("a","b"))
identical("1", 1) # FALSE, weil Typ nicht stimmt 
identical(1,1L)




