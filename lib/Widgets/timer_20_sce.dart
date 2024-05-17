import 'package:flutter/material.dart';
import 'package:quiver/async.dart';




class MyCountdownContainer extends StatefulWidget {
  late final int remainingTime;
   MyCountdownContainer({required this.remainingTime});
  @override
  _MyCountdownContainerState createState() => _MyCountdownContainerState();
}

class _MyCountdownContainerState extends State<MyCountdownContainer> {
  int _timeRemaining = 10; // Initial time in seconds
  CountdownTimer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = CountdownTimer(
      Duration(seconds: _timeRemaining),
      Duration(seconds: 1),
    );

    _countdownTimer?.listen((event) {
      setState(() {
        _timeRemaining = event.remaining.inSeconds;
      });

      if (event.remaining.inSeconds == 0) {
        // Timer has finished, you can perform actions here
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = _timeRemaining <= 10 ? Colors.red : const Color.fromARGB(255, 26, 1, 1);
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.blue,
          width: 5.0,
        ),
       
      ),
      child: Center(
        child: Text(
          '$_timeRemaining',
          style: TextStyle(color: textColor, fontSize: 25,fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}