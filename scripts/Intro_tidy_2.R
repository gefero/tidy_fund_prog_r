#' # SOLUCIONES
#' ### Consignas 
#' En todos los casos, realice el gráfico que considere más relevante para responder a la pregunta
#' 
#' 1. ¿En qué horarios del día hay más delitos habitualmente? 
#' 
## ----echo=TRUE-----------------------------------------------------------
delitos %>%         
        mutate(hora = hour(hms(hora))) %>%
        select(hora) %>%
        group_by(hora) %>%
        summarise(tot=n()) %>%
        ggplot() + 
                geom_line(aes(x=hora, y=tot), color='red')

#' 
#' 2. ¿Cuál es el tipo de delito más habitual al mediodía? 
#' 
## ----echo=TRUE-----------------------------------------------------------
delitos %>% 
        mutate(hora = hour(hms(hora))) %>%
        select(hora, tipo_delito) %>%
        group_by(hora, tipo_delito) %>%
        summarise(tot=n()) %>%
        ggplot() + 
                geom_line(aes(x=hora, y=tot, color=tipo_delito))


#' 
#' 
#' 3. ¿Puede notarse alguna diferencia en la distribución horaria del total de delitos entre las comunas?
#' 
#' 
## ----echo=TRUE-----------------------------------------------------------
delitos %>% 
        mutate(hora = hour(hms(hora))) %>%
        select(hora, comuna) %>%
        group_by(hora, comuna) %>%
        summarise(tot=n()) %>%
        ggplot() + 
                geom_line(aes(x=hora, y=tot, color=comuna))


#' 
#' 
#' 
#' 4. Genere un gráfico de barras 100% apilado de la distribución de delitos por día de la semana (etiquetada), pero solamente correspondiente a los registros del año 2017:
#' 
#' 
## ------------------------------------------------------------------------
delitos %>%
        filter(year(fecha) >= 2017) %>%
        ggplot() +
                geom_bar(aes(x=wday(fecha, label=TRUE), fill=tipo_delito), position = 'fill')

#' 
#' 
#' 
#' 5. Seleccione el barrio con mayor cantidad de delitos en cada comuna -no es necesario hacer un gráfico-
#' 
## ------------------------------------------------------------------------
delitos %>%
        group_by(comuna, barrio) %>%
        summarise(tot=n()) %>%
        filter(tot==max(tot)) %>%
        arrange(comuna)

#' 
#' ### Consignas
#' Repetir los últimos mapas, pero generando información solamente sobre los hurtos de automotores.
#' 
#' * Densidad por día
#' 
## ----fig.height=12, fig.width=12-----------------------------------------

ggmap(CABA) +
        geom_density2d(data=filter(delitos, tipo_delito=='Robo Automotor' | tipo_delito=='Hurto Automotor'),  aes(x = longitud, y = latitud, color = stat(level))) +
        scale_color_viridis_c() +
        facet_wrap(~dia, nrow=3) +
        labs(title = "Concentración espacial de robos de automotores",
         subtitle = "según día de la semana")



#' 
#' 
#' * Densidad por hora
#' 
## ----fig.height=12, fig.width=12-----------------------------------------
ggmap(CABA) +
    geom_density2d(data = filter(delitos, tipo_delito=='Robo Automotor' | tipo_delito=='Hurto Automotor'), aes(x = longitud, y = latitud, color = stat(level))) +
        scale_color_viridis_c() + 
        facet_wrap(~hora_base, nrow=4) + 
        labs(title = "Concentración espacial de delitos",
         subtitle = "según hora del día")


#' 
