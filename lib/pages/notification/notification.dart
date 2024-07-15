import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final notificationList = [
    {
      "image": "assets/notification/done.png",
      "title": "System",
      "message": "Your booking has been successfully done!",
      "time": "10 min ago"
    },
    {
      "image": "assets/notification/wallet.png",
      "title": "New payment method",
      "message": "Has been added successfully.",
      "time": "10 min ago"
    },
    {
      "image": "assets/notification/ticket.png",
      "title": "Promotion",
      "message": "Invite friends - Get 3 Coupons each!",
      "time": "10 min ago"
    },
    {
      "image": "assets/notification/close.png",
      "title": "System",
      "message": "Your booking has been cancelled.",
      "time": "10 min ago"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
        title: const Text(
          "Notification",
          style: appBarStyle,
        ),
      ),
      body: notificationList.isEmpty
          ? emptyListContent()
          : notificationListContent(),
    );
  }

  emptyListContent() {
    return const Center(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              color: greyShade3,
              size: 28,
            ),
            heightSpace,
            Text(
              "No new notification",
              style: semibold16Grey,
            )
          ],
        ),
      ),
    );
  }

  notificationListContent() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: notificationList.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          background: Container(
            color: redColor,
          ),
          onDismissed: (direction) {
            setState(() {
              notificationList.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: blackColor,
                content: Text(
                  "Removed from notification",
                  style: bold15White,
                ),
                duration: Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: lightGreyColor,
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          notificationList[index]['image'].toString(),
                          height: 24,
                          width: 24,
                        ),
                      ),
                      widthSpace,
                      width5Space,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notificationList[index]['title'].toString(),
                                    style: semibold16black,
                                  ),
                                ),
                                widthSpace,
                                Text(
                                  notificationList[index]['time'].toString(),
                                  style: regular12Grey,
                                )
                              ],
                            ),
                            Text(
                              notificationList[index]['message'].toString(),
                              style: regular14Grey,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                notificationList.length == index + 1
                    ? const SizedBox()
                    : Container(
                        height: 1,
                        width: double.maxFinite,
                        color: lightGreyColor,
                      )
              ],
            ),
          ),
        );
      },
    );
  }
}
