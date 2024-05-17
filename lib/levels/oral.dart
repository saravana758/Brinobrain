import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import '../Result/result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:s/Result/oralresult.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'section_list_screen.dart';

class OralScreen extends StatefulWidget {
  final String selectedId;
  final String selectedName;
  final String levelId;
  final String levelName;
  final String type;
  final String token;
  final int currentSliderValue;
  final Map<String, dynamic> preferences;

  OralScreen(
      {required this.selectedId,
      required this.selectedName,
      required this.levelName,
      required this.type,
      required sectionId,
      required this.levelId,
      required this.token,
      required this.preferences,
      required this.currentSliderValue});

  @override
  _OralScreenState createState() => _OralScreenState();
}

class _OralScreenState extends State<OralScreen> with TickerProviderStateMixin {
  List<List<String>> currentQuestion = [];
  TextEditingController _controller = TextEditingController();
  Future<Map<String, dynamic>>? apiData;

  List<int> answers = [];
  int currentQuestionIndex = 0;
  String temporaryAnswer = '';
  String answer = '';
  Timer? timer;
  int currentQuestionValue = 0;
  Timer? countdownTimer;
  late int remainingTime;
  FlutterTts flutterTts = FlutterTts();
  String previousValue = '';
  int _seconds = 0;
  String textToSpeak = '';
  bool hasSpoken = false;
  List<List<String>> questionList = [];
  late AnimationController _borderColorController;
  late Animation<Color?> _borderColorAnimation;
  String previousQues = "";
  bool hasSpokenMultiplication = false;
  bool hasSpokenDivision = false;
  String multiplicationExpression = '';
  String divisionExpression = '';
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

  set _timer(Timer _timer) {}

  @override
  void initState() {
    super.initState();
    print('Current Slider it: ${widget.currentSliderValue}');
    _borderColorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    remainingTime = widget.currentSliderValue;

    _borderColorAnimation = ColorTween(
      begin: Colors.blue, // Set the initial color
      end: Colors.red, // Set the final color
    ).animate(_borderColorController);

    _borderColorController.addListener(() {
      setState(() {}); // Update the UI when the animation value changes
    });
    _borderColorController.forward();
    apiData = fetchAndDisplayResponse();
    configureTts();
    con();
    _startTimer();
  }

  Future<void> configureTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts
        .setVoice('en-US-male-voice-variant' as Map<String, String>);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(1);
  }

  void con() {
    if (widget.type == "Multiplication") {
      multi(currentQuestion.cast<String>());
    } else if (widget.type == "Division") {
      division(currentQuestion.cast<String>());
    } else {
      startCountdown();
    }
  }

  void division(List<String> currentQuestion) {
    hasSpokenDivision = false;
    int tick = 0;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tick = timer.tick;
        remainingTime = (widget.currentSliderValue) - tick;
      });

      if (tick == 3) {
        timer.cancel();

        setState(() {
          remainingTime = widget.currentSliderValue;
        });

        if (widget.type == "Division") {
          if (!hasSpokenDivision) {
            hasSpokenDivision = true;
            print("Division Expression: $multiplicationExpression");
            speakText(divisionExpression);
          }
          showNumberPadDialog();
        } else {
          print("Tick is not 3. Current value: $tick");
        }
      }
    });
  }

  void multi(List<String> currentQuestion) {
    hasSpokenMultiplication = false;
    int tick = 0;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tick = timer.tick;
        remainingTime = (widget.currentSliderValue) - tick;
      });

      if (tick == 3) {
        timer.cancel();

        setState(() {
          remainingTime = widget.currentSliderValue;
        });

        if (widget.type == "Multiplication") {
          if (!hasSpokenMultiplication) {
            hasSpokenMultiplication = true;
            print("Multiplication Expression: $multiplicationExpression");
            speakText(multiplicationExpression);
          }
          showNumberPadDialog();
        } else {
          print("Tick is not 3. Current value: $tick");
        }
      }
    });
  }

  void startCountdown() {
    int tick = 0;
    bool hasSpokenOnce = false;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!hasSpokenOnce && currentQuestionValue == 0) {
        String textToSpeak = questionList[currentQuestionIndex][0];
        speakText(textToSpeak);
        hasSpokenOnce = true;
      }

      setState(() {
        tick = timer.tick;
        remainingTime = widget.currentSliderValue - tick;
      });

      if (tick == widget.currentSliderValue) {
        timer.cancel();

        setState(() {
          currentQuestionValue++;
          remainingTime = widget.currentSliderValue;
        });

        if (currentQuestionValue == questionList[currentQuestionIndex].length) {
          showNumberPadDialog();
        } else {
          String textToSpeak =
              questionList[currentQuestionIndex][currentQuestionValue];
          speakText(textToSpeak);

          if (currentQuestionValue > 0) {
            startCountdown();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _borderColorController.dispose();
    super.dispose();
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

        // Assuming 'data' is a list of questions in the API response

        return parsedData;
      } else {
        throw Exception(
            'Failed with status code: ${response.statusCode}\nReason phrase: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error: $e');
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

  void showNumberPadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors
                .transparent, // Set a transparent background for the AlertDialog
            content: Container(
              height: 500, // Adjust the height of the Container
              width: 300, // Adjust the width of the Container
              decoration: BoxDecoration(
                color: Colors.white, // Set background color for the Container
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 10), // Adjust content padding
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 90.0, // Adjust the height as needed
                    width: 230.0, // Adjust the width as needed
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 120, 184, 236),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        // labelText: "Enter an answer",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 233, 86, 157),
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          color: Color.fromARGB(255, 41, 7, 141),
                          fontSize: 33.0,
                          fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      textAlign:
                          TextAlign.center, // Align text horizontally center
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),

                  buildAnswerPad(), // Add the answer pad widget here
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumberButton("1"),
                      _buildNumberButton("2"),
                      _buildNumberButton("3"),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumberButton("4"),
                      _buildNumberButton("5"),
                      _buildNumberButton("6"),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumberButton("7"),
                      _buildNumberButton("8"),
                      _buildNumberButton("9"),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(70, 0, 0, 0),
                  //   child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumberButton(""),

                      _buildNumberButton("0"),
                      // const SizedBox(height: 2),

                      _buildNumberButton(const Icon(
                        Icons.backspace,
                        color: Colors.red,
                        size: 30,
                      )),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildNumberButton(dynamic child) {
    return TextButton(
      onPressed: () {
        _handleNumberButtonPress(child);
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
        textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      child: child is String
          ? Text(
              child,
              style: const TextStyle(
                  fontSize: 27.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )
          : child is Widget
              ? child
              : const SizedBox.shrink(),
    );
  }

  Widget _buildNumbberButton(String buttonText) {
    return ElevatedButton(
      onPressed: () {
        _handleNumberButtonPress(buttonText);
      },
      child: Text(buttonText),
    );
  }

  void _handleNumberButtonPress(dynamic value) {
    setState(() {
      if (value is String) {
        if (value == "backspace") {
          if (_controller.text.isNotEmpty) {
            _controller.text =
                _controller.text.substring(0, _controller.text.length - 1);
          }
        } else if (value == "submit") {
          handleSubmit();
          _controller.clear();
          Navigator.pop(context);
        } else {
          if (_controller.text.length < maxDigits) {
            temporaryAnswer = _controller.text += value;
          }
        }
      } else if (value is Icon && value.icon == Icons.backspace) {
        if (_controller.text.isNotEmpty) {
          _controller.text =
              _controller.text.substring(0, _controller.text.length - 1);
        }
      }
    });
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < 9) {
      setState(() {
        currentQuestionIndex++;
        progress = (currentQuestionIndex + 1) / 10.0;
        currentQuestionValue = 0;
        temporaryAnswer = '';
        if (widget.type == "Multiplication") {
          multi(currentQuestion.cast<String>());
        } else if (widget.type == "Division") {
          division(currentQuestion.cast<String>());
        } else {
          startCountdown();
        }
      });
    } else {
      print('All questions are completed.');

      print('Total correct answers: ${answers.length}');
      if (answers.length == 10) {
        print('All questions are answered correctly!');
      } else {
        print('Some questions are not answered correctly.');
      }
      print('Total correct answers: ${answers.length} out of 10');
    }
  }

  void handleBackspace() {
    if (temporaryAnswer.isNotEmpty) {
      setState(() {
        temporaryAnswer =
            temporaryAnswer.substring(0, temporaryAnswer.length - 1);
      });
    }
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
                    fixedSize: const Size(30.0, 10.0),
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

  void handleSubmit() {
    if (temporaryAnswer == "0" ||
        temporaryAnswer == "00" ||
        temporaryAnswer == "000" ||
        temporaryAnswer == "0000") {
      print('Temporary Answer is 0. Showing dialog.');
      ValidAnswerDialoge();
    } else if (temporaryAnswer.isNotEmpty) {
      apiData?.then((data) {
        final currentQuestionData = data['data'][currentQuestionIndex];
        final correctAnswer = currentQuestionData['answers'][0];

        print('Temporary Answer: $temporaryAnswer');
        print('Answer: $correctAnswer');

        if (temporaryAnswer == correctAnswer) {
          answers.add(currentQuestionIndex);
        }

        answer = '';
        temporaryAnswer = '';

        if (currentQuestionIndex < 9) {
          moveToNextQuestion();
        } else {
          print('All questions are completed.');
          // This is where the navigation should occur
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => oralResultScreen(
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
          print('Time taken: $formattedTimer');
          if (answers.length == 10) {
            print('All questions are answered correctly!');
          } else {
            print('Some questions are not answered correctly.');
          }
        }
      });
    } else {
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
  }

  Future<void> speakText(String text) async {
    // Replace the minus sign with the word "minus"
    String modifiedText = text.replaceAll('-', 'less than');

    await flutterTts.speak(modifiedText);
  }

  bool shouldDisableBackButton() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
            return false;
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
          body: Column(
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
              buildQuestionView(),
            ],
          ),
        ));
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
                width: 40,
              ),
              buildCountdownContainer(),
            ],
          );
        }
      },
    );
  }

  Widget LinearIndicator() {
    return Container(
      height: 10, // Adjust the height as needed
      width: 360, // Adjust the width as needed
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(5), // Adjust the border radius as needed
        border: Border.all(color: Colors.blue), // Set the border color to blue
      ),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor:
            Colors.transparent, // Set the background color to transparent
        valueColor: const AlwaysStoppedAnimation<Color>(
            Colors.blue), // Set the value color to blue
      ),
    );
  }

  Widget buildCountdownContainer() {
    Color textColor =
        remainingTime <= 10 ? Colors.red : const Color.fromARGB(255, 26, 1, 1);

    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        return Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColorAnimation.value!,
              width: 5.0,
            ),
          ),
          child: Center(
            child: Text(
              '$remainingTime',
              style: TextStyle(
                  color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget buildQuestionView() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: apiData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No questions available'));
            } else {
              final data = snapshot.data!;
              questionList = List<List<String>>.from(
                data['data'].map(
                  (item) => List<String>.from(item['question']),
                ),
              );

              // Check if all questions are completed
              if (currentQuestionIndex >= questionList.length) {
                return Center(
                  child: Text(
                    'All questions completed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              }

              final currentQuestion = questionList[currentQuestionIndex];
              return buildQuestionListView(currentQuestion);
            }
          },
        ),
      ),
    );
  }

  Widget buildQuestionListView(List<String> currentQuestion) {
    String textToSpeak = currentQuestion[currentQuestionValue];
    String multiplicationExpression =
        '${int.tryParse(currentQuestion[0]) ?? 0} × ${int.tryParse(currentQuestion[1]) ?? 0}';
    String divisionExpression =
        '${int.tryParse(currentQuestion[0]) ?? 0} / ${int.tryParse(currentQuestion[1]) ?? 0}';
    if (!hasSpokenMultiplication && widget.type == "Multiplication") {
      String multiplicationExpression =
          '${int.tryParse(currentQuestion[0]) ?? 0} maltiply ${int.tryParse(currentQuestion[1]) ?? 0}';
      speakText(multiplicationExpression);
      hasSpokenMultiplication = true;
    } else if (!hasSpokenDivision && widget.type == "Division") {
      String divisionExpression =
          '${int.tryParse(currentQuestion[0]) ?? 0} division ${int.tryParse(currentQuestion[1]) ?? 0}';
      speakText(divisionExpression);
      hasSpokenDivision = true;
    }

    List<Color> textColors = [
      const Color.fromARGB(255, 252, 158, 158),
      Colors.blue,
      Colors.red,
      Colors.pink,
      const Color.fromARGB(255, 23, 168, 4),
      Colors.orange,
      Colors.blueGrey,
      const Color.fromARGB(255, 45, 3, 168)
    ];

    Color textColor = textColors[currentQuestionValue % textColors.length];
    if (widget.type == "Multiplication") {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 75),
        child: Container(
          width: 300,
          height: 155,
          child: Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 50),
                children: [
                  TextSpan(
                    text: multiplicationExpression,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 12, 96,
                            165)), // Change color for the first part
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (widget.type == "Division") {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 75),
        child: Container(
          width: 300,
          height: 155,
          child: Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 50),
                children: [
                  TextSpan(
                    text: divisionExpression,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 12, 96,
                            165)), // Change color for the first part
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 70,
          width: 200,
          child: Center(
            child: Text(
              textToSpeak,
              style: TextStyle(fontSize: 55, color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAnswerInput() {
    return const SizedBox(
      height: 25,
    );
  }

  Widget buildAnswerPad() {
    return Column(
      children: [
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isEmpty) {
              // Show dialog for empty answer
              showDialog(
                context: context,
                builder: (context) => buildAlertDialog(),
              );
            } else {
              // Handle non-empty answer submission
              handleSubmit();
              Navigator.pop(context);
              _controller.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        // Add your buildToggleCard() function here if needed,
        // buildToggleCard(),
      ],
    );
  }

  Widget buildAlertDialog() {
    return AlertDialog(
      title: const ListTile(
        title: Text(
          'Please Enter Answer!',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          Icons.error,
          color: Colors.red,
          size: 48.0,
        ),
      ),
      actions: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ),
        ),
      ],
    );
  }
}
