import 'package:flutter/material.dart';
import 'package:s/home/home_screen.dart';


  class ProfilePage extends StatelessWidget {
       final String token;

    final String? userName;
  final String? userEmail;

  ProfilePage({Key? key, this.userName, this.userEmail,     required this.token,
}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Profile',
      home: StackDemo(userName: userName, userEmail: userEmail, token: token,),
      );
    }
  }

  class StackDemo extends StatelessWidget {
           final String token;

      final String? userName;
  final String? userEmail;

  StackDemo({Key? key, this.userName, this.userEmail,     required this.token,
}) : super(key: key);
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 101, 65, 143),
        title: const Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(37,3,3,3),
            child: Text(
              'My Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
       actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0,3,7,3),
              child: IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 31),
                onPressed: () {
                     Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(token:token,)),
                  );
                },
              ),
            ),
          ],),
        
      
      
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // background image and bottom contents
            Column(
              children: <Widget>[
                // Container(
                //   height: 200.0,
                //   color: Colors.orange,
                //   child: Center(
                //     child: Text('Background image goes here'),
                //   ),
                // ),
                Container(
            height: 240,
            decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: const AssetImage('assets/profile.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), // Adjust the opacity to control the dullness
                  BlendMode.dstATop,
                ),
              ),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black,
                  blurRadius: 2.0,
                ),
              ],
            ),
          ),
       
    
                Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                 Colors.white,
                    Color.fromARGB(255, 223, 181, 226)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(userName ?? '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                       SizedBox(height:10),
                        Text(userEmail ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
            ),
          ),
        
              ],
            ),
            // Profile image
           Positioned(
      top: 120.0,
      child: Container(
        height: 200.0,
        width: 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
          image: DecorationImage(
            image: AssetImage('assets/boy1.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),

    // Another stack for the edit icon
  //   Positioned(
  // top: 100.0,
  // right: 80.0,
  // child: Tooltip(
  //   message: 'Edit Profile Picture',
  //   child: InkWell(
  //     onTap: () {
  //       // Handle the tap to edit the profile picture
  //       // For example:
  //       // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePictureScreen()));
  //     },
  //     child: Container(
  //       padding: EdgeInsets.all(8.0), // Adjust the padding for spacing around the icon
  //       child: Icon(
  //         Icons.camera_alt, // Edit icon
  //         color: Colors.white,
  //         size: 40.0,
  //       ),
  //     ),
  //   ),

    
  // ),),
  
          ],
        ),
      );
    }
  }