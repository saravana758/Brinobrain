import 'dart:convert';
// import 'dart:ffi';
//import 'package:bob_dictation_flutter/levels/oral_screen.dart';
//import 'package:bob_dictation_flutter/levels/visual_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:s/levels/Level_list_screen.dart';
import 'package:s/levels/doubling.dart';
import 'package:s/levels/oral.dart';

import '../home/home_screen.dart';
import 'level_3.dart';
//import 'oral.dart';

class MyAPIScreen extends StatefulWidget {
  final String levelId;
  final String levelName;
  final String token;
  final String name;
  MyAPIScreen(
      {required this.levelId,
      required this.levelName,
      required this.token,
      required this.name});

  @override
  _MyAPIScreenState createState() => _MyAPIScreenState();
}

class _MyAPIScreenState extends State<MyAPIScreen> {
  List<dynamic> apiData = [];
  bool isLoading = true;
  bool visualEnabled = true;
  bool oralEnabled = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
    //  bool visualEnabled = true;
  }

  Future<void> fetchDataFromAPI() async {
    print(widget.levelId);
    print('Token: ${widget.token}');
    try {
      final response = await http.get(
        Uri.parse(
          'https://bob-fms.trainingzone.in/api/practice/${widget.levelId}/sections',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)["data"];
        print('shakila');
        print(jsonData);

        // Manually add 'Doubling' section for Level 10
        if (widget.levelId == 'wzVMQnjAWZ') {
          jsonData.add({
            "id":
                "customDoublingId", // Provide a unique ID for the custom section
            "name": "Doubling",
            "type": "Double the number", // You can adjust the type as needed
            "preferences": {
              "max_value": "999",
              "min_value": "1",
              "max_digits": "2",
              "time_slider": "1",
              "time_slider_ends_at": "3",
              "time_slider_start_at": "0.5",
              "time_slider_increment": "0.5",
              "visual": false,
              "oral": false
            }
          });
        }

        setState(() {
          apiData = jsonData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void handleItemClick(String id, String name) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContent(
          sectionId: id,
          levelId: widget.levelId,
          token: widget.token,
          levelName: widget.levelName,
          onActionButtonPressed: () {},
        );
      },
    );
  }

  Widget buildSectionItem(Map<String, dynamic> section) {
    bool isLevel10 = widget.levelId == 'wzVMQnjAWZ';
    return Container(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 7, 7, 7),
            child: Lottie.asset('assets/back.json',
                width: 340, height: 78, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 0, 5),
            child: ListTile(
              title: Text(
                section['name'],
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                section['type'],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          if (isLevel10 && section['name'] == 'Doubling')
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 5),
              child: ListTile(
                title: Text(
                  'Doubling',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
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
            MaterialPageRoute(
                builder: (context) => LevelListScreen(token: widget.token)),
          );

          // Return false to prevent the screen from being popped immediately
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 121, 14, 170),
            title: const Text(
              'Brainobrain Dictation',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context); // This pops the current screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LevelListScreen(
                            token: widget.token,
                          )),
                );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 7, 3),
                child: IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 31),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(
                                token: widget.token,
                              )),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                height: 30,
                color: const Color.fromARGB(236, 223, 222, 222),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Practices >",
                        style: TextStyle(
                          color: Color.fromARGB(255, 50, 136, 158),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.levelName,
                        style: const TextStyle(
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
                itemCount: apiData.length,
                itemBuilder: (context, index) {
                  final section = apiData[index];
                  return GestureDetector(
                    onTap: () {
                      if (section['name'] != 'Doubling') {
                        handleItemClick(section['id'], section['name']);
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Doubling(
                                      token: widget.token,
                                    )));
                        // DoublingQuiz()));
                      }
                    },
                    child: buildSectionItem(section),
                  );
                },
              )),
            ],
          ),
        ));
  }
}

class BottomSheetContent extends StatefulWidget {
  final String sectionId;
  final String levelId;
  final String token;
  final String levelName;
  final VoidCallback onActionButtonPressed;

  BottomSheetContent({
    required this.sectionId,
    required this.levelId,
    required this.token,
    required this.levelName,
    required this.onActionButtonPressed,
  });

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  Map<String, dynamic> sectionData = {};
  bool isLoading = true;
  bool visualEnabled = true;
  bool oralEnabled = false;
  int _currentSliderValue = 0; // Changed to int
  
  Map<String, dynamic> preferences = {};

  @override
  void initState() {
    super.initState();
    fetchDataForSection();
  }

  Future<void> fetchDataForSection() async {
    print(widget.sectionId);
    try {
      final response = await http.get(
        Uri.parse(
          'https://bob-fms.trainingzone.in/api/practice/${widget.levelId}/${widget.sectionId}/new',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        print("Level Name: ${widget.levelName}");
        print('Token: ${widget.token}');

        final jsonData = json.decode(response.body);

        if (jsonData.containsKey('data')) {
          final data = jsonData['data'];
          if (data.containsKey('section')) {
            final section = data['section'];
            if (section.containsKey('type')) {
              final type = section['type'];
              print('Type: $type');
            

            }
            if (section.containsKey('preferences')) {
              preferences = section['preferences'];
              print('Preferences ok : $preferences');

              if (oralEnabled &&
                  preferences.containsKey('time_slider') &&
                  preferences['time_slider'] == true) {
                print(
                    'Time Slider Min: ${preferences['time_slider_start_at']}');
                print('Time Slider Max: ${preferences['time_slider_ends_at']}');
                print(
                    'Time Slider Increment: ${preferences['time_slider_increment']}');
              }

              if (oralEnabled) {
                print('Max Value: ${preferences['max_value']}');
                print('Min Value: ${preferences['min_value']}');
                print('Max Digits: ${preferences['max_digits']}');
              }
            }
          }
        }

        if (jsonData['visualEnabled'] == true) {
          setState(() {
            visualEnabled = true;
          });
        }
        if (jsonData['oralEnabled'] == true) {
          setState(() {
            oralEnabled = true;
          });
        }

        if (oralEnabled &&
            preferences.containsKey('time_slider') &&
            preferences['time_slider'] == true &&
            preferences['time_slider_start_at'] !=
                preferences['time_slider_ends_at']) {
          setState(() {
            _currentSliderValue =
                int.parse(preferences['time_slider_start_at']);
          });
        } else {
          // Set the time slider to 3 seconds if start and end timers are the same
          setState(() {
            _currentSliderValue = 3; // Changed to int
          });
        }

        setState(() {
          sectionData = jsonData;
          isLoading = false;
        });
      } else {
        print('Failed to load data from the API: ${response.body}');
      }
    } catch (e) {
      print('Error fetching data from the API: $e');
    }
  }

 @override
Widget build(BuildContext context) {
  return OrientationBuilder(
    builder: (context, orientation) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: Container(
                  decoration: BoxDecoration(
                    color: visualEnabled ? Colors.blue : Colors.grey,
                    border: Border.all(
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        visualEnabled = true;
                        oralEnabled = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: orientation == Orientation.portrait
                            ? 20
                            : 30,
                        vertical: 5,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          color: Colors.white,
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Visual',
                          style: TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Visibility(
                visible: sectionData.containsKey('data') &&
                    sectionData['data']['section']
                        .containsKey('type') &&
                    sectionData['data']['section']['type'] !=
                        "Flash Cards",
                child: Container(
                  decoration: BoxDecoration(
                    color: oralEnabled ? Colors.blue : Colors.grey,
                    border: Border.all(
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        visualEnabled = false;
                        oralEnabled = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: orientation == Orientation.portrait
                            ? 27
                            : 40,
                        vertical: 5,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.mic,
                          color: Colors.white,
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Oral',
                          style: TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                children: [
                  if (oralEnabled)
                    Slider(
                      value: _currentSliderValue.toDouble(),
                      min: double.parse(
                          preferences['time_slider_start_at']),
                      max: double.parse(
                          preferences['time_slider_ends_at']),
                      divisions: (double.parse(preferences[
                                  'time_slider_increment']) >
                              0)
                          ? (((double.parse(preferences[
                                          'time_slider_ends_at']) -
                                      double.parse(preferences[
                                          'time_slider_start_at'])) /
                                  double.parse(preferences[
                                      'time_slider_increment']))
                              .ceil()
                              .clamp(1, double.infinity)
                              .toInt())
                          : null,
                      onChanged: (double value) {
                        setState(() {
                          double step = double.parse(
                              preferences['time_slider_increment']);
                          int steps = ((value -
                                      double.parse(preferences[
                                          'time_slider_start_at'])) /
                                  step)
                              .round();
                          double newValue = double.parse(
                                  preferences['time_slider_start_at']) +
                              steps * step;

                          _currentSliderValue = newValue
                              .clamp(
                                double.parse(preferences[
                                    'time_slider_start_at']),
                                double.parse(
                                    preferences['time_slider_ends_at']),
                              )
                              .toInt();

                          print(
                              'Current Slider Value: $_currentSliderValue');
                              
                        });
                      },
                    ),
                  if ((visualEnabled &&
                      sectionData.containsKey('data') &&
                      sectionData['data']['section']
                          .containsKey('type') &&
                      sectionData['data']['section']['type'] ==
                          "Flash Cards"))
                    Slider(
                      value: _currentSliderValue.toDouble(),
                      min: double.parse(
                          preferences['time_slider_start_at']),
                      max: double.parse(
                          preferences['time_slider_ends_at']),
                      divisions: (double.parse(preferences[
                                  'time_slider_increment']) >
                              0)
                          ? (((double.parse(preferences[
                                          'time_slider_ends_at']) -
                                      double.parse(preferences[
                                          'time_slider_start_at'])) /
                                  double.parse(preferences[
                                      'time_slider_increment']))
                              .ceil()
                              .clamp(1, double.infinity)
                              .toInt())
                          : null,
                      onChanged: (double value) {
                        setState(() {
                          double step = double.parse(
                              preferences['time_slider_increment']);
                          int steps = ((value -
                                      double.parse(preferences[
                                          'time_slider_start_at'])) /
                                  step)
                              .round();
                          double newValue = double.parse(
                                  preferences['time_slider_start_at']) +
                              steps * step;

                          _currentSliderValue = newValue
                              .clamp(
                                double.parse(preferences[
                                    'time_slider_start_at']),
                                double.parse(
                                    preferences['time_slider_ends_at']),
                              )
                              .toInt();

                          print(
                              'Current Slider Value: $_currentSliderValue');
                        });
                      },
                    ),
                  Visibility(
                    visible: oralEnabled,
                    child: Visibility(
                      visible: !(sectionData.containsKey('data') &&
                          sectionData['data']['section']
                              .containsKey('type') &&
                          sectionData['data']['section']['type'] ==
                              "Flash Cards"),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'Time : ',
                            ),
                            TextSpan(
                              text: '$_currentSliderValue secs',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: visualEnabled,
                    child: Visibility(
                      visible: ((visualEnabled &&
                          sectionData.containsKey('data') &&
                          sectionData['data']['section']
                              .containsKey('type') &&
                          sectionData['data']['section']['type'] ==
                              "Flash Cards")),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'Time : ',
                            ),
                            TextSpan(
                              text: '$_currentSliderValue secs',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                height: 50,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 36, 19, 118),
                      width: 3.0),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: InkWell(
                  onTap: () {
                    if (visualEnabled) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NextScreen(
                            selectedId: widget.sectionId,
                            selectedName: widget.levelName,
                            currentSliderValue: _currentSliderValue,
                            token: widget.token,
                            sectionId: null,
                            levelId: widget.levelId,
                            levelName: widget.levelName,
                            type: sectionData.containsKey('data') &&
                                    sectionData['data']['section']
                                        .containsKey('type')
                                ? sectionData['data']['section']['type']
                                : 'DefaultType', preferences: preferences,
                          ),
                        ),
                      );
                    } else if (oralEnabled) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OralScreen(
                            selectedId: widget.sectionId,
                            selectedName: widget.levelName,
                            levelId: widget.levelId,
                            levelName: widget.levelName,
                            type: sectionData.containsKey('data') &&
                                    sectionData['data']['section']
                                        .containsKey('type')
                                ? sectionData['data']['section']['type']
                                : 'DefaultType',
                            sectionId: '',
                            token: widget.token,
                            currentSliderValue: _currentSliderValue, preferences: preferences,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.play_arrow,
                        color: Color.fromARGB(255, 36, 19, 118),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Start',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 36, 19, 118)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      );
    },
  );
}

}
