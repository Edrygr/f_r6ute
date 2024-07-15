import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rider/constants/key.dart';
import 'package:rider/theme/theme.dart';
import 'package:rider/widget/column_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../services/location.dart';
import '../../services/model/recent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? backpressTime;
  late WebSocketChannel channel;
  late TextEditingController messageController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<RRecent> placeList = [];
  String? jwtToken;

  // final placeList = [
  //   {
  //     "name": "Bailey Drive, Fredericton",
  //     "address": "9 Bailey Drive, Fredericton, NB E3B 5A3"
  //   },
  //   {
  //     "name": "Belleville St, Victoria",
  //     "address": "225 Belleville St, Victoria, BC V8V 1X1"
  //   },
  // ];

  GoogleMapController? mapController;

  late Location _location;
  late LatLng _currentLocation;
  late Marker _currentLocationMarker;
  late StreamSubscription<LocationData> _locationSubscription;

  List<Marker> allMarkers = [];

  List cabMarkers = [];

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(wsBaseUrl);
    messageController = TextEditingController();
    _location = Location();
    _currentLocation = LatLng(0, 0);
    fetchJWT();

    _getCurrentLocation();

    // Websocket
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      final cabId = data['id'];
      final latLng =
          LatLng(data['latLng']['latitude'], data['latLng']['longitude']);
      setState(() {
        // Update cabMarkers list with new data
        final existingMarkerIndex =
            cabMarkers.indexWhere((marker) => marker['id'] == cabId);
        if (existingMarkerIndex != -1) {
          cabMarkers[existingMarkerIndex]['latLng'] = latLng;
        } else {
          cabMarkers.add({
            'image': 'assets/home/cab1.png', // Default image, adjust as needed
            'latLng': latLng,
            'id': cabId,
            'size': 100 // Default size, adjust as needed
          });
        }
        _updateMarkers();
      });
    });
    // end Websocket
  }

  Future<void> fetchJWT() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    setState(() {
      jwtToken = token;
    });
    // Only fetch recent locations if the token is not null
    if (jwtToken != null) {
      fetchRecentLocations();
    } else {
      // Handle the case where the JWT token is null
      print('No JWT token found');
    }
  }

  Future<void> fetchRecentLocations() async {
    RecentService recentService = RecentService();
    List<RRecent> list = await recentService.getRecent(jwtToken!);
    if (list.isNotEmpty) {
      setState(() {
        placeList = list;
      });
    } else {
      // Handle the error
      print('Failed to load recent locations');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
        _currentLocationMarker = Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentLocation,
          infoWindow: InfoWindow(title: 'Tu Ubicación Actual'),
        );
      });
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 15),
      );

      _locationSubscription = _location.onLocationChanged.listen((newLocation) {
        setState(() {
          _currentLocation =
              LatLng(newLocation.latitude!, newLocation.longitude!);
          _currentLocationMarker = Marker(
            markerId: MarkerId('currentLocation'),
            position: _currentLocation,
            infoWindow: InfoWindow(title: 'Tu Ubicación Actual'),
          );
          mapController?.animateCamera(
            CameraUpdate.newLatLng(_currentLocation),
          );
        });
        mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentLocation),
        );
      });
    } catch (e) {
      print('Error al obtener la ubicación: $e');
    }
  }

  void _updateMarkers() async {
    final newMarkers = <Marker>[];
    for (final markerData in cabMarkers) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(markerData['id'].toString()),
          position: markerData['latLng'] as LatLng,
          icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset(markerData['image'], markerData['size']),
          ),
        ),
      );
    }

    setState(() {
      allMarkers = newMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        bool backStatus = onWillpop(context);
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: drawer(size),
        body: Stack(
          children: [
            googleMap(),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: currentLoationBox(),
            ),
            whereToGoBottomSheet(size),
          ],
        ),
      ),
    );
  }

  currentLocationButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: fixPadding, right: fixPadding),
        child: FloatingActionButton(
          backgroundColor: whiteColor,
          mini: true,
          onPressed: _goCurrentPosition,
          child: const Icon(
            Icons.my_location,
            color: blackColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  googleMap() {
    return GoogleMap(
      zoomControlsEnabled: false,
      mapType: MapType.terrain,
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
        zoom: 14.4746,
      ),
      onMapCreated: mapCreated,
      markers: Set.from(allMarkers),
    );
  }

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    await marker();
    setState(() {});
  }

  marker() async {
    // Add the current location marker
    allMarkers.add(
      Marker(
        markerId: const MarkerId("current_location"),
        position: LatLng(_currentLocation.latitude, _currentLocation.longitude),
        icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/home/pickup_Location.png", 130),
        ),
      ),
    );
    for (int i = 0; i < cabMarkers.length; i++) {
      allMarkers.add(
        Marker(
          markerId: MarkerId(cabMarkers[i]['id'].toString()),
          position: cabMarkers[i]['latLng'] as LatLng,
          icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset(
                cabMarkers[i]['image'], cabMarkers[i]['size']),
          ),
        ),
      );
    }
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

  _goCurrentPosition() async {
    final GoogleMapController controller = mapController!;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
      zoom: 14.4746,
    )));
  }

  currentLoationBox() {
    return Container(
      margin: const EdgeInsets.only(
          top: fixPadding * 4.0,
          left: fixPadding * 2.0,
          right: fixPadding * 2.0),
      padding: const EdgeInsets.symmetric(
        vertical: fixPadding * 1.5,
        horizontal: fixPadding,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              scaffoldKey.currentState?.openDrawer();
            },
            child: const Icon(
              Icons.notes,
              color: blackColor,
            ),
          ),
          widthSpace,
          widthSpace,
          const Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.place_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                width5Space,
                Expanded(
                  child: Text(
                    "Current Location",
                    style: semibold15black,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  drawer(Size size) {
    return Row(
      children: [
        Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(20.0),
            ),
          ),
          width: size.width * 0.75,
          backgroundColor: whiteColor,
          child: Column(
            children: [
              userInformation(size),
              drawerItems(),
            ],
          ),
        ),
        closeButton(size),
      ],
    );
  }

  whereToGoBottomSheet(size) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          curve: Curves.easeIn,
          delay: const Duration(milliseconds: 350),
          child: BottomSheet(
            enableDrag: false,
            constraints: BoxConstraints(maxHeight: size.height * 0.6),
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
            ),
            onClosing: () {},
            builder: (context) {
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  currentLocationButton(),
                  Container(
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
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: fixPadding * 2.0, vertical: fixPadding),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Center(
                          child: Container(
                            width: 60,
                            height: 5,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        heightSpace,
                        heightSpace,
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/dropOffLocation',
                                arguments: {
                                  'currentLocation': _currentLocation,
                                });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: fixPadding),
                            width: double.maxFinite,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: greyF0Color,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  CupertinoIcons.search,
                                  color: primaryColor,
                                  size: 22,
                                ),
                                widthSpace,
                                width5Space,
                                Expanded(
                                  child: Text(
                                    "Where to go?",
                                    style: semibold15black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        heightSpace,
                        ColumnBuilder(
                          itemCount: placeList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/bookNow',
                                      arguments: {
                                        'startLocation': _currentLocation,
                                        'endLocation': placeList[index],
                                        // Puedes agregar más datos aquí si es necesario
                                      },
                                    );
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: greyF0Color,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.star_border_rounded,
                                      color: greyShade3,
                                      size: 18,
                                    ),
                                  ),
                                  minLeadingWidth: 0,
                                  title: Text(
                                    placeList[index].name,
                                    style: semibold16black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    placeList[index].address,
                                    style: regular15Grey,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                placeList.length == index + 1
                                    ? const SizedBox()
                                    : Container(
                                        height: 1,
                                        width: double.maxFinite,
                                        color: lightGreyColor,
                                      )
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  userInformation(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 5.0, horizontal: fixPadding * 1.5),
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: size.height * 0.09,
            width: size.height * 0.09,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: size.height * 0.085,
                    width: size.height * 0.085,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/home/User.png",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/editProfile').then(
                          (value) => scaffoldKey.currentState?.closeDrawer());
                    },
                    child: Container(
                      height: size.height * 0.038,
                      width: size.height * 0.038,
                      decoration: const BoxDecoration(
                        color: whiteColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.border_color,
                        size: 15,
                        color: primaryColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          widthSpace,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Samantha Smith",
                  style: bold16White,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "samanthasmith@gmail.com",
                  style: regular14White,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  closeButton(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipPath(
          clipper: CustomMenuClipper(),
          child: Container(
            width: size.width * 0.22,
            height: 130,
            decoration: const BoxDecoration(
              color: whiteColor,
            ),
            padding: const EdgeInsets.only(left: fixPadding / 3),
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                if (scaffoldKey.currentState!.isDrawerOpen) {
                  scaffoldKey.currentState!.closeDrawer();
                }
              },
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: greyColor.withOpacity(0.5),
                      blurRadius: 6,
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  drawerItems() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(fixPadding * 1.5),
        physics: const BouncingScrollPhysics(),
        children: [
          drawerItemWidget(Icons.home_rounded, "Home", () {
            scaffoldKey.currentState!.closeDrawer();
          }),
          divider(),
          drawerItemWidget(Icons.drive_eta, "My Rides", () {
            Navigator.pushNamed(context, '/myride')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.account_balance_wallet_rounded, "Wallet", () {
            Navigator.pushNamed(context, '/wallet')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.notifications_sharp, "Notification", () {
            Navigator.pushNamed(context, '/notification')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(CupertinoIcons.gift_fill, "Invite Friends", () {
            Navigator.pushNamed(context, '/invitefriends')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(CupertinoIcons.question_circle_fill, "FAQs", () {
            Navigator.pushNamed(context, '/faqs')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(Icons.email, "Contact us", () {
            Navigator.pushNamed(context, '/contactUs')
                .then((value) => scaffoldKey.currentState!.closeDrawer());
          }),
          divider(),
          drawerItemWidget(
            Icons.logout,
            "Logout",
            () {
              logoutDialog();
            },
          ),
        ],
      ),
    );
  }

  logoutDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          insetPadding: const EdgeInsets.all(fixPadding * 2.0),
          contentPadding: const EdgeInsets.all(fixPadding * 2.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.question_circle_fill,
                    color: primaryColor,
                  ),
                  widthSpace,
                  Expanded(
                    child: Text(
                      "Do You Want to Logout...?",
                      style: semibold16black,
                    ),
                  )
                ],
              ),
              heightSpace,
              heightSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding, horizontal: fixPadding * 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: greyShade3),
                        color: whiteColor,
                      ),
                      child: const Text(
                        "Cancel",
                        style: bold16Grey,
                      ),
                    ),
                  ),
                  widthSpace,
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding, horizontal: fixPadding * 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        boxShadow: buttonShadow,
                        color: primaryColor,
                      ),
                      child: const Text(
                        "Logout",
                        style: bold16White,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: fixPadding / 4),
      width: double.maxFinite,
      color: lightGreyColor,
    );
  }

  drawerItemWidget(IconData icon, String title, Function() onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 6))
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: whiteColor,
          size: 16,
        ),
      ),
      minLeadingWidth: 0,
      title: Text(
        title,
        style: bold17Black,
      ),
    );
  }

  onWillpop(context) {
    DateTime now = DateTime.now();
    if (backpressTime == null ||
        now.difference(backpressTime!) >= const Duration(seconds: 2)) {
      backpressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: blackColor,
          content: Text(
            "Press back once again to exit",
            style: bold15White,
          ),
          behavior: SnackBarBehavior.fixed,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    channel.sink.close();
    mapController!.dispose();
    super.dispose();
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;

    final width = size.width;
    final height = size.height;

    Path path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 10, 10, 19);
    path.conicTo(width, height / 2, 5, height - 18, 1.0);
    path.conicTo(0, height - 12, 0, height, 1.4);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
