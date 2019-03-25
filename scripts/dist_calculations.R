# Lectura de archivos

radios_gral <- st_read('./data/radios_info.geojson')

comisarias <- read.csv('data/comisarias-policia-de-la-ciudad.csv')
bomberos <- read.csv('data/cuarteles-y-destacamentos-de-bomberos-de-policia-federal-argentina.csv')
bancos <- read.csv('./data/bancos.csv')


ffcc <- read.csv('./data/estaciones-de-ferrocarril.csv')
subte <- read.csv('./data/estaciones-de-subte.csv')
metrobus <- read.csv('./data/estaciones-de-metrobus.csv')
colectivos <- read.csv('./data/paradas-de-colectivo.csv', sep=";")

# Generación de tipo de punto
comisarias$tipo <- 'Comisaria'
bomberos$tipo <- 'Destacamento Bomberos'
bancos$tipo <- 'Banco'
ffcc$tipo <- "FFCC"
subte$tipo <- "Subte"
metrobus$tipo <- "Metrobus"
colectivos$tipo <- "Colectivos"

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

radios_gral$dist_tren_subte <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final %>% 
                            filter(tipo=='Tren' | tipo=='Subte')
        ) %>%
        apply(., 1, FUN=min)

radios_gral$dist_colectivo_metro <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final %>% 
                            filter(tipo=='Metrobus' | tipo=='Colectivo')
        ) %>%
        apply(., 1, FUN=min)






st_write(radios_gral, dsn = "./data/radios_info_gral.geojson", 
         driver = "GeoJSON", delete_dsn = TRUE)


# Plot
ggplot() + 
        geom_sf(data = radios_gral, aes(fill=dist_seg), color=NA) +
        scale_fill_viridis_c() + 
        theme_minimal() + 
        labs(title = "Distancia a comisaría o destacamento de bomberos",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "distancias en mts.")


cond_act <- st_read('./data/nbi_radio.geojson')

