import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final List<CustomDropdownMenuItem<T>> items;
  final Function(T)? onSelected;

  CustomDropdownButton({required this.items, this.onSelected, required int height, required int width, required MaterialColor backgroundColor});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      icon: Icon(Icons.more_vert, color: Colors.white,),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return items;
      },
    );
  }
}

class CustomDropdownMenuItem<T> extends PopupMenuItem<T> {
  CustomDropdownMenuItem({required T value, required Widget child})
      : super(
          value: value,
          child: child,
        );
}