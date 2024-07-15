import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final faqList = [
    {
      "title": "Sign in Issue",
      "question": "Issue regarding login, register, verification etc.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Cab Booking",
      "question": "Issue regarding booking a ride.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Payment",
      "question": "Problem related to payment methods.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Map Loading",
      "question": "Map loading issue, route issue, location picker etc.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Report Driver",
      "question": "Report misbehave driver, block driver.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
    },
    {
      "title": "Other Issue",
      "question": "Wrong information provided fake driver etc.",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed hendrerit elementum fringilla gravida blandit craseget mauris mauris. Ipsum, iaculis elementum senectus non condimentum id massa eget."
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
          "FAQs",
          style: appBarStyle,
        ),
      ),
      body: faqsListContent(),
    );
  }

  faqsListContent() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(fixPadding * 2.0),
      itemCount: faqList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                expansionTileTheme: const ExpansionTileThemeData(
                  iconColor: primaryColor,
                  collapsedIconColor: primaryColor,
                  collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
                ),
              ),
              child: ExpansionTile(
                shape: const RoundedRectangleBorder(),
                iconColor: primaryColor,
                childrenPadding: const EdgeInsets.only(bottom: fixPadding),
                tilePadding:
                    const EdgeInsets.symmetric(vertical: fixPadding / 2),
                title: Text(
                  faqList[index]['title'].toString(),
                  style: semibold14Grey,
                ),
                subtitle: Text(
                  faqList[index]['question'].toString(),
                  style: semibold16black,
                ),
                children: [
                  Text(
                    faqList[index]['answer'].toString(),
                    style: regular14Grey,
                  ),
                ],
              ),
            ),
            faqList.length == index + 1
                ? const SizedBox()
                : Container(
                    height: 1,
                    color: lightGreyColor,
                    width: double.maxFinite,
                  )
          ],
        );
      },
    );
  }
}
