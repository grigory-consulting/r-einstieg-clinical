

numbers1 <- c(1,3,4,5,6)
numbers2 <- c(1,3,4,5,6,443,"9") # coercion 

# logical < integer < double < character 

logicals <- c(TRUE, FALSE, TRUE)
logicals2 <- c(TRUE, FALSE, 1) # 1 0 1 

# Benannte Vektoren 
einkommen <- c("Anna" = 45000, "Bert" = 60000, "Clara"=70000)
einkommen["Clara"] # bleibt benannt
einkommen[["Clara"]] # Zugriff auf den Wert hinter dem Namen "Clara" 

numbers <- numbers1*9 + 120
numbers

# Zugriffe 

numbers[2]
numbers[c(1,5)] # auf das erste und fünfte Element

# Negativer Zugriff
numbers[-1] # alles außer das erste Element
numbers[-1:-3] # die ersten drei rauslassen 

# Logisches Zugreifen 

mask <- (numbers != 156)
mask

numbers[mask] # alle Elemente, die die Maske erfüllen
numbers[!mask] # alle Elemente, die die Maske nicht erfüllen

# Modifikation 

numbers[2] <- 99
numbers 

# Neue Elemente hinzufügen = Länge + 1 modifizieren 
length(numbers) # Anzahl der Elemente 
numbers[length(numbers) + 1] = 999

numbers

# probieren, nicht in Schleifen zu nutzen 

# Vektorielle Operation/Function 

v1 <- c(1,2,3)
v2 <- c(34,43,11)

v1 + v2 
v1 * v2 # elementenweise Multiplikation

v1 %*% v2 # im Sinne der Matrizenmultiplikation = Skalarprodukt 

sum(v2)
mean(v2)
sort(v2)







