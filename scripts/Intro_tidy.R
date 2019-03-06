## ----include=FALSE-------------------------------------------------------
knitr::opts_chunk$set(message=FALSE, warning=TRUE, highlight=TRUE)

## ---- message=FALSE, warning=FALSE---------------------------------------
library(tidyverse)
library(sf)
library(gdalUtils)

## ------------------------------------------------------------------------
delitos <- read.csv("../data/delitos.csv")
head(delitos)

## ------------------------------------------------------------------------
ggplot(delitos) + 
        geom_point(aes(x=longitud, y=latitud))

## ------------------------------------------------------------------------
delitos_limpios <- filter(delitos, latitud!=0 | longitud!=0)
head(delitos_limpios)

## ------------------------------------------------------------------------
ggplot(delitos_limpios) + 
        geom_point(aes(x=longitud, y=latitud))

## ------------------------------------------------------------------------
ggplot(delitos_limpios) + 
        geom_point(aes(x=longitud, y=latitud), color='blue') +
        coord_map("mercator")

## ------------------------------------------------------------------------
ggplot(delitos_limpios) + 
        geom_point(aes(x=longitud, y=latitud), color='red', size=0.05) +
        coord_map("mercator")

## ------------------------------------------------------------------------
ggplot(delitos_limpios) + 
        geom_point(aes(x=longitud, y=latitud), color='red', size=0.05, shape=3) +
        coord_map("mercator")

## ---- fig.height = 5, fig.width = 8--------------------------------------
ggplot(delitos_limpios) + 
        geom_point(aes(x=longitud, y=latitud, color=tipo_delito), size=0.05, alpha=0.25) +
        facet_wrap(~tipo_delito) +
        coord_map("mercator")

## ------------------------------------------------------------------------
ggplot(delitos_limpios, aes(x=tipo_delito))+
        geom_bar(stat="count")

## ------------------------------------------------------------------------
ggplot(delitos_limpios, aes(x=tipo_delito))+
        geom_bar(stat="count") + 
        scale_x_discrete(labels = abbreviate)

## ------------------------------------------------------------------------
ggplot(delitos_limpios, aes(x=tipo_delito))+
        geom_bar(stat="count") + 
        scale_x_discrete(labels = c('H.doloso','H.seg.vial', 'Hurto(s/v)', 
                                    'Robo(c/v)', 'Robo auto', 'Hurto auto', 'Lesion.seg.vial'))

## ------------------------------------------------------------------------
str(delitos_limpios)

## ------------------------------------------------------------------------
summary(delitos_limpios)

## ------------------------------------------------------------------------
levels(delitos_limpios$barrio)

## ----message=FALSE, warning=FALSE----------------------------------------
library(lubridate)

delitos_limpios <- mutate(delitos_limpios, fecha=ymd(fecha), hora=hms(hora))

## ------------------------------------------------------------------------
p <- group_by(delitos_limpios, fecha) 
periodo <- summarise(p, gran_total = n())

head(periodo)

## ------------------------------------------------------------------------
ggplot(periodo) + 
        geom_histogram(aes(x = gran_total))

## ------------------------------------------------------------------------
p <- group_by(delitos_limpios, fecha, tipo_delito)
periodo <- summarise(p, gran_total=n())

head(periodo)

## ------------------------------------------------------------------------
ggplot(periodo) + 
        geom_histogram(aes(x=gran_total)) + 
        facet_wrap(~tipo_delito)

## ------------------------------------------------------------------------
table(year(delitos_limpios$fecha))

## ------------------------------------------------------------------------
at_ciudadano <- read.csv("../data/sistema-unico-de-atencion-ciudadana-2016.csv", sep=";")
head(at_ciudadano)

## ------------------------------------------------------------------------
str(at_ciudadano)

## ----message=FALSE, warning=TRUE-----------------------------------------
at_barrio <- select(at_ciudadano, DOMICILIO_BARRIO, RUBRO)
head(at_barrio)

## ------------------------------------------------------------------------
at_barrio <- filter(at_barrio, RUBRO == 'DENUNCIAS SOBRE INCONDUCTAS REFERIDAS A LA ACTUACION POLICIAL' | RUBRO == 'EMERGENCIAS' |  RUBRO == 'SEGURIDAD' | RUBRO == 'SEGURIDAD E HIGIENE' | RUBRO == 'VEHICULOS DE FANTASIA')

## ------------------------------------------------------------------------
at_barrio_agg <- group_by(at_barrio, DOMICILIO_BARRIO)
at_barrio_agg <- summarize(at_barrio_agg, total=n())

## ------------------------------------------------------------------------
at_barrio_agg <- arrange(at_barrio_agg, desc(total))
head(at_barrio_agg)

## ------------------------------------------------------------------------
at_barrio <- select(at_ciudadano, DOMICILIO_BARRIO, RUBRO)

at_barrio <- filter(at_barrio, RUBRO == 'DENUNCIAS SOBRE INCONDUCTAS REFERIDAS A LA ACTUACION POLICIAL' | RUBRO == 'EMERGENCIAS' |  RUBRO == 'SEGURIDAD' | RUBRO == 'SEGURIDAD E HIGIENE' | RUBRO == 'VEHICULOS DE FANTASIA')

at_barrio_agg <- group_by(at_barrio, DOMICILIO_BARRIO)

at_barrio_agg <- summarize(at_barrio_agg, total=n())

arrange(at_barrio_agg, desc(total))

## ------------------------------------------------------------------------
at_barrio <- select(at_ciudadano, DOMICILIO_BARRIO, RUBRO) %>%
        filter(RUBRO == 'DENUNCIAS SOBRE INCONDUCTAS REFERIDAS A LA ACTUACION POLICIAL' | 
                       RUBRO == 'EMERGENCIAS' |  RUBRO == 'SEGURIDAD' | 
                       RUBRO == 'SEGURIDAD E HIGIENE' | RUBRO == 'VEHICULOS DE FANTASIA') %>%
        group_by(DOMICILIO_BARRIO) %>% 
        summarize(total=n()) %>% 
        arrange(desc(total))

head(at_barrio)

## ------------------------------------------------------------------------
delitos_barrio <- select(delitos_limpios, barrio, tipo_delito) %>%
        group_by(barrio) %>% 
        summarize(total=n()) %>% 
        arrange(desc(total))

head(delitos_barrio)

## ------------------------------------------------------------------------
barrios <- left_join(delitos_barrio, at_barrio)
barrios

## ------------------------------------------------------------------------
at_barrio <- at_barrio %>%
                rename(barrio=DOMICILIO_BARRIO)

barrios <- left_join(delitos_barrio, at_barrio, by='barrio')

## ------------------------------------------------------------------------
filter(barrios, is.na(total.y))

## ------------------------------------------------------------------------
at_barrio$barrio <- as.character(at_barrio$barrio)
at_barrio$barrio[at_barrio$barrio=='MONSERRAT'] <- 'MONTSERRAT'
at_barrio$barrio[at_barrio$barrio=='BOCA'] <- 'LA BOCA'
at_barrio$barrio[at_barrio$barrio=='VILLA GRAL. MITRE'] <- 'VILLA GRAL MITRE'
at_barrio$barrio[at_barrio$barrio=='COGHLAN'] <- 'COGHLAND'
at_barrio$barrio <- as.factor(at_barrio$barrio)

## ------------------------------------------------------------------------
barrios <- left_join(delitos_barrio, at_barrio, by='barrio') %>%
                        rename(n_delitos = total.x, n_reclamos=total.y)

## ------------------------------------------------------------------------
barrios %>%
        filter(!is.na(n_reclamos))

## ------------------------------------------------------------------------
barrios <- barrios %>% 
        mutate(n_reclamos=replace_na(n_reclamos, 0))

## ------------------------------------------------------------------------
 ggplot(barrios, aes(x=n_delitos, y=n_reclamos), color='red') + 
        geom_point() + 
        geom_smooth(method = 'lm') +
         labs(title = "Delitos registrados según contactos al SIUAC vinculados a seguridad",
         subtitle = "Barrios de la CABA, 2016 - 2017",
         caption = "Fuente: portal de datos abiertos de la Ciudad - http://data.buenosaires.gob.ar",
         x = "Cantidad de delitos",
         y = "Cantidad de contactos")

## ------------------------------------------------------------------------
 ggplot(barrios, aes(x=n_delitos, y=n_reclamos), color='red') + 
        geom_point() + 
        geom_smooth(method = 'loess', span=0.8, se=FALSE) +
         labs(title = "Delitos registrados según contactos al SIUAC vinculados a seguridad",
         subtitle = "Barrios de la CABA, 2016 - 2017",
         caption = "Fuente: portal de datos abiertos de la Ciudad - http://data.buenosaires.gob.ar",
         x = "Cantidad de delitos",
         y = "Cantidad de contactos")

## ------------------------------------------------------------------------
 ggplot(barrios, aes(x=n_delitos, y=n_reclamos), color='red') + 
        geom_point() + 
        geom_smooth(method = 'loess', span=0.3) +
         labs(title = "Delitos registrados según contactos al SIUAC vinculados a seguridad",
         subtitle = "Barrios de la CABA, 2016 - 2017",
         caption = "Fuente: portal de datos abiertos de la Ciudad - http://data.buenosaires.gob.ar",
         x = "Cantidad de delitos",
         y = "Cantidad de contactos")

