import 'package:flutter/material.dart';

class CalculatorDialog extends StatefulWidget {
  @override
  _CalculatorDialogState createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String userInput = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
     
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         
          Text(userInput, style: TextStyle(fontSize: 24.0)),
          
          // Number pad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('0'),
              _buildNumberButton('.'),
              _buildBackspaceButton(),
            ],
          ),
          
          // View Answer button
          ElevatedButton(
            onPressed: () {
              // Calculate and display the answer (for simplicity, this example just displays the user input)
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Answer'),
                    content: Text(userInput),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('View Answer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return TextButton(
      onPressed: () {
        setState(() {
          userInput += number;
        });
      },
      child: Text(number, style: TextStyle(fontSize: 20.0)),
    );
  }

  Widget _buildBackspaceButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          if (userInput.isNotEmpty) {
            userInput = userInput.substring(0, userInput.length - 1);
          }
        });
      },
      child: Icon(Icons.backspace, size: 20.0),
    );
  }

  
}