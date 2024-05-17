import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:s/home/home_screen.dart';
import 'homepage.dart';
import 'login/login_secreen.dart';

//import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    checkLoginStatus();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> checkLoginStatus() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    Timer(const Duration(seconds: 5), () {
      if (_mounted) {
        if (token != null) {
          print('Navigate to HomePage');
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(token: token,)));
        } else {
          print('Navigate to LoginScreen');
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 252, 252),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 45,
            ),
            const Text(
              "Brainobrain",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 7, 100, 177),
              ),
            ),
            const Text(
              "Dictation",
              style: TextStyle(fontSize: 25, color: Colors.cyan),
            ),
            Center(
              child: Container(
                height: 60,
                width: 60,
                child: Lottie.asset(
                  'assets/animation_lmyiihn1.json',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:  AppBar(
//             backgroundColor: const Color.fromARGB(255, 121, 14, 170),
//             title: const Center(
//               child: Text(
//                 'Brainobrain Dictation',
//                 style: TextStyle(fontSize: 24, color: Colors.white),
//               ),
//             ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.all(0),
//              child: Container(
//               height: 300,
//               width: 500,
//              // color: Colors.amber,
                     
//               child:Image.asset(
//               'assets/aba.png',
//               width: 200, // Set the width of the image
//               height: 150, // Set the height of the image
//               fit: BoxFit.fill, // Optional: maintain the aspect ratio
//             ), // Make sure to put your image in the 'assets' folder
//                      ),
//            ),
// //             SizedBox(height: 40),
// //            Container(
// //             //color: Colors.amber,
// //   height: 70,
// //   width: 300,
// //   child: Center(
// //     child: Text(
// //                 'Hello There!',
// //                 style: GoogleFonts.prata(
// //                   fontSize: 28,
// //                   fontWeight: FontWeight.bold,
// //       ),
// //     ),
// //   ),
// // ),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 // ElevatedButton(
//                 //   onPressed: () {},
//                 //   child: const Text(
//                 //     'Guest  Login',
//                 //     style: TextStyle(
//                 //       fontWeight: FontWeight.bold,
//                 //       fontSize: 22,
//                 //       color: Colors.white,
//                 //     ),
//                 //   ),
//                 //   style: ElevatedButton.styleFrom(
//                 //     backgroundColor: const Color.fromARGB(255, 121, 44, 243),
//                 //     padding: const EdgeInsets.all(10.0),
//                 //     minimumSize: const Size(150.0, 50.0),
//                 //   ),
//                 // ),
                
//                 const SizedBox(width: 0,),
//                Padding(
//   padding: const EdgeInsets.fromLTRB(0, 105, 0, 0.0),
//   child: ElevatedButton(
//     onPressed: () {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => HomePage(),
//         ),
//       );
//     },
//      child: Text(
//                 'Login',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 36,
//                   color: Colors.white,
//                 ),
//               ),
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Color.fromARGB(255, 144, 102, 211),
//       padding: const EdgeInsets.all(10.0),
//       minimumSize: const Size(180.0, 20.0),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(50.0), // Adjust the radius as needed
//       ),
//     ),
//   ),
// ),

//               ],
//             ),
   
//           ],
//         ),
//       ),
      
//     );
//   }
// }
