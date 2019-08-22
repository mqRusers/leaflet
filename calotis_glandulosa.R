## MAP OF KNOWN OBSERVATIONS AND CURRENT MANAGEMENT SITES FOR CALOTIS GLANDULOSA, A THREATENED PLANT SPECIES IN NEW SOUTH WALES

install.packages(c('leaflet','tidyverse','rgdal'))

require(leaflet)
require(tidyverse)
require(rgdal)

# read in some species observation data - latitude / longitude format (WGS84 projection)
spdat <- readr::read_csv('data/calotis_glandulosa.csv')

# read in a shapefile with polygons defining species management sites
management_sites <- rgdal::readOGR('data/C_glandulosa_sites/C_glandulosa.shp')

# create a leaflet map! 
# Note if we don't assign this to an object it will plot in the Viewer pane of RStudio

leaflet() %>% # using pipes (%>%) - these can be translated as "and then do"
  
  # tell leaflet to use OpenStreetMap for the basemap tiles
  addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
  
  # plot species observations as circles with radius 100 (not sure what units this is, but it's relative so it looks the same size at whatever map zoom level you're on)
  addCircles(spdat$longitude, spdat$latitude,
             fill = TRUE,
             color = "blue",
             weight = 0.6,
             opacity = 0.5,
             fillOpacity = 0.5,
             radius = 100,
  )

# lets create something more sophisticated

leaflet() %>%
  
  addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
  
  # species observations
  addCircles(spdat$longitude, spdat$latitude,
             fill = TRUE,
             color = "blue",
             weight = 0.6,
             opacity = 0.5,
             fillOpacity = 0.5,
             radius = 100,
  ) %>%

  # draw polygons which define the sites where the species is already being managed by the NSW government
  addPolygons(data=management_sites,
              weight = 1,
              color = "red",
              fillColor = "red",
              opacity = 1,
              popup = paste( # when site polygons are clicked, a popup will display the site name
                '<strong>SoS Site:</strong>', as.character(management_sites$SiteName))) %>% # use some HTML for formatting the popup

  # put a minimap in bottom left corner, for context
  addMiniMap(tiles = providers$OpenStreetMap.Mapnik,
             toggleDisplay = TRUE,
             position = "bottomleft",
             width=100,
             height=100) %>%
  
  # add a legend with properties that we specify manually
  addLegend(position = "bottomright", colors = c('blue', "red"), labels=c('Species observations', 'Current management sites'), opacity=1)


# the species observations have some attribute data - lets show this in a popup

leaflet() %>% 
  
  addProviderTiles(providers$OpenStreetMap.Mapnik, group = "OpenStreetMap") %>%
  
  # note that because we build a Leaflet map by adding layers, we need to have the polygons under the points or when we click them we'll just get the popup with the site name
  # so add the polygon layer before the points (circles) layer
  addPolygons(data=management_sites,
              weight = 1,
              color = "red",
              fillColor = "red",
              opacity = 1,
              popup = paste(
                '<strong>SoS Site:</strong>', as.character(management_sites$SiteName))) %>%

  # species observations
  addCircles(spdat$longitude, spdat$latitude,
             fill = TRUE,
             color = "blue",
             weight = 0.6,
             opacity = 0.5,
             fillOpacity = 0.5,
             radius = 100,
             popup = paste( 
               #create an on-click popup with info about the observations
                 '<strong>Species:</strong>', as.character(spdat$scientificName), '<br>', # popups can be as sophisticated as you want if you know HTML
                 '<strong>Locality:</strong>', as.character(spdat$locality), '<br>',
                 '<strong>Year of observation:</strong>', spdat$year,'<br>',
                 '<strong>Data provider:</strong>', spdat$dataProvider)
  ) %>%
  
  # minimap in bottom left corner
  addMiniMap(tiles = providers$OpenStreetMap.Mapnik,
             toggleDisplay = TRUE,
             position = "bottomleft",
             width=100,
             height=100) %>%
  
  addLegend(position = "bottomright", colors = c('blue', "red"), labels=c('Species observations', 'Current management sites'), opacity=1)
