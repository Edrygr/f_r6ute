import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:rider/theme/theme.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final ridesList = [
    {
      "image": "assets/myride/driver1.png",
      "name": "Cameron Williamson",
      "price": "\$30.50",
      "cabname": "Hyundari WagonR",
      "time": "Tue 02 Jun, 2020 11:05 am",
      "pickAddress": "9 Bailey Drive, Fredericton, NB E3B 5A3",
      "dropAddress": "1655 Island Pkwy, Kamloops, BC V2B 6Y9"
    },
    {
      "image": "assets/myride/driver2.png",
      "name": "Jenny Wilson",
      "price": "\$25.50",
      "cabname": "Hyundari WagonR",
      "time": "Mon 29 Jun, 2020 07:40 am",
      "pickAddress": "38 Whiteshell Avenue, Winnipeg, MB R2C",
      "dropAddress": "225 Belleville St, Victoria, BC V8V 1X1"
    },
    {
      "image": "assets/myride/driver3.png",
      "name": "Esther Howard",
      "price": "\$35.500",
      "cabname": "Hyundari WagonR",
      "time": "Thu 04 Jun, 2020 04:51 am",
      "pickAddress": "6387 Arad Street, Niagara Falls, ON L2G 2Z7",
      "dropAddress": "225 Belleville St, Victoria, BC V8V 1X1"
    }
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
        title: const Text(
          "My Rides",
          style: appBarStyle,
        ),
      ),
      body: myRideList(size),
    );
  }

  myRideList(Size size) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      physics: const BouncingScrollPhysics(),
      itemCount: ridesList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/rideDetail');
          },
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(fixPadding),
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: lightGreyColor),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: size.height * 0.08,
                      width: size.height * 0.08,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            ridesList[index]['image'].toString(),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    widthSpace,
                    width5Space,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ridesList[index]['name'].toString(),
                            style: semibold16black,
                            overflow: TextOverflow.ellipsis,
                          ),
                          heightBox(3.0),
                          Text(
                            ridesList[index]['cabname'].toString(),
                            style: regular13Grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            ridesList[index]['time'].toString(),
                            style: regular13Grey,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                    Text(
                      ridesList[index]['price'].toString(),
                      style: bold16Primary,
                    )
                  ],
                ),
                heightSpace,
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.radio_button_checked,
                          color: secondaryColor,
                          size: 20,
                        ),
                        widthSpace,
                        widthSpace,
                        Expanded(
                          child: Text(
                            ridesList[index]['pickAddress'].toString(),
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
                        const Icon(
                          Icons.location_on,
                          color: primaryColor,
                          size: 20,
                        ),
                        widthSpace,
                        widthSpace,
                        Expanded(
                          child: Text(
                            ridesList[index]['dropAddress'].toString(),
                            style: semibold15black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
