import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final paymentMethod = [
    {
      "image": "assets/payment/wallet.png",
      "title": "Wallet",
      "subtitle": "Default payment method",
    },
    {
      "image": "assets/payment/visa.png",
      "title": "**** **** **56 7896",
      "subtitle": "Expires 04/25",
    },
    {
      "image": "assets/payment/mastercard.png",
      "title": "**** **** **56 7896",
      "subtitle": "Expires 04/25",
    }
  ];
  int selectedpayment = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          "Payment Method",
          style: appBarStyle,
        ),
      ),
      body: paymentMethodsListContent(),
      bottomNavigationBar: addNewButton(context, size),
    );
  }

  paymentMethodsListContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          vertical: fixPadding, horizontal: fixPadding * 2.0),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: fixPadding),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedpayment = index;
              });
            },
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(fixPadding),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: lightGreyColor),
              ),
              child: Row(
                children: [
                  Image.asset(
                    paymentMethod[index]['image'].toString(),
                    height: 40,
                    width: 40,
                  ),
                  widthSpace,
                  widthSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          paymentMethod[index]['title'].toString(),
                          style: semibold16black,
                        ),
                        Text(
                          paymentMethod[index]['subtitle'].toString(),
                          style: semibold12Grey,
                        )
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: selectedpayment == index
                        ? secondaryColor
                        : lightGreyColor,
                  )
                ],
              ),
            ),
          ),
        );
      },
      itemCount: paymentMethod.length,
    );
  }

  addNewButton(BuildContext context, Size size) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/newpaymentMethod');
            },
            child: Container(
              margin: const EdgeInsets.only(
                  top: fixPadding * 1.5,
                  bottom: fixPadding * 2.0,
                  left: fixPadding * 2.0,
                  right: fixPadding * 2.0),
              padding: const EdgeInsets.all(fixPadding * 1.3),
              width: size.width * 0.75,
              decoration: BoxDecoration(
                  boxShadow: buttonShadow,
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(5.0)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 22,
                    color: whiteColor,
                  ),
                  widthSpace,
                  Text(
                    "Add New Method",
                    style: bold18White,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
