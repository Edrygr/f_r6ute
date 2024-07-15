import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:rider/services/login.dart';
import 'package:rider/theme/theme.dart';

import '../../services/model/loginresponse.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DateTime? backpressTime;
  final PhoneController _phoneController = PhoneController(
      const PhoneNumber(isoCode: IsoCode.US, nsn: "")); // Use PhoneController

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
        body: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image(size),
                  heightSpace,
                  heightSpace,
                  welcomeText(),
                  heightSpace,
                  enterToContinueText(),
                  heightSpace,
                  height5Space,
                  phoneField(context),
                  heightSpace,
                  height5Space,
                  continueButton(size),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  image(Size size) {
    return Image.asset(
      "assets/auth/loginImage.png",
      width: double.maxFinite,
      height: size.height * 0.42,
      fit: BoxFit.fill,
    );
  }

  enterToContinueText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "Enter your phone number to continue",
        style: semibold15Grey,
      ),
    );
  }

  welcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Text(
        "Welcome to R6ote",
        style: bold20Black,
      ),
    );
  }

  continueButton(Size size) {
    return GestureDetector(
      onTap: () {
        login();
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(fixPadding * 2.0),
          width: size.width * 0.75,
          padding: const EdgeInsets.all(fixPadding * 1.3),
          decoration: BoxDecoration(
            color: primaryColor,
            boxShadow: buttonShadow,
            borderRadius: BorderRadius.circular(5.0),
          ),
          alignment: Alignment.center,
          child: const Text(
            "Continue",
            style: bold18White,
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    var phoneNumber = _phoneController.value?.international;
    try {
      LoginService login = LoginService();
      AuthResponse response = await login.validate(phoneNumber!);
      if (response.statusCode == 200) {
        // Navigate to the next screen if validation is successful
        Navigator.pushNamed(context, '/verification', arguments: {
          'phoneNumber': phoneNumber,
        });
      } else {
        // Show an error message if validation fails
        Navigator.pushNamed(context, '/register', arguments: {
          'phoneNumber': phoneNumber,
        });
      }
    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during login: $error'),
        ),
      );
    }
  }

  phoneField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: PhoneFormField(
        controller: _phoneController,
        shouldFormat: false,
        cursorColor: primaryColor,
        defaultCountry: IsoCode.US,
        decoration: const InputDecoration(
          hintText: "Enter your phone number",
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: lightGreyColor,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
        validator: (value) {
          return null;
        },
        countryCodeStyle: bold15Black,
        style: semibold16black,
        isCountryChipPersistent: false,
        isCountrySelectionEnabled: true,
        countrySelectorNavigator: const CountrySelectorNavigator.dialog(),
        showFlagInInput: true,
        flagSize: 20,
        enabled: true,
        autofocus: false,
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
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}
