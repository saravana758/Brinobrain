import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:s/levels/oral.dart';
//import 'package:s/levels/level_3.dart';
//import 'package:s/levels/oral.dart';

import '../home/home_screen.dart';
import '../levels/section_list_screen.dart';
//import '../levels/level_3.dart';

class oralResultScreen extends StatelessWidget {
  final int correctAnswerCount;
  final String formattedTimer;
  final String selectedId;
  final String levelId;
  final String sectionId;
  final String token;
  final String levelName;
  final String type;
  final int currentSliderValue;
  final Map<String, dynamic> preferences;

  oralResultScreen({
    required this.correctAnswerCount,
    required this.selectedId,
    required this.sectionId,
    required this.levelId,
    required this.formattedTimer,
    required this.levelName, // Add this parameter
    required this.type,
    required List<int> answers,
    required this.token,
    required this.currentSliderValue,
      required this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (shouldDisableBackButton()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyAPIScreen(
                levelId: levelId,
                levelName: levelName,
                token: token,
                name: '',
              ),
            ),
          );
          return false; // Don't allow popping the screen
        } else {
          return true; // Allow popping the screen
        }
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: buildBody(context),
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56),
      child: AppBar(
        backgroundColor: Color(0xFF791EAA),
        title: Text(
          'Brainobrain Dictation',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyAPIScreen(
                  levelId: levelId,
                  levelName: levelName,
                  token: token,
                  name: '',
                ), // Replace MyAPIScreen with the actual screen you want to navigate to
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 3, 7, 3),
            child: IconButton(
              icon: Icon(Icons.home, color: Colors.white, size: 31),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(token: token),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool shouldDisableBackButton() {
    // Add your condition logic here
    // For example, if you want to disable the back button in a certain case, return true
    // Otherwise, return false
    return true; // Replace with your actual condition
  }

  Widget buildBody(BuildContext context) {
    String resultText = getResultText(correctAnswerCount);

    return Column(
      children: [
        buildPracticeHeader(),
        SizedBox(height: 20),
        buildResultContainer(resultText, context),
        SizedBox(
          height: 10,
        ),
        logo(),
      ],
    );
  }

  Widget logo() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Image.asset(
        'assets/5.png',
        width: 180,
        height: 150,
      ),
    );
  }

  Widget buildPracticeHeader() {
    return Container(
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
              levelName,
              style: const TextStyle(
                color: Color.fromARGB(255, 50, 136, 158),
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              '>',
              style: TextStyle(
                color: Color.fromARGB(255, 50, 136, 158),
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              type,
              style: const TextStyle(
                color: Color.fromARGB(255, 4, 84, 104),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultContainer(String resultText, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          Container(
            height: 350,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 3.0,
              ),
            ),
            child: Stack(
              children: [
                buildTimeWidget(),
                buildCenterLottieWidget(),
                buildBottomText(resultText),
                buildTryAgainButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeWidget() {
    return Align(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 60),
            child: Text(
              'Time taken: $formattedTimer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCenterLottieWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(70, 0, 0, 70),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (correctAnswerCount >= 9)
                  Lottie.asset(
                    'assets/celebrate.json',
                    fit: BoxFit.contain,
                  ),
                Image.asset(
                  'assets/rond.png',
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Positioned(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$correctAnswerCount',
                  style: TextStyle(
                    color: Color.fromARGB(255, 248, 4, 4),
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Out of 10',
                  style: TextStyle(
                    color: Color.fromARGB(255, 13, 14, 0),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomText(String resultText) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 50,
        color: Color.fromARGB(255, 235, 198, 243),
        child: Center(
          child: Text(
            resultText,
            style: TextStyle(
              color: Color.fromARGB(255, 153, 127, 127),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTryAgainButton(BuildContext context) {
    // Only show the "Try Again" button if correctAnswerCount is less than 9
    if (correctAnswerCount < 9) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(100, 224, 4, 4),
        child: ElevatedButton(
          onPressed: () {
            _postDataAndNavigate1(context);
          },
          child: Text('Try Again'),
        ),
      );
    } else {
      // If correctAnswerCount is 9 or 10, return an empty container
      return Container();
    }
  }

  String getResultText(int correctAnswerCount) {
    if (correctAnswerCount >= 0 && correctAnswerCount <= 5) {
      return "Speak with your teacher";
    } else if (correctAnswerCount >= 6 && correctAnswerCount <= 8) {
      return "Good";
    } else if (correctAnswerCount >= 9 && correctAnswerCount <= 10) {
      return "Excellent";
    } else {
      return "Invalid count"; // You can customize this as needed
    }
  }

  Future<void> _postDataAndNavigate(BuildContext context) async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token}',
    };
    var url = Uri.parse(
        'https://bob-fms.trainingzone.in/api/practice/$levelId/$selectedId/store-stats');
    var request = http.Request('POST', url);
    request.body =
        json.encode({"email": "student1@mail.com", "password": "Test@123"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      print(responseBody);

      Navigator.pop(context);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> _postDataAndNavigate1(BuildContext context) async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token}',
    };

    var url = Uri.parse(
        'https://bob-fms.trainingzone.in/api/practice/$levelId/$selectedId/store-stats');
    var request = http.Request('POST', url);
    request.body = json.encode({
      "email": "student1@mail.com",
      "password": "Test@123",
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      print(responseBody); // Print the response

      // Update the existing instance of ResultScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OralScreen(
            // Reset correct answer count
            selectedId: selectedId,
            sectionId: sectionId,
            levelId: levelId, selectedName: '',
            token: token,
            levelName: levelName,
            type: type, currentSliderValue: currentSliderValue,preferences: preferences
          ),
        ),
      );
    } else {
      print(response.reasonPhrase);
      // Handle the error or show an error message
    }
  }
}
