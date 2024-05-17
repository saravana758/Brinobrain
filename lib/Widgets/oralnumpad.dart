import 'dart:async';

import 'package:flutter/material.dart';

class OralNumberPad extends StatefulWidget {
  final Function(String) onTap;

  OralNumberPad({required this.onTap});

  @override
  _OralNumberPadState createState() => _OralNumberPadState();
}

class _OralNumberPadState extends State<OralNumberPad> {
  String? _selectedNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 1; i <= 3; i++) _buildButton('$i'),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 4; i <= 6; i++) _buildButton('$i'),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 7; i <= 9; i++) _buildButton('$i'),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(65, 0, 0, 0),
                child: SizedBox(
                  width: 90,
                  child: _buildButton('0'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onTap('backspace'); // Trigger backspace action
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Container(
                    child: Icon(
                      Icons.backspace,
                      color: Colors.red,
                      size: 35,
                    ),
                    
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label) {
    bool isSelected = _selectedNumber == label;

    void onTapButton() {
      widget.onTap(label);
      setState(() {
        _selectedNumber = label;
      });

      // Reset _selectedNumber after a brief delay (e.g., 200 milliseconds)
      Timer(Duration(milliseconds: 200), () {
        setState(() {
          _selectedNumber = null;
        });
      });
    }

    return GestureDetector(
      onTap: onTapButton,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200), // Adjust the duration as needed
        width: 90,
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
}




class ToggleCard extends StatelessWidget {
  final bool isBlue;
  final VoidCallback onPressed;
  final Function(String) onNumberPressed;

  ToggleCard({
    required this.isBlue,
    required this.onPressed,
    required this.onNumberPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: null, // Set color to null to remove the color
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
           
            SizedBox(height: 16), // Add some spacing
            OralNumberPad(
              onTap: (String number) {
                onNumberPressed(number);
              },
            ), // Add the NumberPad widget
          ],
        ),
      ),
    );
  }
}
