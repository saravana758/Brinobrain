import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home/home_screen.dart';
import 'urls.dart'; //

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email = '';
  late String _password = '';
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'assets/top1.png',
                ),
              ),
           Align(alignment: Alignment.bottomLeft,
             child: Positioned(bottom: 0,
              child: FittedBox(
                    fit: BoxFit
                        .contain, 
                    child: Image.asset(
                      'assets/bot.png',
                    ),
                  ),
               ),
           ),
           
              Positioned(
                left: screenWidth * 0.30,
                bottom: screenHeight * 0.13,
                child: SizedBox(
                  height: 55.0,
                  width: 175.0,
                  child: OutlinedButton(
                    onPressed: () {
                      _login();
                    },
                    child: Text(" Login",
                        style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(
                          0xFFEBECF0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30.0),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * 0.23,
                top: screenHeight * 0.12,
                child: Container(
                  child: Text(
                    'Brainobrain',
                    style: TextStyle(
                      color: Color(0xFF6AA1FF),
                      fontFamily: 'Lato',
                      fontSize: screenWidth * 0.09,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w800,
                      height: 1.7,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * 0.37,
                top: screenHeight * 0.20 + 0,
                child: Container(
                  child: Text(
                    'Dictation',
                    style: TextStyle(
                      color: Color(0xFF7DADFF),
                      fontFamily: 'Lato',
                      fontSize: 22,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 250,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 27.0, vertical: 5),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                            });
                          },
                          validator: (email) {
                            if (email!.isEmpty) {
                              return "Please Enter Email";
                            }
                            bool emailValid =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(email);
                            if (!emailValid) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                      //  keyboardType: TextInputType.emailAddress,
                     // obscureText: _obscureText,
                          decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.blue,
                              ),
                              labelText: "Email Address",
                              labelStyle: TextStyle(
                                  fontSize: 19.67853355407715,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 27.0, vertical: 5),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              _password = value;
                            });
                          },
                          validator: (password) {
                            if (password!.isEmpty) {
                              return "Please Enter Password";
                            } else if (password.length < 8 ||
                                password.length > 14) {
                              return "Password is Wrong!!!";
                            }
                            return null;
                          },
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_open,
                              color: Colors.blue,
                            ),
                            labelText: "Password",
                            labelStyle: const TextStyle(
                                fontSize: 19.67853355407715,
                                fontWeight: FontWeight.w500),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   left: screenWidth * 0.37,
                      //    top: screenHeight * 0.2,

                      //   child: SizedBox(
                      //     height: 55.0,
                      //     width: 175.0,
                      //     child: OutlinedButton(
                      //       onPressed: () {
                      //         _login();
                      //       },
                      //       child: Text(" Login",
                      //           style: TextStyle(
                      //               fontSize: screenWidth * 0.07,
                      //               fontWeight: FontWeight.w600,
                      //               color: Colors.black)),
                      //       style: OutlinedButton.styleFrom(
                      //         backgroundColor: Color(
                      //             0xFFEBECF0), // Set your desired background color here
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(
                      //               30.0), // Specify the border radius here
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      print("Email: $_email");
      print("Password: $_password");

      final Map<String, String> requestBody = {
        "email": _email,
        "password": _password,
      };

      final String apiUrl = "$baseUrl/api/login";

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode(requestBody),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        );

        print("Response: ${response.body}");

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final String token = responseData['data']['token'];

          final storage = const FlutterSecureStorage();
          await storage.write(key: 'token', value: token);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(token: token),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                alignment: Alignment.center,
                child: const Text(
                  "Invalid Details!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        print("Error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server Error"),
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    print("_onWillPop method called");

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Exit'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // Returning true means allow popping, false means prevent popping
    return shouldPop ?? false;
  }
}
