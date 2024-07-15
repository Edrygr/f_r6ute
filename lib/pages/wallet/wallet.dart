import 'package:flutter/material.dart';
import 'package:rider/theme/theme.dart';
import 'package:rider/widget/column_builder.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final transactionList = [
    {
      "image": "assets/wallet/Image1.png",
      "title": "Paid for ride",
      "time": "Today, 10:25 am",
      "price": "\$30.50",
      "ispaid": true
    },
    {
      "image": "assets/wallet/Image2.png",
      "title": "Paid for ride",
      "time": "Wed 17 Jun, 2020 07:39 am",
      "price": "\$20.50",
      "ispaid": true
    },
    {
      "image": "assets/wallet/Image3.png",
      "title": "Send to Friend",
      "time": "Mon 29 Jun, 2020 07:40 am",
      "price": "\$10.00",
      "ispaid": true
    },
    {
      "image": "assets/wallet/Image4.png",
      "title": "Added to wallet",
      "time": "Tue 23 Jun, 2020 01:17 pm",
      "price": "\$30.50",
      "ispaid": false
    },
    {
      "image": "assets/wallet/Image5.png",
      "title": "Send to Bank",
      "time": "Thu 04 Jun, 2020 07:00 am",
      "price": "\$12.50",
      "ispaid": true
    },
    {
      "image": "assets/wallet/Image6.png",
      "title": "Paid for ride",
      "time": "Mon 01 Jun, 2020 05:05 pm",
      "price": "\$10.50",
      "ispaid": true
    },
    {
      "image": "assets/wallet/Image7.png",
      "title": "Received from Friend",
      "time": "Fri 05 Jun, 2020 06:31 am",
      "price": "\$15.00",
      "ispaid": false
    },
    {
      "image": "assets/wallet/Image8.png",
      "title": "Added to wallet",
      "time": "Wed 17 Jun, 2020 06:49 am",
      "price": "\$20.50",
      "ispaid": true
    },
    {
      "image": "assets/wallet/Image9.png",
      "title": "Paid for ride",
      "time": "Mon 08 Jun, 2020 01:55 am",
      "price": "\$30.50",
      "ispaid": true
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_sharp),
        ),
        title: const Text(
          "Wallet",
          style: appBarStyle,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          walletBalance(size),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  vertical: fixPadding * 2.0, horizontal: fixPadding * 2.0),
              children: [
                paymentMethodsBox(),
                heightSpace,
                heightSpace,
                cuponBox(),
                heightSpace,
                heightSpace,
                const Text(
                  "Recent Transactions",
                  style: bold18Black,
                ),
                tranactionList(size)
              ],
            ),
          )
        ],
      ),
    );
  }

  tranactionList(Size size) {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: fixPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: size.height * 0.07,
                    width: size.height * 0.07,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          transactionList[index]['image'].toString(),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  widthSpace,
                  widthSpace,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Paid for ride",
                          style: semibold16black,
                        ),
                        Text(
                          "Today, 10:25 am",
                          style: regular14Grey,
                        )
                      ],
                    ),
                  ),
                  transactionList[index]['ispaid'] == true
                      ? Text(
                          "+${transactionList[index]['price']}",
                          style: bold16Red,
                        )
                      : Text(
                          "+${transactionList[index]['price']}",
                          style: bold16Primary,
                        )
                ],
              ),
            ),
            transactionList.length == index + 1
                ? const SizedBox()
                : Container(
                    height: 1,
                    width: double.maxFinite,
                    color: lightGreyColor,
                  )
          ],
        );
      },
      itemCount: transactionList.length,
    );
  }

  cuponBox() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: lightGreyColor),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text.rich(
              TextSpan(
                text: "Coupon",
                style: semibold16black,
                children: [
                  TextSpan(text: " "),
                  TextSpan(
                    text: "(3)",
                    style: semibold14Grey,
                  )
                ],
              ),
            ),
          ),
          widthSpace,
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.keyboard_arrow_right,
              color: secondaryColor,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  paymentMethodsBox() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/payments');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: lightGreyColor),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "Payment Methods",
                style: semibold16black,
              ),
            ),
            widthSpace,
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.keyboard_arrow_right,
                color: secondaryColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  walletBalance(Size size) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: fixPadding),
        padding: const EdgeInsets.all(fixPadding * 1.5),
        width: size.width * 0.75,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
                color: blackColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(4, 0)),
            BoxShadow(
                color: blackColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: secondaryColor,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: whiteColor,
                    size: 22,
                  ),
                ),
                widthSpace,
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Wallet",
                        style: bold16Black,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Default Payment Method",
                        style: semibold14Grey,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
            heightSpace,
            const Text(
              "Balance",
              style: semibold14Grey,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              "\$250.50",
              style: bold18Black,
            )
          ],
        ),
      ),
    );
  }
}
