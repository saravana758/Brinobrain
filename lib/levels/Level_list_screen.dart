import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:level/levels/inside.dart';

import '../home/home_screen.dart';
import '../models/Level.dart';
import 'section_list_screen.dart';
//import 'inside_level.dart';
//import 'inside_level.dart';

class LevelListScreen extends StatefulWidget {
   final String token;
   const LevelListScreen({Key? key, required this.token}) : super(key: key);
  @override
  _LevelListScreenState createState() => _LevelListScreenState();
}

class _LevelListScreenState extends State<LevelListScreen> {
  List<Level> levels = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':
          'Bearer ${widget.token}',
    };

    var response = await http.get(
      Uri.parse('https://bob-fms.trainingzone.in/api/practice/levels'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      final data = responseJson['data'];
      final List<Level> fetchedLevels = (data['levels'] as List)
          .map((item) => Level.fromJson(item))
          .toList();

      setState(() {
        levels = fetchedLevels;
      });

      print('Response: ${response.body}');
       print('Token: ${widget.token}');
    } else {
      print('Failed to fetch data: ${response.reasonPhrase}');
    }
  }
@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // Handle back button press here, if needed
      // Return true if the screen can be popped, or false otherwise

      // Navigate to LevelListScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(token: widget.token)),
      );

      // Return false to prevent the screen from being popped immediately
      return false;
    },
    child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 121, 14, 170),
          title: const Text('Brainobrain Dictation',
              style: TextStyle(fontSize: 18, color: Colors.white)),
              leading: IconButton(
  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
  onPressed: () {
    Navigator.pop(context); // This pops the current screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(token: widget.token)),
    );
  },
),

          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0,3,7,3),
              child: IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 31),
                onPressed: () {
                     Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(token:widget.token,)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
       // color: Color.fromARGB(236, 223, 222, 222), // Set the background color of the outer Container to red
        child: Column(
          children: [
            Container(
              height: 30,
              color: const Color.fromARGB(236, 223, 222, 222),
              child: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Practices >",
                      style: TextStyle(
                        color:  Color.fromARGB(255, 50, 136, 158),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                        width: 2), // Add some spacing between "Practices" and "Levels"
                    Text(
                      "Levels",
                      style: TextStyle(
                        color: Color.fromARGB(255, 4, 84, 104),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];

                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color.fromARGB(255, 59, 17, 212),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 4.0,
                      child: SizedBox(
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            title: Text(
      level.name,
      style: const TextStyle(
        // Add your desired text style properties here
        fontWeight: FontWeight.bold,
        fontSize: 24.0,color: Colors.black,
        fontFamily: 'FontStyle.italic', 
        // Add more styling properties as needed
      ),
    ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                       MyAPIScreen(levelId: level.id, levelName: level.name,token: widget.token, name: '',   ),
                                      
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}






