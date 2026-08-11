library(tidyverse)

df <- tibble(
  name = c("Anna", "Ben", "Chris", "Dana"),
  alter = c(23, 31, 28, 35),
  stadt = c("Berlin", "Hamburg", "Berlin", "München"),
  einkommen = c(3200, 4100, 3700, 4900)
)

# Zeilenauswahl
df %>% filter(alter>=30) %>% # 

filter(df,alter>=30)

df %>% 






# %>% ... tidyverse  

# Spaltenauswahl 

df %>% select(name,einkommen)

# neue Variable berechnen 

df %>% mutate(einkommen_jahr = einkommen*12)


df %>% mutate(name_gross = str_to_upper(name),
              einkommen_gruppe = if_else(
                einkommen>=4000,
                "hoch",
                "OK"
              ),
              
              # Mehrere Bedingungen 
              altersgruppe = case_when(
                alter < 25 ~ "jung", # if
                alter < 35 ~ "mittel", # elseif 
                TRUE ~ "älter" # else 
              )
)

# Gruppieren 

df %>% group_by(stadt) %>% group_split()
    

df %>% group_by(stadt) %>% 
  summarize(
    n=n(),
    mean_alter = mean(alter),
    mean_einkommen = mean(einkommen),
  )


ds <- df  %>% group_by(stadt) %>% group_split() 


statistic <- df %>% 
  group_by(stadt) %>% 
  group_split() %>% 
  lapply(\(x) summary(select(x, -stadt, -name)))

# genau ein Objekt
saveRDS(ds, "ds.rds")
ds <- readRDS("ds.rds")


save(ds,statistic, df, file = "projekt.Rdata")


load("projekt.Rdata")


library(lubridate)

date1 <- lubridate::ymd("2026-08-11")
date2 <- dmy("11.08.2026")

ymd_hms("2026-08-11 14:30:00")
dmy_hm("11.08.2026 14:30")



year(date1)
month(date1)
day(date1)
wday(date1) # Sonntag ist 1 
wday(date1, week_start = 1 , locale = "de_DE")

date1 + days(7)
date1 - months(5)
date1 + years(2) 


#date1 + 7

datetime1 <- ymd_hms("2026-08-11 14:30:00")

#datetime1 +7 

start <- ymd("2025-05-15")
end <- ymd("2026-08-11")

diffd <- end - start
class(diffd) # difftime 

as.numeric(diffd)
as.numeric(diffd, units = "hours")
as.numeric(diffd, units = "weeks")


df <- tibble(
  name = c("Anna", "Ben"),
  start = c("01.08.2026", "03.08.2026"),
  end = c("20.08.2026", "15.08.2026")
)

df %>% mutate(
  start = dmy(start),
  end = dmy(end),
  days = as.numeric(end - start)
)

interval(start, end) / months(1)
interval(start, end) / years(1)

time_length(interval(start, end), "months")



# Join Operationen


personen <- tibble(
  id = c(1,2,3, 1),
  year =c(2026,2025,2024,2024),
  name = c("Anna", "Ben", "Clara", "Bert")
)

einkommen <-tibble(
  pid = c(1,2,4,1),
  year =c(2026,2025,2024,2024),
  einkommen = c(3000, 4100, 5000, 5500)
)

left_join(personen, einkommen, by=c("id"="pid","year"))


inner_join(personen, einkommen, by="id")


right_join(personen, einkommen, by = "id")

full_join(personen,einkommen,by="id")





