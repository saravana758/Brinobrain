import 'package:flutter/material.dart';
import 'package:s/login/log.dart';
import 'package:s/login/login_secreen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        
        body: Stack(
          children: [
           
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

             Positioned(
              left: screenWidth * 0.16,
              top: screenHeight * 0.2 + 100, // Adjust the vertical position as needed
              child: Container(
                width: 250,
                height: 232,
                child: Image.asset('assets/4 1.png'),
              ),
            ),
           Positioned(
  left: screenWidth * 0.28,
  top: screenHeight * 0.62 +100,
  child: SizedBox(
    width: screenWidth * 0.5, // Adjust the width as needed
    height: screenHeight * 0.07, // Adjust the height as needed
    child: ElevatedButton(
      onPressed: () {
         Navigator.push(
    context,
    //MaterialPageRoute(builder: (context) => LogScreen()),
     MaterialPageRoute(builder: (context) => LogInScreen()),
  );
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
      ),
      child: Text('Login'),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
