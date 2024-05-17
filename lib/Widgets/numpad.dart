import 'dart:async';

import 'package:flutter/material.dart';

class NumberPad extends StatefulWidget {
  final Function(String) onTap;

  NumberPad({required this.onTap});

  @override
  _NumberPadState createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  String? _selectedNumber;

  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildNumberRow(1, 3),
          buildNumberRow(4, 6),
          buildNumberRow(7, 9),
       // buildNumberRow(0, 0, additionalWidgets: [buildBackspaceButton()]),
           buildLastRow(),
        ],
      ),
    );
  }

Widget buildNumberRow(int start, int end ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = start; i <= end; i++) 
            buildNumberButton('$i'),
        ],
      ),
    );
  }

  Widget buildLastRow() {
    return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: [

                    buildNumberButton('',),
                SizedBox(width:0),  // Add an empty space as a placeholder


          buildNumberButton('0',),
                  SizedBox(width: 13),  // Add an empty space as a placeholder

          buildBackspaceButton(),
                            SizedBox(width: 25),  // Add an empty space as a placeholder


        ],
      ),
    );
  }

  Widget buildNumberButton(String label, {double width = 90}) {
    bool isSelected = _selectedNumber == label;

    return GestureDetector(
      onTap: () => onTapButton(label),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: width,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: isSelected ? Colors.blue : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildBackspaceButton() {
    return GestureDetector(
      onTap: () => widget.onTap('backspace'),
      child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),

        // padding: const EdgeInsets.only(left: 55),
        child: Container(
          child: Icon(
            Icons.backspace,
            color: Colors.red,
            size: 30,
          ),
        ),
      ),
    );
  }

  void onTapButton(String label) {
    widget.onTap(label);
    setState(() {
      _selectedNumber = label;
    });

    Timer(Duration(milliseconds: 200), () {
      setState(() {
        _selectedNumber = null;
      });
    });
  }
}
