# Gen dataset valor de oferta



read_data <- function(path="E:/PEN/Datasets_ML/PreciosTerrenos/",
                      patt='.csv'){
        files <- dir(path, '.csv', full.names = TRUE)
        files <- files[15:16]
        
        df <- files %>% 
                map_df(~read_delim(., delim=";"))
        return(df)
}

df <- read_data()

df <- df[!is.na(df$X) | !is.na(df$Y),]

ggplot(df) +
        geom_point(aes(x=Y, y=X))



# Gen dataset radios

#INDEC
radios <- read.csv('./data/censo_PHV_2010.csv')

#geojson
radios_gral <- st_read('./data/radios_gral.geojson')

radios_gral <- cbind(radios_gral, str_split(as.character(radios_gral$RADIO_ID), "_", simplify = TRUE))
radios_gral$X1 <- as.character(radios_gral$X1)
radios_gral$X2 <- as.character(radios_gral$X2)
radios_gral$X3 <- as.character(radios_gral$X3)

for (n in 1:nrow(radios_gral)){
        if (nchar(radios_gral$X1[n])==1){ radios_gral$X1[n] <- paste('00', radios_gral$X1[n], sep="")}
        if (nchar(radios_gral$X1[n])==2){ radios_gral$X1[n] <- paste('0', radios_gral$X1[n], sep="")}
        if (nchar(radios_gral$X2[n])==1){ radios_gral$X2[n] <- paste('0', radios_gral$X2[n], sep="")}
        if (nchar(radios_gral$X3[n])==1){ radios_gral$X3[n] <- paste('0', radios_gral$X3[n], sep="")}
}

radios_gral$RADIO <- paste('02', radios_gral$X1, radios_gral$X2, radios_gral$X3, sep="")


radios <- radios %>%
        mutate(
        tasa_desoc = PERSONA.Condici????n.de.actividad._.Desocupado / (PERSONA.Condici????n.de.actividad._.Ocupado + PERSONA.Condici????n.de.actividad._.Desocupado)*100,
        tasa_act = (PERSONA.Condici????n.de.actividad._.Desocupado + PERSONA.Condici????n.de.actividad._.Ocupado)/(PERSONA.Condici????n.de.actividad._.Ocupado + PERSONA.Condici????n.de.actividad._.Desocupado + PERSONA.Condici????n.de.actividad._.Inactivo)*100,
        razon_masc = PERSONA.Sexo._.Var????n / PERSONA.Sexo._.Mujer,
        prop_mayores = PERSONA.Edad.en.grandes.grupos._.65.y.m??.s / PERSONAS*100,
        tasa_cal_construct_insuf = VIVIENDA.Calidad.constructiva.de.la.vivienda._.Insuficiente / (VIVIENDA.Calidad.constructiva.de.la.vivienda._.Satisfactoria + VIVIENDA.Calidad.constructiva.de.la.vivienda._.B??.sico + VIVIENDA.Calidad.constructiva.de.la.vivienda._.Insuficiente)*100,
        tasa_cal_serv_insuf = VIVIENDA.Calidad.Conexiones.Servicios.B??.sicos._.Insuficiente / (VIVIENDA.Calidad.Conexiones.Servicios.B??.sicos._.Satisfactorio + VIVIENDA.Calidad.Conexiones.Servicios.B??.sicos._.B??.sico + VIVIENDA.Calidad.Conexiones.Servicios.B??.sicos._.Insuficiente)*100,
        tasa_cal_mat_insuf = (VIVIENDA.Calidad.de.materiales._.Calidad.4 + VIVIENDA.Calidad.de.materiales._.Calidad.3) /(VIVIENDA.Calidad.de.materiales._.Calidad.1+VIVIENDA.Calidad.de.materiales._.Calidad.2+VIVIENDA.Calidad.de.materiales._.Calidad.3+VIVIENDA.Calidad.de.materiales._.Calidad.4)*100
        ) %>%
        select(RADIO, PROVINCIA, tasa_desoc, tasa_act, razon_masc, prop_mayores, 
               tasa_cal_construct_insuf, tasa_cal_serv_insuf, 
               tasa_cal_mat_insuf)

radios<-radios %>% 
        mutate(RADIO=ifelse(nchar(RADIO)==8, paste('0',RADIO,sep=""),as.character(RADIO))) %>%
        filter(PROVINCIA=='Ciudad Aut????noma de Buenos Aires')

radios_gral<-radios_gral %>% 
        left_join(radios, by="RADIO") %>%
        select(-c(X1, X2, X3, dist_seg, PROVINCIA)) %>%
        select(RADIO, RADIO_ID, everything())

names(radios_gral)

st_write(radios_gral, dsn = "./data/radios_info.geojson", 
         driver = "GeoJSON")

