library(foreign)
library(tidyverse)
df <- read.spss('./tp/Individual_t414.sav')
write.csv(df, './tp/Individual_t414.csv', row.names=FALSE)
df<-read_csv('./tp/Individual_t414.csv')




#1

Tasas_ej_1 <- df %>% 
        filter(ch06 >= 18  & ch06<= 35) %>% 
        group_by(ch04) %>% 
        summarise(Poblacion         = sum(pondera),
                  Ocupados          = sum(pondera[estado == 'Ocupado']),
                  Desocupados       = sum(pondera[estado == 'Desocupado']),
                  PEA               = Ocupados + Desocupados,
                  'Tasa Actividad'                  = PEA/Poblacion,
                  'Tasa Empleo'                     = Ocupados/Poblacion,
                  'Tasa Desocupacion'               = Desocupados/PEA) %>% 
        select(-c(2:5)) %>% 
        mutate(ch04 = case_when(ch04 != 'Mujer' ~ "Hombre",
                                ch04 == 'Mujer' ~ "Mujer"))

#2 
Salarios_ej_2 <- df %>%
        mutate(gr_edad=ifelse(ch06 >=18 & ch06<=35, '18-35', 
                              ifelse(ch06 >= 36 & ch06<=70,'36-70',NA))) %>%
        filter(estado=='Ocupado' & cat_ocup=='Obrero o empleado') %>%
        group_by(gr_edad, ch04) %>%
        summarise(n=n(),
                  p21=mean(p21))

# 3
        
df %>%
        filter(estado=='Ocupado') %>%
        select(cat_ocup, p21) %>%
        ggplot() +
                geom_histogram(aes(p21)) +
                facet_grid(~cat_ocup)

df %>%
        filter(estado=='Ocupado' & p21 > 0) %>%
        ggplot() +
        geom_boxplot(aes(fill=cat_ocup, y=p21))



    