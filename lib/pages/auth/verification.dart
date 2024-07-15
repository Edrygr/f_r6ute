import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/login.dart';
import '../../services/model/rvalidation.dart';
import '../../theme/theme.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  final defaultPinTheme = const PinTheme(
    textStyle: bold16Black,
    margin: EdgeInsets.symmetric(horizontal: fixPadding / 2),
    width: 50,
    height: 50,
    constraints:
    BoxConstraints(minHeight: 0, maxHeight: 50, minWidth: 0, maxWidth: 50),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: lightGreyColor, width: 1.5),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>?;
    var phoneNumber = args?['phoneNumber'];
    final size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        centerTitle: false,
        foregroundColor: blackColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_sharp,
          ),
        ),
        title: const Text("Verification", style: appBarStyle),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(fixPadding * 2.0),
        children: [
          const Text(
            "Enter Verification Code",
            style: semibold18black,
            textAlign: TextAlign.center,
          ),
          heightSpace,
          Text(
            "A 4 digit code has been sent to $phoneNumber",
            style: semibold15Grey,
            textAlign: TextAlign.center,
          ),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          otpField(context, phoneNumber),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          resendText(),
        ],
      ),
      bottomNavigationBar: continueButton(context, size, phoneNumber),
    );
  }

  otpField(BuildContext context, phoneNumber) {
    return Form(
      key: formKey,
      child: Pinput(
        controller: _pinController,
        focusNode: focusNode,
        cursor: Container(
          height: 15,
          width: 2,
          color: primaryColor,
        ),
        onCompleted: (value) {
          try {
          validatePin(phoneNumber, _pinController.text);
          } catch (error) {
            Navigator.pushNamed(context, '/login');
          }
        },
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> validatePin(String phoneNumber, String pin) async {
    try {
      LoginService login = LoginService();
      RValidation response = await login.validatePin(phoneNumber, pin);
      if (response.statusCode == 200) {
        String jwt = response.jwt;
        // Navigate to the next screen if validation is successful
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', jwt);
        String? token = prefs.getString('jwt');
        Navigator.pushNamed(context, '/home');
      } else {
        // Show an error message if validation fails
        Navigator.pushNamed(context, '/login');
      }
    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during login: $error'),
        ),
      );
      Navigator.pushNamed(context, '/login');
    }
  }

  continueButton(BuildContext context, Size size, phoneNumber) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery
          .of(context)
          .viewInsets
          .bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              validatePin(phoneNumber, _pinController.text);
              pleaseWaitDialog(context);
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
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: const Text(
                "Continue",
                style: bold18White,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pleaseWaitDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          contentPadding: const EdgeInsets.all(fixPadding * 2.0),
          insetPadding: const EdgeInsets.all(fixPadding * 2.0),
          backgroundColor: whiteColor,
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              height5Space,
              SizedBox(
                height: 45,
                width: 45,
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3.0,
                ),
              ),
              heightSpace,
              heightSpace,
              Text(
                "Please wait...",
                style: regular14Grey,
              ),
              height5Space,
            ],
          ),
        );
      },
    );
  }

  resendText() {
    return const Text.rich(
      TextSpan(
        text: "Didn’t receive a code?",
        style: regular15Grey,
        children: [
          TextSpan(text: " "),
          TextSpan(
            text: "Resend",
            style: bold15Primary,
          )
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
