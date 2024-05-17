//=======
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:s/Widgets/numpad.dart';
import '../Result/result.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'section_list_screen.dart';
//import '../Widgets/numpad.dart';

class NextScreen extends StatefulWidget {
  final String selectedId;
  final String selectedName;
  final String levelId;
  final String levelName;
  final String type;
  final String token;
  final int currentSliderValue;
  final Map<String, dynamic> preferences;

  NextScreen({
    required this.selectedId,
    required this.selectedName,
    required this.levelName,
    required this.type,
    required this.token,
    required sectionId,
    required this.levelId,
    required this.currentSliderValue,
    required this.preferences,
  });

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> with TickerProviderStateMixin {
  Future<Map<String, dynamic>>? apiData;
  List<int> answers = [];
  int currentQuestionIndex = 0;
  Timer? countdownTimer;
  int remainingTime = 10;
  String temporaryAnswer = '';
  String answer = '';
  int _seconds = 0;
  late Timer _timer;
  late CountDownController _controller;
  bool isTimerCompleted = false;
  double progress = 0.0;
  int maxDigits = 0;

  String get formattedTimer {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  get _currentSliderValue => _currentSliderValue;
  @override
  void initState() {
    super.initState();
    _controller = CountDownController();

    print('Current Slider it: ${widget.currentSliderValue}');
    _controller.start();

    apiData = fetchAndDisplayResponse();
    print('Preferences in saro: ${widget.preferences}');
    print('max_digits in NextScreen: ${widget.preferences['max_digits']}');
    apiData?.then((data) {
      decide();
    });
    //startCountdown();
    _startTimer();

    print('Section ID: ${widget.selectedId}');
    print('LevelName: ${widget.levelName}');
    print('Section Type: ${widget.type}');
  }

  Future<Map<String, dynamic>> fetchAndDisplayResponse() async {
    final String baseUrl = 'https://bob-fms.trainingzone.in';
    final String endpoint =
        '/api/practice/${widget.levelId}/${widget.selectedId}';
    final String authToken = 'Bearer ${widget.token}';
    final Uri uri = Uri.parse('$baseUrl$endpoint');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authToken,
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedData = json.decode(response.body);
        print('API Response: $parsedData');

        final answers = List<String>.from(parsedData['data'].map(
          (item) => item['answers'][0].toString(),
        ));

        for (int i = 0; i < answers.length; i++) {
          print('Answer for Question $i: ${answers[i]}');
        }

        return parsedData;
      } else {
        throw Exception(
            'Failed with status code: ${response.statusCode}\nReason phrase: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < 9) {
      setState(() {
        currentQuestionIndex++;
        temporaryAnswer = '';

        // Calculate progress as a percentage
        progress = (currentQuestionIndex + 1) / 10.0;

        if (widget.type == 'Flash Cards') {
          _controller.restart(duration: widget.currentSliderValue + 1);
          remainingTime = widget.currentSliderValue.toInt();
        } else {
          _controller.restart(duration: 20);
          remainingTime = 20;
        }
      });
    } else {
      print('All questions are completed.');
      countdownTimer?.cancel();
    }
  }

  void showEnterAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: 130.0,
            width: 60.0,
            child: Column(
              children: [
                const ListTile(
                  title: Text(
                    'Please Enter Answer!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 30.0,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0), // Adjust spacing as needed
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(
                        30.0, 10.0), // Adjust width and height as needed
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void ValidAnswerDialoge() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: 130.0,
            width: 60.0,
            child: Column(
              children: [
                const ListTile(
                  title: Text(
                    'Please Enter Valid Answer!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  leading: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 30.0,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0), // Adjust spacing as needed
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(
                        30.0, 10.0), // Adjust width and height as needed
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void handleBackspace() {
    if (temporaryAnswer.isNotEmpty) {
      setState(() {
        temporaryAnswer =
            temporaryAnswer.substring(0, temporaryAnswer.length - 1);
      });
    }
  }

  int correctAnswerCount = 0;

  void handleSubmit() {
    isTimerCompleted = false;

    print('Temporary Answer before condition: $temporaryAnswer');

    if (temporaryAnswer.trim() == "0" ||
        temporaryAnswer.trim() == "00" ||
        temporaryAnswer.trim() == "000" ||
        temporaryAnswer.trim() == "0000" ||
        temporaryAnswer.trim() == "00000" ||
        temporaryAnswer.trim() == "0") {
      ValidAnswerDialoge();
    } else if (temporaryAnswer.isNotEmpty) {
      apiData?.then((data) {
        final currentQuestionData = data['data'][currentQuestionIndex];
        final correctAnswer = currentQuestionData['answers'][0];

        print('Temporary Answer: $temporaryAnswer');
        print('Answer: $correctAnswer');

        if (temporaryAnswer == correctAnswer.toString()) {
          answers.add(currentQuestionIndex);
          correctAnswerCount++;
        }

        answer = '';
        temporaryAnswer = '';

        if (currentQuestionIndex < 9) {
          moveToNextQuestion();
        } else {
          print('All questions are completed.');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ResultScreen(
              correctAnswerCount: answers.length,
              formattedTimer: formattedTimer,
              answers: [],
              selectedId: widget.selectedId,
              levelId: widget.levelId,
              sectionId: '',
              token: widget.token,
              levelName: widget.levelName,
              type: widget.type,
              currentSliderValue: widget.currentSliderValue,
              preferences: widget.preferences,
            ),
          ));
          countdownTimer?.cancel();
          print('Total correct answers: $correctAnswerCount');
          print('Time taken: $formattedTimer');
          if (answers.length == 10) {
            print('All questions are answered correctly!');
          } else {
            print('Some questions are not answered correctly.');
          }
        }
      });
    } else {
      showEnterAnswerDialog();
    }
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool shouldDisableBackButton() {
    // Add your condition logic here
    // For example, if you want to disable the back button in a certain case, return true
    // Otherwise, return false
    return true; // Replace with your actual condition
  }

  @override
  Widget build(BuildContext context) {
    // print('Preferences in saro: ${widget.preferences}');
    // print('max_digits in NextScreen: ${widget.preferences['max_digits']}');

    // return
    if (widget.preferences.containsKey('max_digits')) {
      dynamic maxDigitsValue = widget.preferences['max_digits'];
      if (maxDigitsValue is int) {
        maxDigits = maxDigitsValue;
      } else if (maxDigitsValue is String) {
        try {
          maxDigits = int.parse(maxDigitsValue);
        } catch (e) {
          print('Invalid max_digits value in preferences');
          print('max_digits in NextScreen: $maxDigitsValue');
          // Handle the error or provide a default value for maxDigits
          maxDigits = 2;
        }
      } else {
        print('Invalid max_digits value in preferences');
        print('max_digits in NextScreen: $maxDigitsValue');
        // Handle the error or provide a default value for maxDigits
        maxDigits = 2;
      }
    } else {
      print('max_digits key not found in preferences');
      // Handle the error or provide a default value for maxDigits
      maxDigits = 2;
    }

    return WillPopScope(
      onWillPop: () async {
        if (shouldDisableBackButton()) {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyAPIScreen(
                levelId: widget.levelId,
                levelName: widget.levelName,
                token: widget.token,
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
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 121, 14, 170),
          title: const Center(
            child: Text(
              'Brainobrain',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
            onPressed: () {
              // Pop the current screen
              Navigator.of(context).pop();

              // Navigate to MyAPIScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyAPIScreen(
                    levelId: widget.levelId,
                    levelName: widget.levelName,
                    token: widget.token,
                    name: '',
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 13, 5),
                child: Row(
                  children: [
                    Lottie.asset(
                      'assets/3.json',
                    ),
                    const SizedBox(width: 0),
                    Text(
                      '$formattedTimer',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                        widget.type,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 4, 84, 104),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              buildQuestionInfo(),
              LinearIndicator(),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: decide(),
              ),
              //buildQuestionView(),

              buildAnswerInput(),
              buildAnswerPad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget decide() {
    return FutureBuilder<Map<String, dynamic>>(
      future: apiData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data != null) {
            return decideSection(widget.type, snapshot.data!);
          } else {
            return Text('No data available');
          }
        } else {
          // Handle other connection states
          return Container();
        }
      },
    );
  }

  Widget decideSection(String sectionType, Map<String, dynamic> data) {
    if (sectionType == 'Flash Cards') {
      return flash(data);
    } else {
      return buildQuestionView();
    }
  }

  Widget flash(Map<String, dynamic> data) {
    final currentQuestionData = data['data'][currentQuestionIndex];
    final correctAnswer = currentQuestionData['answers'][0];
    // final correctAnswer = 12345;
    print('value : $correctAnswer');
    return Container(
      padding: const EdgeInsets.fromLTRB(50, 10, 10, 0),
      height: 260,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 218, 228, 233),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      child: DiamondWidget(
        correctAnswer: correctAnswer,
        selectedId: widget.selectedId,
      ),
    );
  }

  Widget buildQuestionInfo() {
    return FutureBuilder<Map<String, dynamic>>(
      future: apiData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text('No questions available');
        } else {
          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center the items vertically
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                child: Container(
                  height: 50,
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1} of 10',
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 49,
              ),
              CircularCountDownTimer(
                duration: (widget.type == 'Flash Cards')
                    ? widget.currentSliderValue + 1
                    : 20,
                controller: _controller,
                width: 30,
                height: 30,
                ringColor: Colors.transparent,
                fillColor: Colors.red,
                strokeWidth: 5.0,
                textStyle: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                isReverse: true,
                isReverseAnimation: true,
                onComplete: () {
                  setState(() {
                    isTimerCompleted = true;
                  });
                  if (temporaryAnswer.isEmpty) {
                    showEnterAnswerDialog();
                  } else {
                    handleSubmit();
                  }
                },
              )
            ],
          );
        }
      },
    );
  }

  Widget LinearIndicator() {
    return Container(
      height: 10, // Adjust the height as needed
      width: 370, // Adjust the width as needed
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(5), // Adjust the border radius as needed
        border: Border.all(color: Colors.blue), // Set the border color to blue
      ),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor:
            Colors.transparent, // Set the background color to transparent
        valueColor: AlwaysStoppedAnimation<Color>(
            Colors.blue), // Set the value color to blue
      ),
    );
  }

  Widget buildQuestionView() {
    return
        //Padding(
        //    padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
        // child:
        Container(
      height: 260,
      child: FutureBuilder<Map<String, dynamic>>(
        future: apiData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return   CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No questions available'));
          } else {
            final data = snapshot.data!;
            final questionList = List<List<String>>.from(
              data['data'].map(
                (item) => List<String>.from(item['question']),
              ),
            );

            final currentQuestion = questionList[currentQuestionIndex];

            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: buildQuestionGridView(currentQuestion),
            );
          }
        },
      ),
    );
  }

  //=====
  Widget buildQuestionGridView(List<String> currentQuestions) {
    bool isMultiplicationSection = widget.type == 'Multiplication';
    bool isDivisionSection = widget.type == 'Division';

    if (isDivisionSection) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
        ),
        itemCount: currentQuestions.length,
        itemBuilder: (context, index) {
          if (index == 1) {
            return Container();
          } else if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 75),
              child: Container(
                width: 20,
                height: 5,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 50),
                      children: [
                        TextSpan(
                          text: '${int.tryParse(currentQuestions[0]) ?? 0}',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 12, 96, 165)),
                        ),
                        const TextSpan(
                          text: '  / ',
                          style:
                              TextStyle(color: Color.fromARGB(255, 170, 17, 6)),
                        ),
                        TextSpan(
                          text: '${int.tryParse(currentQuestions[1]) ?? 0}',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 23, 129, 9)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      );
    }

    if (isMultiplicationSection) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
        ),
        itemCount: currentQuestions.length,
        itemBuilder: (context, index) {
          if (index == 1) {
            return Container();
          } else if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 75),
              child: Container(
                width: 20,
                height: 5,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 50),
                      children: [
                        TextSpan(
                          text: '${int.tryParse(currentQuestions[0]) ?? 0}',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 12, 96, 165)),
                        ),
                        const TextSpan(
                          text: '  * ',
                          style:
                              TextStyle(color: Color.fromARGB(255, 170, 17, 6)),
                        ),
                        TextSpan(
                          text: '${int.tryParse(currentQuestions[1]) ?? 0}',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 23, 129, 9)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      );
    }

    int rowCount = ((currentQuestions.length - 1) / 5).floor() + 1;

    return ListView(
      //  scrollDirection: Axis.vertical,
      children: List.generate(
        5,
        (columnIndex) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              rowCount,
              (rowIndex) {
                int questionIndex = columnIndex + rowIndex * 5;

                if (questionIndex < currentQuestions.length) {
                  int questionNumber =
                      int.tryParse(currentQuestions[questionIndex]) ?? 0;

                  String displayText = questionNumber < 0
                      ? '$questionNumber'
                      : '  $questionNumber';

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(50, 15, 0, 15),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayText,
                        style: GoogleFonts.dancingScript(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color:
                                questionNumber < 0 ? Colors.red : Colors.black,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildAnswerInput() {
    return const SizedBox(
      height: 0,
    );
  }

  Widget buildAnswerPad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    width: 240,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          temporaryAnswer,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 54, 10, 156),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                ElevatedButton(
                  onPressed: handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    minimumSize: Size(0, 50),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: NumberPad(
            onTap: (value) {
              if (value == 'backspace') {
                handleBackspace();
              } else {
                setState(() {
                  // Ensure that the total number of digits doesn't exceed the specified maximum
                  //int maxDigits = {widget.preferences['max_digits']} as int;
                  if (temporaryAnswer.length < maxDigits) {
                    temporaryAnswer += value;
                    print('maxDigits: $maxDigits');
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

class DiamondPage extends StatelessWidget {
  final int correctAnswer;
  final String selectedId;

  DiamondPage({
    required this.correctAnswer,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DiamondWidget(
        correctAnswer: correctAnswer,
        selectedId: selectedId,
      ),
    );
  }
}

class DiamondWidget extends StatefulWidget {
  final int correctAnswer;
  final String selectedId;

  DiamondWidget({
    required this.correctAnswer,
    required this.selectedId,
  });

  @override
  _DiamondWidgetState createState() => _DiamondWidgetState();
}

class _DiamondWidgetState extends State<DiamondWidget> {
  late List<int> tops;
  late List<int> bottoms;
  final double initialPosition = 145.0;

  @override
  void initState() {
    super.initState();
    _calculateTopsAndBottoms();
  }

  @override
  void didUpdateWidget(covariant DiamondWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.correctAnswer != widget.correctAnswer) {
      _calculateTopsAndBottoms();
    }
  }

  void _calculateTopsAndBottoms() {
    List<int> digits = splitNumberIntoDigits(widget.correctAnswer);

    setState(() {
      tops = [];
      bottoms = [];
      for (int digit in digits) {
        int top = digit != 5 ? digit - 5 : 0;
        int bottom = digit;
        tops.add(top);
        bottoms.add(bottom);
      }
    });
  }

  Widget createCircularContainer() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxDiamondTop = 0.0;
    List<Widget> diamonds = _buildDiamonds((diamondTop) {
      if (diamondTop > maxDiamondTop) {
        maxDiamondTop = diamondTop;
      }
    }); // Track the maximum diamondTop

    return Stack(
      children: [
        Positioned(
          top: 59,
          left: 11,
          bottom: 180,
          right: widget.selectedId == 'RXBVXyWkJ2'
              ? 195 // Adjust the value as needed
              : (widget.selectedId == 'vwEVOQL0qN'
                  ? 150
                  : (widget.selectedId == 'E8wm5emAz2'
                      ? 95
                      : (widget.selectedId == 'b1pmPgL7NX' ? 50 : 0))),
          child: Container(
            color: Colors.black,
            height: 1,
            width: 20,
            child: Stack(
              children: [
                SizedBox(
                  width: 57,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: widget.selectedId == 'vwEVOQL0qN'
                          ? BoxShape.circle
                          : BoxShape.circle, // Corrected this line
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.selectedId == 'vwEVOQL0qN')
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(72, 0, 0, 0),
                      child: createCircularContainer(),
                    ),
                  ),
                if (widget.selectedId == 'E8wm5emAz2')
                  SizedBox(
                    width: 400,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(72, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                      ],
                    ),
                  ),
                if (widget.selectedId == 'b1pmPgL7NX')
                  SizedBox(
                    width: 400,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(72, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                      ],
                    ),
                  ),
                if (widget.selectedId == 'xedLzBL2QE')
                  SizedBox(
                    width: 400,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(72, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: createCircularContainer(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Use the diamonds list
        ...diamonds,
      ],
    );
  }

  List<Widget> _buildDiamonds(void Function(double) updateMaxDiamondTop) {
    List<Widget> diamonds = [];

    for (int i = 0; i < bottoms.length; i++) {
      int top = tops[i];
      int bottom = bottoms[i];

      int loopRange = top < 0 ? bottom.abs() : top.abs() + 1;

      for (int j = 0; j < loopRange; j++) {
        double diamondTop = top < 0
            ? initialPosition - 100.0 + j * 40.0 // Adjust the value as needed
            : initialPosition - 145.0 + j * 45.0;
        // : initialPosition + j * 45.0; // Adjust the value as needed

        updateMaxDiamondTop(diamondTop);

        // Decrease the distance between columns by adjusting the left position
        double diamondLeft = i * 50.0; // Adjust the value as needed

        diamonds.add(
          Positioned(
            top: diamondTop,
            left: diamondLeft,
            child: Container(
              width: 40.0,
              height: 40.0,
              child: CustomPaint(
                painter: DiamondPainter(),
              ),
            ),
          ),
        );
      }
    }
    return diamonds;
  }
}

class DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.brown;
    Path path = Path();

    double centerX = size.width / 2;
    double centerY = size.height / 2;

    path.moveTo(centerX, 0);
    path.lineTo(size.width, centerY);
    path.lineTo(centerX, size.height);
    path.lineTo(0, centerY);
    path.close();

    canvas.translate(centerX, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

List<int> splitNumberIntoDigits(int number) {
  List<int> digits = [];

  while (number > 0) {
    digits.add(number % 10);
    number ~/= 10;
  }

  digits = digits.reversed.toList();

  return digits;
}
