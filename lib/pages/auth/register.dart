import 'package:flutter/material.dart';
import 'package:rider/theme/theme.dart';

import '../../services/login.dart';
import '../../services/model/rvalidation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _phoneNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    var phoneNumber = args?['phoneNumber'];

    // Initialize _controller with phoneNumber or an empty string if null
    _phoneNumberController = TextEditingController(text: phoneNumber ?? '');
    final size = MediaQuery.of(context).size;
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
        title: const Text("Register", style: appBarStyle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          nameField(),
          heightSpace,
          heightSpace,
          emailField(),
          heightSpace,
          heightSpace,
          phoneField(), // Pass the controller to phoneField
        ],
      ),
      bottomNavigationBar: continueButton(context, size),
    );
  }

  continueButton(BuildContext context, Size size) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              register(_phoneNumberController.text);
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

  Future<void> register(String phoneNumber) async {
    try {
      LoginService login = LoginService();
      RValidation response = await login.register(phoneNumber, _nameController.text,_emailController.text);
      if (response.statusCode == 200) {
        // Navigate to the next screen if validation is successful
        login.validate(phoneNumber);
        Navigator.pushNamed(context, '/verification', arguments: {
          'jwt': response.jwt,
        });
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
    }
  }

  Widget phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Phone Number",
          style: semibold15Grey,
        ),
        TextField(
          style: bold16Black,
          keyboardType: TextInputType.phone,
          cursorColor: primaryColor,
          controller: _phoneNumberController,
          // Use the controller with default value
          decoration: InputDecoration(
            hintText: "Enter your phone number",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightGreyColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email Address",
          style: semibold15Grey,
        ),
        TextFormField(
          controller: _emailController,
          style: bold16Black,
          keyboardType: TextInputType.emailAddress,
          cursorColor: primaryColor,
          decoration: InputDecoration(
            hintText: "Enter your email address",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightGreyColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor,
                width: 1,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            }
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Full Name",
          style: semibold15Grey,
        ),
        TextField(
          style: bold16Black,
          keyboardType: TextInputType.name,
          cursorColor: primaryColor,
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Enter your full name",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightGreyColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: primaryColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
