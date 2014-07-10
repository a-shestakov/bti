initialize = ->
  mapOptions =
    zoom: 12
    center: new google.maps.LatLng(56.830891, 60.5949335)
    mapTypeId: google.maps.MapTypeId.TERRAIN

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

  infowindow = new google.maps.InfoWindow();

  markerByCityName = {}

  window.showMarker = (cityName)->
    infowindow.setContent cityName
    infowindow.open map, markerByCityName[cityName]

  createMarker = (city)->
    marker = new google.maps.Marker(
      map: map
      position: new google.maps.LatLng(city.lat, city.lon)
    )
    markerByCityName[city.name] = marker
    google.maps.event.addListener marker, "click", ->
      window.showMarker(city.name)
      return

  for city in window.citymap
    createMarker(city)

google.maps.event.addDomListener window, "load", initialize