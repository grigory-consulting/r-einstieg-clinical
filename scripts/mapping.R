

library(purrr)


numbers <- c(10, 20, 30)

# map garantiert Liste 
purrr::map(numbers, ~ .x^2) # Quadrate in einer Liste 

# moderner
map_dbl(numbers, \(x) x^2) # vector
map_chr(numbers, as.character)

df <- tibble(
  name = c("Anna", "Ben", "Chris", "Dana"),
  alter = c(23, 31, 28, 35),
  stadt = c("Berlin", "Hamburg", "Berlin", "München"),
  einkommen = c(3200, 4100, 3700, 4900)
)

tables <- df %>% group_by(stadt) %>% group_split()

map_dbl(tables, \(df) mean(df$einkommen))


map2_chr(
  c("A", "B"),
  c("C", "D"),
  \(first,second) paste0(first, second)
)



