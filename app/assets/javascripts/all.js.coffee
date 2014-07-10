# This example creates circles on the map, representing
# populations in North America.

# First, create an object containing LatLng and population for each city.
initialize = ->

  # Create the map.
  mapOptions =
    zoom: 13
    center: new google.maps.LatLng(56.830891, 60.5949335)
    mapTypeId: google.maps.MapTypeId.TERRAIN

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

  # Construct the circle for each value in citymap.
  # Note: We scale the area of the circle based on the population.
  for city in window.citymap
    populationOptions =
      strokeColor: "#FFFF00"
      strokeOpacity: 0
      strokeWeight: 2
      fillColor: "#FF0000"
      fillOpacity: 0.5
      map: map
      center: new google.maps.LatLng(city[0], city[1])
      radius: city[2]
    new google.maps.Circle(populationOptions)
  return
google.maps.event.addDomListener window, "load", initialize