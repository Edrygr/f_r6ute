import 'dart:convert';
import 'dart:ui' as ui;

import 'package:custom_info_window/custom_info_window.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:rider/constants/key.dart';
import 'package:rider/services/model/recent.dart';
import 'package:rider/theme/theme.dart';

class BookNowScreen extends StatefulWidget {
  const BookNowScreen({super.key});

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen>
    with TickerProviderStateMixin {
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();

  late LatLng startLocation;
  late LatLng endLocation;
  late RRecent recent;

  Map<PolylineId, Polyline> polylines = {};
  List<Marker> allMarkers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener los argumentos pasados a la pantalla
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    startLocation = args?['startLocation'];
    recent = args?['endLocation'];
    endLocation = LatLng(recent.latitude, recent.longitude);

    getDirections();
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapApiKey,
        PointLatLng(startLocation.latitude, startLocation.longitude),
        PointLatLng(endLocation.latitude, endLocation.longitude),
        wayPoints: [],
        // Cambia 'Kolkata' a una lista vacía si no tienes wayPoints
        travelMode: TravelMode
            .driving, // Añade TravelMode para especificar el modo de viaje
      );

      if (result.status == 'OK') {
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
          addPolyLine(polylineCoordinates);
          updateCameraToShowAllRoute(polylineCoordinates);
        }
      } else {
        throw Exception('Error al obtener la ruta: ${result.errorMessage}');
      }
    } catch (e) {
      // Manejar el error de forma adecuada
      print('Exception: $e');
    }
  }

  void updateCameraToShowAllRoute(List<LatLng> routeCoordinates) {
    if (routeCoordinates.isEmpty) return;

    double minLat = routeCoordinates.first.latitude;
    double maxLat = routeCoordinates.first.latitude;
    double minLng = routeCoordinates.first.longitude;
    double maxLng = routeCoordinates.first.longitude;

    for (LatLng coord in routeCoordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    // Ampliar los límites en un 10%
    double latDiff = (maxLat - minLat) * 0.1;
    double lngDiff = (maxLng - minLng) * 0.1;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - latDiff, minLng - lngDiff),
      northeast: LatLng(maxLat + latDiff, maxLng + lngDiff),
    );

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: primaryColor,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          googlmap(),
          customInfoWindow(size),
          header(context),
          routeAddressBottomsheet(),
        ],
      ),
    );
  }

  customInfoWindow(Size size) {
    return CustomInfoWindow(
      controller: _customInfoWindowController,
      width: size.width * 0.7,
      height: 40,
      offset: 50,
    );
  }

  googlmap() {
    return GoogleMap(
      onTap: (position) {
        _customInfoWindowController.hideInfoWindow!();
      },
      onCameraMove: (position) {
        _customInfoWindowController.onCameraMove!();
      },
      zoomControlsEnabled: false,
      mapType: MapType.terrain,
      initialCameraPosition: CameraPosition(
        target: startLocation,
        zoom: 15.00,
      ),
      onMapCreated: mapCreated,
      markers: Set.from(allMarkers),
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  routeAddressBottomsheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          curve: Curves.easeIn,
          delay: const Duration(milliseconds: 350),
          child: BottomSheet(
            backgroundColor: Colors.transparent,
            enableDrag: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            onClosing: () {},
            builder: (context) {
              return Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(10, 0),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    heightSpace,
                    heightSpace,
                    Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    height5Space,
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          horizontal: fixPadding * 2),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked,
                                color: secondaryColor,
                                size: 20,
                              ),
                              widthSpace,
                              widthSpace,
                              Expanded(
                                child: Text(
                                  "Current Location",
                                  style: semibold15black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: fixPadding),
                                child: DottedBorder(
                                  padding: EdgeInsets.zero,
                                  strokeWidth: 1.2,
                                  dashPattern: const [1, 3],
                                  color: blackColor,
                                  strokeCap: StrokeCap.round,
                                  child: Container(
                                    height: 40,
                                  ),
                                ),
                              ),
                              widthSpace,
                              Expanded(
                                child: Container(
                                  width: double.maxFinite,
                                  height: 1,
                                  color: lightGreyColor,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: primaryColor,
                                size: 20,
                              ),
                              widthSpace,
                              widthSpace,
                              Expanded(
                                child: Text(
                                  recent.address,
                                  style: semibold15black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/selectCab');
                      },
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(fixPadding * 1.3),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          boxShadow: buttonShadow,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Continue",
                          style: bold18White,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: fixPadding, right: fixPadding, top: fixPadding * 5.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_sharp,
              color: blackColor,
            ),
          ),
          const Expanded(
            child: Text(
              "Book Your Ride",
              style: extrabold20Black,
            ),
          )
        ],
      ),
    );
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    _customInfoWindowController.googleMapController = controller;
    await marker();
    setState(() {});
  }

  marker() async {
    // Calcula la distancia entre startLocation y endLocation en millas

    double distanceInMiles =
        await getDistanceInMiles(startLocation, endLocation);

    String distanceText = "${distanceInMiles.toStringAsFixed(2)} miles";

    allMarkers.add(
      Marker(
        markerId: MarkerId("drop location"),
        position: endLocation,
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            Container(
              width: double.maxFinite,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ]),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      distanceText,
                      // Reemplaza "10km" con la distancia calculada en millas
                      style: bold10White,
                    ),
                  ),
                  widthSpace,
                  Expanded(
                    child: Text(
                      "Dropoff Location",
                      style: semibold14black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            endLocation,
          );
        },
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/bookNow/dropLocation.png", 130),
        ),
      ),
    );

    allMarkers.add(
      Marker(
        markerId: const MarkerId("your location"),
        position: startLocation,
        onTap: () {
            _customInfoWindowController.addInfoWindow!(
              createInfoWindow(distanceText, "Dropoff Location"),
              endLocation,
            );
        },
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/bookNow/currentLocation.png", 60),
        ),
      ),
    );
    setState(() {});
    _customInfoWindowController.addInfoWindow!(
      createInfoWindow(distanceText, "Dropoff Location"),
      endLocation,
    );
  }
  Widget createInfoWindow(String distanceText, String title) {
    return Container(
      width: double.maxFinite,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              distanceText,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<double> getDistanceInMiles(LatLng start, LatLng end) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$googleMapApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distance = data['routes'][0]['legs'][0]['distance']['value'];
      final distanceInMeters = distance.toDouble();
      final distanceInMiles = distanceInMeters / 1609.34; // Convertir a millas
      return distanceInMiles;
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
