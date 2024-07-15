import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rider/services/location.dart';
import 'package:rider/services/model/recent.dart';
import 'package:rider/theme/theme.dart';
import 'package:rider/widget/column_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DropOffLocation extends StatefulWidget {
  const DropOffLocation({super.key});

  @override
  State<DropOffLocation> createState() => _DropOffLocationState();
}

class _DropOffLocationState extends State<DropOffLocation> {
  List<RRecent> recent = [];
  String? jwtToken;

  @override
  void initState() {
    super.initState();
    fetchJWT();
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
        recent = list;
      });
    } else {
      // Handle the error
      print('Failed to load recent locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    var currentLocation = args?['currentLocation'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        centerTitle: false,
        foregroundColor: blackColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding),
        children: [
          whereToGoField(currentLocation),
          heightSpace,
          heightSpace,
          goToHome(currentLocation), // Modified
          goForWork(currentLocation), // Modified
          heightSpace,
          recentTitle(),
          recentList(currentLocation), // Modified
        ],
      ),
    );
  }

  recentList(var currentLocation) {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/bookNow',
                  arguments: {
                    'startLocation': currentLocation,
                    'endLocation': LatLng(recent[index].latitude, recent[index].longitude),
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
                  Icons.history,
                  color: greyShade3,
                  size: 18,
                ),
              ),
              minLeadingWidth: 0,
              title: Text(
                recent[index].name.toString(),
                style: semibold16black,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                recent[index].address.toString(),
                style: regular15Grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            recent.length == index + 1
                ? const SizedBox()
                : Container(
              height: 1,
              width: double.maxFinite,
              color: lightGreyColor,
            )
          ],
        );
      },
      itemCount: recent.length,
    );
  }

  recentTitle() {
    return const Text(
      "Recent",
      style: bold18Black,
    );
  }

  goForWork(var currentLocation) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/bookNow',
          arguments: {
            'currentLocation': currentLocation,
            'selectedLocation': 'Work Address', // Replace with the actual work address
          },
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: fixPadding),
        child: Row(
          children: [
            Icon(
              Icons.work,
              color: primaryColor,
              size: 20,
            ),
            widthSpace,
            widthSpace,
            Expanded(
              child: Text(
                "Work",
                style: semibold16black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  goToHome(var currentLocation) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/bookNow',
          arguments: {
            'currentLocation': currentLocation,
            'selectedLocation': 'Home Address', // Replace with the actual home address
          },
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: fixPadding),
        child: Row(
          children: [
            Icon(
              Icons.home_rounded,
              color: primaryColor,
              size: 21,
            ),
            widthSpace,
            widthSpace,
            Expanded(
                child: Text(
                  "Home",
                  style: semibold16black,
                ))
          ],
        ),
      ),
    );
  }

  whereToGoField(var currentLocation) {
    TextEditingController locationController = TextEditingController();

    return Container(
      width: double.maxFinite,
      height: 110,
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.2),
            child: Column(
              children: [
                const Icon(
                  Icons.radio_button_checked,
                  color: secondaryColor,
                  size: 20,
                ),
                Expanded(
                  child: DottedBorder(
                    padding: EdgeInsets.zero,
                    strokeWidth: 1.2,
                    dashPattern: const [2, 3],
                    color: blackColor,
                    strokeCap: StrokeCap.round,
                    child: Container(),
                  ),
                ),
                const Icon(
                  Icons.location_on,
                  color: primaryColor,
                  size: 20,
                )
              ],
            ),
          ),
          widthSpace,
          width5Space,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Current Location",
                      style: semibold15black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  height: 1,
                  color: lightGreyColor,
                ),
                Expanded(
                  child: TextField(
                    controller: locationController,
                    cursorColor: primaryColor,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Where to go?",
                    ),
                    onSubmitted: (value) {
                      Navigator.pushNamed(
                        context,
                        '/bookNow',
                        arguments: {
                          'currentLocation': currentLocation,
                          'selectedLocation': value,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
