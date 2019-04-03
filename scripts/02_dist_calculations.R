# Lectura de archivos

radios_gral <- st_read('./data/radios_info.geojson')

comisarias <- read.csv('data/comisarias-policia-de-la-ciudad.csv')
bomberos <- read.csv('data/cuarteles-y-destacamentos-de-bomberos-de-policia-federal-argentina.csv')
bancos <- read.csv('./data/bancos.csv')


ffcc <- read.csv('./data/estaciones-de-ferrocarril.csv')
subte <- read.csv('./data/estaciones-de-subte.csv')
metrobus <- read.csv('./data/estaciones-de-metrobus.csv')
colectivos <- read.csv('./data/paradas-de-colectivo.csv', sep=";", dec=",")

# Generación de tipo de punto
comisarias$tipo <- 'Comisaria'
bomberos$tipo <- 'Destacamento Bomberos'
bancos$tipo <- 'Banco'
ffcc$tipo <- "FFCC"
subte$tipo <- "Subte"
metrobus$tipo <- "Metrobus"
colectivos$tipo <- "Colectivos"

#check colectivos
colectivos$LINEAS %>%
        as.character() %>%
        str_split(., "[:punct:]") %>%
        unlist() %>%
        unique() %>%
        as.integer() %>%
        sort()


# Unificación de objetos

comisarias <- comisarias %>%
        select(nombre, lat, long, tipo)

bancos <- bancos %>%
        select(nombre, lat, long, tipo)

bomberos <- bomberos %>% 
        select(dcia, lat, long, tipo) %>%
        rename(nombre=dcia)

ffcc <- ffcc %>%
        select(nombre, lat, long, tipo)

subte <- subte %>%
        select(estacion, lat, long, tipo) %>%
        rename(nombre=estacion)

metrobus <- metrobus %>%
        select(nombre, lat, long, tipo)

colectivos <- colectivos %>%
        select(NUMERO, X, Y, tipo) %>%
        rename(nombre=NUMERO, long=X, lat=Y)  %>%
        mutate(nombre=as.character(nombre),
               long=as.numeric(long),
               lat=as.numeric(lat))

final <- bind_rows(comisarias, bomberos, bancos, ffcc, subte, metrobus, colectivos)


# Transformación a sf object
final <- st_as_sf(final, 
                  coords=c('long', 'lat'), 
                  crs=4326)

st_write(final, dsn = "./data/places_complete.geojson", 
         driver = "GeoJSON", delete_dsn=TRUE)


# Cálculo distancias


radios_gral$dist_bancos <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final %>% 
                            filter(tipo=='Banco')
                    ) %>%
        apply(., 1, FUN=min)

radios_gral$dist_seguridad <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final %>% 
                            filter(tipo=='Comisaria' | tipo=='Destacamento Bomberos')
        ) %>%
        apply(., 1, FUN=min)

radios_gral$dist_tren <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final %>% 
                            filter(tipo=='FFCC')
        ) %>%
        apply(., 1, FUN=min)

radios_gral$dist_subte <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final %>% 
                            filter(tipo=='Subte')
        ) %>%
        apply(., 1, FUN=min)



radios_gral$dist_colectivo <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final %>% 
                            filter(tipo=='Colectivos')
        ) %>%
        apply(., 1, FUN=min)

radios_gral$dist_metrobus <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final %>% 
                            filter(tipo=='Metrobus')
        ) %>%
        apply(., 1, FUN=min)


st_write(radios_gral, dsn = "./data/radios_info_gral.geojson", 
         driver = "GeoJSON", delete_dsn = TRUE)


radios_gral <- st_read("./data/radios_info_gral.geojson")

# Plot
ggplot() + 
        geom_sf(data = radios_gral, aes(fill=dist_seguridad), color=NA) +
        scale_fill_viridis_c() + 
        theme_minimal() + 
        labs(title = "Distancia a comisaría o destacamento de bomberos",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "distancias en mts.")


# Plot
ggplot() + 
        geom_sf(data = radios_gral, aes(fill=dist_bancos), color=NA) +
        scale_fill_viridis_c() + 
        theme_minimal() + 
        labs(title = "Distancia a bancos",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "distancias en mts.")


# Plot
ggplot() + 
        geom_sf(data = radios_gral, aes(fill=dist_tren), color=NA) +
        scale_fill_viridis_c() + 
        theme_minimal() + 
        labs(title = "Distancia a estaciones de tren",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "distancias en mts.")


# Plot
ggplot() + 
        geom_sf(data = radios_gral, aes(fill=dist_subte), color=NA) +
        scale_fill_viridis_c() + 
        theme_minimal() + 
        labs(title = "Distancia a estaciones de subte",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "distancias en mts.")


# Plot
ggplot() + 
        geom_sf(data = radios_gral, aes(fill=dist_colectivo), color=NA) +
        scale_fill_viridis_c() + 
        theme_minimal() + 
        labs(title = "Distancia a estaciones de colectivo",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "distancias en mts.")


# Plot
ggplot() + 
        geom_sf(data = radios_gral, aes(fill=dist_metrobus), color=NA) +
        scale_fill_viridis_c() + 
        theme_minimal() + 
        labs(title = "Distancia a estaciones de metrobus",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "distancias en mts.")



## Agrega precios de departamentos


dptos16 <- read.csv('./data/departamentos-en-venta-2016.csv',
                  sep=";") %>% 
        select(U_S_M2, LONGITUD, LATITUD) %>%
        mutate(period=2016)


dptos15 <- read.csv('./data/departamentos-en-venta-2015.csv',
                    sep=";", stringsAsFactors = FALSE) %>%
        select(U_S_M2, LONGITUD, LATITUD) %>%
        mutate(period=2015,
               U_S_M2=as.numeric(str_replace(U_S_M2, ",", ".")))

dptos13 <- read.csv('./data/departamentos-en-venta-2013.csv',
                    sep=";", stringsAsFactors = FALSE) %>%
        select(U_S_M2, LON, LAT) %>%
        mutate(period=2013) %>%
        rename(LONGITUD=LON, LATITUD=LAT)


dptos14 <- read.csv('./data/departamentos-en-venta-2014.csv',
                    sep=";", stringsAsFactors = FALSE) %>%
        select(U_S_M2, LON, LAT) %>%
        mutate(period=2014) %>%
        rename(LONGITUD=LON, LATITUD=LAT)



dptos12 <- read.csv('./data/departamentos-en-venta-2012.csv',
                    sep=";", stringsAsFactors = FALSE) %>%
        select(U_S_M2, LON, LAT) %>%
        mutate(period=2012) %>%
        rename(LONGITUD=LON, LATITUD=LAT)

dptos11 <- read.csv('./data/departamentos-en-venta-2011.csv',
                    sep=";", stringsAsFactors = FALSE) %>%
        select(U_S_M2, LON, LAT) %>%
        mutate(period=2011) %>%
        rename(LONGITUD=LON, LATITUD=LAT)

dptos10 <- read.csv('./data/departamentos-en-venta-2010.csv',
                    sep=";", stringsAsFactors = FALSE) %>%
        select(U_S_M2, LON, LAT) %>%
        mutate(period=2010) %>%
        rename(LONGITUD=LON, LATITUD=LAT)


dptos09 <- read.csv('./data/departamentos-en-venta-2009.csv',
                    sep=";", stringsAsFactors = FALSE) %>%
        select(U_S_M2, LON, LAT) %>%
        mutate(period=2009) %>%
        rename(LONGITUD=LON, LATITUD=LAT)


radios_gral <- st_read("./data/radios_info_gral.geojson")

dptos_final<- bind_rows(dptos09, dptos10, dptos11,dptos12, 
                        dptos13, dptos14, dptos15, dptos16) %>%
        filter(!is.na(LATITUD) | !is.na(LONGITUD)) %>%
        st_as_sf(
                coords=c('LONGITUD', 'LATITUD'), 
                crs=4326)

remove(dptos09, dptos10, dptos11,dptos12, 
       dptos13, dptos14, dptos15, dptos16)
        
dptos_radio <- st_join(dptos_final, 
                         select(radios_gral, RADIO), 
                         join = st_within) %>%
        as_tibble() 

radios_gral <- dptos_radio %>%
        group_by(RADIO) %>%
        summarise(n_dptos=n(),
                  mean_USS_M2 = mean(U_S_M2),
                  std_USS_M2 = sd(U_S_M2),
                  median_USS_M2 = median(U_S_M2),
                  mad_USS2_M2 = mad(U_S_M2)) %>%
        left_join(x=radios_gral) %>%
        replace(., is.na(.),0) 


radios_gral <- radios_gral %>%
        replace(., is.na(.),0) 

ggplot() + 
        geom_sf(data=radios_gral, aes(fill=mean_USS_M2), color=NA) +
        scale_fill_viridis_c() +
        theme_minimal() + 
        labs(title = "Precio medio del M2 (en U$S)",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "U$S / M2.")

ggplot() + 
        geom_sf(data=radios_gral, aes(fill=std_USS_M2), color=NA) +
        scale_fill_viridis_c() +
        theme_minimal() + 
        labs(title = "Desvío estándar del precio del M2 (en U$S)",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "U$S / M2.")

ggplot() + 
        geom_sf(data=radios_gral, aes(fill=median_USS_M2), color=NA) +
        scale_fill_viridis_c() +
        theme_minimal() + 
        labs(title = "Precio mediano del M2 (en U$S)",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "U$S / M2.")


ggplot() + 
        geom_sf(data=radios_gral, aes(fill=mad_USS2_M2), color=NA) +
        scale_fill_viridis_c() +
        theme_minimal() + 
        labs(title = "Desvío absoluto mediano del precio del M2 (en U$S)",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "U$S / M2.")



st_write(radios_gral, dsn = "./data/radios_info_gral.geojson", 
         driver = "GeoJSON", delete_dsn = TRUE)

st_write(dptos_final, dsn = "./data/precios_dptos09_16.geojson", 
         driver = "GeoJSON", delete_dsn = TRUE)
