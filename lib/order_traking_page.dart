import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

//coordenadas Riobamba

  static const LatLng sourceLocation =
      LatLng(-1.6608577688184512, -78.68350708234605);
  static const LatLng destination =
      LatLng(-1.6532494895515961, -78.64273635978131);

//CODIGO IMPLEMENTADO

//VARIABLE DE COORDENADAS
  List<LatLng> polylineCoordinates = [];
//UBICACION DEL DISPOSITIVO, VARIABLE DE UBICAION ACTUAL
  LocationData? currentLocation;

//ICONOS ORIGEN, DESTINO, UBICACION ACTUAL
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

//FUNCIONES DEF

//FUNCION UBICACION ACTUAL
  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

//VARIABLE CONTROLADOR DEL MAPA
    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (nevLoc) {
        currentLocation = nevLoc;

        //ANIMACIONES
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                nevLoc.latitude!,
                nevLoc.longitude!,
              ),
            ),
          ),
        );

        setState(() {});
      },
    );
  }

//FUNCION DE SINCRONIZACION, PARA CREAR RUTA DESDE ORIGEN HASTA EL DESTINO

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    //VERIFICA QUE LOS PUNTOS NO ESTEN VACIOS
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  //FUNCION MARCADOR ICONO, ORIGEN, DESTINO, UBICACION ACTUAL
  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_source.png")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );

    //
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_destination.png")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );

    //
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Badge.png")
        .then(
      (icon) {
        currentLocationIcon = icon;
      },
    );
  }

//LLAMADO DE CADA FUNCION CREADA
//MUESTRA LA RUTA Y LLAMA A LA FUNCION DE LOS PUNTOS POLIGONALES
  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Google Map ALE",
          style: TextStyle(
              color: Color.fromARGB(255, 215, 228, 245), fontSize: 17),
        ),
      ),

      //Se reemplaza el texto inicial con el cuerpo del Asistente de Mapas de GOOGLE

      body: currentLocation == null
          ? const Center(child: Text("Cargando"))
          //se establece la posicion inicial de ubicacion de origen y destino

          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 13.5,
              ),
              //DEFINO LA POLILINEA Y LAS COORDENADAS
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polylineCoordinates,
                  color: primaryColor,
                  width: 4,
                ),
              },

              //marcadores para definicion de puntos exactos en el mapa
              //Se visualiza la ubicacion de origen en el mapa
              markers: {
                //Marcador de UBICACION ACTUAL
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  icon: currentLocationIcon,
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                ),
                //Marcador de origen
                Marker(
                  markerId: MarkerId("source"),
                  icon: sourceIcon,
                  position: sourceLocation,
                ),
                //Marcador de destino
                Marker(
                  markerId: MarkerId("destination"),
                  icon: destinationIcon,
                  position: destination,
                ),
              },
              //CONTROLADOR DE ACTUALIZACION PARA EL MAPA
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
    );
  }
}
