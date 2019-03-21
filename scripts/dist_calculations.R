# Lectura de archivos

comisarias <- read.csv('data/comisarias-policia-de-la-ciudad.csv')
bomberos <- read.csv('data/cuarteles-y-destacamentos-de-bomberos-de-policia-federal-argentina.csv')

# Generación de tipo de punto
comisarias$tipo <- 'Comisaria'
bomberos$tipo <- 'Destacamento Bomberos'

# Unificación de objetos
comisarias <- comisarias %>%
        select(nombre, lat, long, tipo)

bomberos <- bomberos %>% 
        select(dcia, lat, long, tipo) %>%
        rename(nombre=dcia)

final <- bind_rows(comisarias, bomberos)


# Transformación a sf object
final <- st_as_sf(final, 
                  coords=c('long', 'lat'), 
                  crs=4326)

st_write(final, dsn = "./data/com_bomb.geojson", 
         driver = "GeoJSON")


# Cálculo distancias

radios_gral$dist_seg <- radios_gral %>% 
        st_centroid() %>%
        st_distance(final) %>%
        apply(., 1, FUN=min)


st_write(radios_gral, dsn = "./data/radios_gral.geojson", 
         driver = "GeoJSON")


# Plot
ggplot() + 
        geom_sf(data = radios_gral, aes(fill=dist_seg), color=NA) +
        scale_fill_viridis_c() + 
        theme_minimal() + 
        labs(title = "Distancia a comisaría o destacamento de bomberos",
             subtitle = "Radios censales, Ciudad de Buenos Aires",
             fill = "distancias en mts.")


cond_act <- st_read('./data/nbi_radio.geojson')

