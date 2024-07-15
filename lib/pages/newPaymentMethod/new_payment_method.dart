import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../theme/theme.dart';

class NewPaymentMethod extends StatefulWidget {
  const NewPaymentMethod({super.key});

  @override
  State<NewPaymentMethod> createState() => _NewPaymentMethodState();
}

class _NewPaymentMethodState extends State<NewPaymentMethod> {
  TextEditingController expriyController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
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
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          Center(
            child: Image.asset(
              "assets/payment/credit_card.png",
              height: size.height * 0.2,
              fit: BoxFit.cover,
            ),
          ),
          heightSpace,
          const Text(
            "Add New Card",
            style: bold16Black,
            textAlign: TextAlign.center,
          ),
          height5Space,
          const Text(
            "Add your debit/credit card",
            style: semibold14Grey,
            textAlign: TextAlign.center,
          ),
          heightSpace,
          heightSpace,
          cardHolderNameField(),
          heightSpace,
          heightSpace,
          cardNumberField(),
          heightSpace,
          heightSpace,
          Row(
            children: [
              expiryColor(context),
              widthSpace,
              widthSpace,
              cvvField()
            ],
          )
        ],
      ),
      bottomNavigationBar: addButton(context, size),
    );
  }

  cvvField() {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CVV",
          style: semibold15Grey,
        ),
        TextField(
          keyboardType: TextInputType.number,
          cursorColor: primaryColor,
          style: bold16Black,
          inputFormatters: [
            LengthLimitingTextInputFormatter(3),
          ],
          obscureText: true,
          controller: cvvController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "CVV",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightGreyColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    ));
  }

  expiryColor(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expiry Date",
            style: semibold15Grey,
          ),
          TextField(
            readOnly: true,
            onTap: () async {
              var pickedDate = await showMonthPicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(
                  const Duration(days: 10000),
                ),
                backgroundColor: whiteColor,
                dismissible: true,
                roundedCornersRadius: 20.0,
                selectedMonthBackgroundColor: primaryColor,
              );

              if (pickedDate != null) {
                String formattedDate = DateFormat('MM/yy').format(pickedDate);
                setState(() {
                  expriyController.text = formattedDate;
                });
              }
            },
            controller: expriyController,
            keyboardType: TextInputType.number,
            cursorColor: primaryColor,
            style: bold16Black,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Expiry Date",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: lightGreyColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  cardNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Card Number",
          style: semibold15Grey,
        ),
        TextField(
          keyboardType: TextInputType.number,
          cursorColor: primaryColor,
          style: bold16Black,
          inputFormatters: [
            LengthLimitingTextInputFormatter(16),
          ],
          controller: numberController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter card number",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightGreyColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  cardHolderNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Card Holder Name",
          style: semibold15Grey,
        ),
        TextField(
          controller: nameController,
          keyboardType: TextInputType.name,
          cursorColor: primaryColor,
          style: bold16Black,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Enter card holder name",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightGreyColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  addButton(BuildContext context, Size size) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
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
              child: const Text(
                "Add",
                style: bold18White,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
