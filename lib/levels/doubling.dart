import 'dart:async';

import 'package:flutter/material.dart';

import 'package:s/Widgets/numpad.dart';
import 'package:s/home/home_screen.dart';

class Doubling extends StatefulWidget {


    final String token;

    Doubling({
          required this.token,

    });



  @override
  _DoublingState createState() => _DoublingState();
}

class _DoublingState extends State<Doubling> {
    String temporaryAnswer = '' ;
int numberOfEntries = 0;
bool startButtonClicked = false;


 int currentNumber = 0; // Initial number to double

  List<int> correctAnswers = [];
  List<int> correctSequence = [];
  List<int> enteredValues = [];
List<int> displayedSequence = [];
  bool showStartButton = true;
  bool showCloseButton = false;
    Timer? _timer;
int _timerInSeconds = 0;
ScrollController scrollController = ScrollController();






  // Add any state variables or methods you need for the widget

  String get formattedTimer {
    int minutes = _timerInSeconds ~/ 60;
    int seconds = _timerInSeconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  bool isCorrectValue() {
    int enteredValue = int.tryParse(temporaryAnswer) ?? 0;
    return enteredValue == currentNumber * 2;
  }

  

void generateDoublingSequence() {
  correctSequence.clear();
  for (int i = 1; i < 30; i++) {
    correctSequence.add(currentNumber * (1 << i));
  }
}


void startTimer() {
  const oneSec = Duration(seconds: 1);
  _timer = Timer.periodic(
    oneSec,
    (Timer timer) {
      setState(() {
        if (_timerInSeconds < 600) {
          _timerInSeconds++;
        } else {
          timer.cancel();
          // Optionally, you can handle what happens when the timer reaches a certain limit.
        }
      });
    },
  );
}


void handleStartButton() {
  int enteredValue = int.tryParse(temporaryAnswer) ?? 0;
  if (enteredValue > 0) {
    setState(() {
      currentNumber = enteredValue;
      correctSequence.clear();
      generateDoublingSequence();
      print(correctSequence);
      print("enteredValue");
      print(currentNumber);

      // Initialize displayedSequence with the entered value
      displayedSequence = [enteredValue];
      enteredValues.clear();
      temporaryAnswer = ''; // Clear the temporary answer
      startTimer();
      startButtonClicked = true;
      showStartButton = false;
      showCloseButton = true;
    });
  } else {
    // Show an error message for invalid input
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter a valid starting number.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}



void handleCloseButton() {
  setState(() {
    // Reset buttons
    showStartButton = true;
    showCloseButton = false;
  });
      _timer?.cancel();


  // Add any logic you need before navigating back
  Navigator.of(context).pop();
}

  
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 121, 14, 170),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios, 
          color: Colors.white,size: 28,
        ),
        onPressed: () {
          // Add navigation logic to go back
          Navigator.of(context).pop();
        },
      ),
  title: const Center(
    child: Text(
      'Brainobrain',
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
  actions: <Widget>[
    Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 13, 5),
        child: Row(
          children: [
            const SizedBox(width: 0),
            IconButton(
              icon: Icon(Icons.home, color: Colors.white,size:31),
              onPressed: () {
                // Add navigation logic to go to the home screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(token: widget.token),// Replace HomeScreen with the actual home screen widget
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  ],
),

      body: Padding(
        padding:  const EdgeInsets.all(4.0),
        child: Column(
         mainAxisAlignment: MainAxisAlignment.start,
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
                        color: Color.fromARGB(255, 50, 136, 158),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      "Level 10",
                      style: TextStyle(
                        color: Color.fromARGB(255, 50, 136, 158),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      '>',
                      style: TextStyle(
                        color: Color.fromARGB(255, 50, 136, 158),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      "Doubling",
                      style: TextStyle(
                        color: Color.fromARGB(255, 4, 84, 104),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
                       const SizedBox(height: 10),

           Container(
  padding: const EdgeInsets.all(4),
  alignment: Alignment.centerLeft,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Stopwatch timer with stopwatch symbol
      Row(
        children: [
          Icon(
            Icons.timer,
            size: 24,
            color: Colors.black,
          ),
          const SizedBox(width: 4.0),
          Text(
            formattedTimer,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      // Entries count
      Text(
        '${displayedSequence.length} entries',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

           const SizedBox(height: 10),
           
           
Visibility(
  visible: startButtonClicked ,
  child: Container(
    height: 80,
    child: SingleChildScrollView(
            controller: scrollController,

      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 6.0, // Adjust the spacing as needed
          runSpacing: 4.0, // Adjust the run spacing as needed
          children: [
            for (int i = 0; i < displayedSequence.length; i++)
              Container(
                height: 60,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: i == displayedSequence.length - 1 ? Colors.blue : Colors.white,
                  border: Border.all(
                    color: Colors.blue, // Set the border color to blue
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text(
                    '${displayedSequence[i]}',
                    style: TextStyle(fontSize: 18, color: i == displayedSequence.length - 1 ? Colors.white : Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  ),
),


 
//  Container(
//   height: 60,
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//        ' ${displayedSequence.join(', ')}',
//         style: const TextStyle(fontSize: 16, color: Colors.blue),
//       ),
//     ],
//   ),
// ),
            // LinearIndicator(),
           // buildQuestionView(),
           const Divider(),
                       const SizedBox(height: 10),

            buildAnswerInput(),
            buildAnswerPad(),
            const SizedBox(height: 10),



           // Submit Button
            // ElevatedButton(
            //   onPressed: handleSubmitButton,
            //   child: Text('Submit'),
            // ),
            
          ],


        )
      ),
    );
  }

  
         




  Widget buildAnswerInput() {
    return const SizedBox(
      height: 5,
    );
  }
Widget buildAnswerPad() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                temporaryAnswer.isNotEmpty ? temporaryAnswer : 'Your answer here',
                style: TextStyle(
                  fontSize: 15,
                  color: temporaryAnswer.isNotEmpty
                      ? Color.fromARGB(255, 54, 10, 156)
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: showStartButton ? handleStartButton : handleCloseButton,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          minimumSize: const Size(100, 40),
          backgroundColor: showStartButton
              ? Color.fromARGB(255, 121, 14, 170)
              : Color.fromARGB(97, 222, 15, 15),
        ),
        child: Text(
          showStartButton ? 'Start' : 'Close',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                temporaryAnswer += value;

                // Check if the entered value matches the correct sequence and is not repeated
                int entered = int.tryParse(temporaryAnswer) ?? 0;

                if (isValueInCorrectOrder(entered)) {
                  print("Condition passed: Value $entered is in correct order.");

                  // Add the currentNumber to the displayed sequence
                  displayedSequence = [currentNumber, ...enteredValues, entered];
                  print(displayedSequence);
                  enteredValues.add(entered);
                  temporaryAnswer = '';

                  // Update the displayed sequence and scroll to the latest entry
                  setState(() {
                    // Set the controller to scroll to the end
                    scrollController.animateTo(
                      scrollController.position.extentTotal,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  });
                } else {
                  print("Condition not passed: Value $entered is not in correct order.");
                }
              });
            }
          },
        ),
      ),
    ],
  );
}

//   bool isValueInCorrectOrder(int enteredValue){
//   int expectedIndex = enteredValues.length;

//   // Check if the entered value matches the correct sequence and is in the correct order
//   return displayedSequence.length > expectedIndex &&
//       correctSequence.sublist(0, expectedIndex + 1).last == enteredValue;
// }
bool isValueInCorrectOrder(int enteredValue) {
  int expectedIndex = enteredValues.length;

  // Check if the entered value matches the correct sequence and is in the correct order
  if (correctSequence.length > expectedIndex &&
      correctSequence[expectedIndex] == enteredValue) {
    // Check if the entered value hasn't been entered before
    if (!enteredValues.contains(enteredValue)) {
      return true;
    }
  }

  return false;
}

//   // Check if the entered value matches the updated entered values and is in the correct order
void updateDisplayedSequence() {
  // Convert temporary answer to a list of integers

  // Update the displayed sequence including the current number
  setState(() {
  //  displayedSequence = [currentNumber, ...enteredSequence];
  });

  // Print the displayed sequence for each entry
  print('Displayed Sequence for Entry $numberOfEntries: $displayedSequence');
  numberOfEntries++;
}
//   return displayedSequence.length > expectedIndex &&
//       correctSequence.sublist(0, expectedIndex + 1).last == enteredValue;
// }








////------------


 void handleBackspace() {
  if (temporaryAnswer.isNotEmpty) {
    setState(() {
      temporaryAnswer =
          temporaryAnswer.substring(0, temporaryAnswer.length - 1);
    });

    // Call updateDisplayedSequence outside the setState block
  //  updateDisplayedSequence();
  }
}
}

