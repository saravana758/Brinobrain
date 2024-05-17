import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../home/home_screen.dart';
import 'urls.dart'; 


class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
  
}

class _LogInScreenState extends State<LogInScreen> {
   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email = '';
  late String _password = '';
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
      double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 0,
              ),
              // Image(image: AssetImage('images/Logo.png')),
              // const SizedBox(height: 50),
              Container(
                //padding: const EdgeInsets.all(0),
                 height:screenHeight,
               width: screenWidth,
              //  height: 735,
              //  width: 450,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/bg.png'), // Replace 'your_image.png' with the actual image path
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                    // height: 130,
                     height: screenHeight *0.2,
                    ),
                    Text(
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
                  SizedBox(height: 10,),
                   Text(
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
                    SizedBox(
                     // height: 20,
                      height: screenHeight *0.07,
                    ),
                    Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // SizedBox(
                      //   height: 60,
                      // ),
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
                  ],
                ),
              ),
        SizedBox(
         height: screenHeight *0.27,
          ),
             ElevatedButton(
  onPressed: () {
    _login();
  },
  style: ElevatedButton.styleFrom(
    primary: Color(0xFFEBECF0),
    onPrimary: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 5,
    shadowColor: Colors.grey[400],
    textStyle: TextStyle(
      fontSize: screenWidth * 0.07,
      fontWeight: FontWeight.w600,
    ),
    minimumSize: Size(170, 55), // Change the height and width here
  ),
  child: Text('Login'),
),

            ],
          ),
        ),
     ] ),
      )));
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
