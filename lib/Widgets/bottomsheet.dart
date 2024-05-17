// import 'package:flutter/material.dart';

// import '../levels/level_3.dart';




// class CustomModalBottomSheet extends StatelessWidget {
//   final String selectedId;
//   final String selectedName;
//   final bool isVisual;
//   final bool isOral;

//   CustomModalBottomSheet({
//     required this.selectedId,
//     required this.selectedName,
//     required this.isVisual,
//     required this.isOral,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text('Selected ID: $selectedId\nSelected Name: $selectedName'),
//           SizedBox(height: 20),
//           Text('Visual: ${isVisual ? 'Enabled' : 'Disabled'}'),
//           Text('Oral: ${isOral ? 'Enabled' : 'Disabled'}'),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => NextScreen(
//                     selectedId: selectedId,
//                     selectedName: selectedName,
//                   ),
//                 ),
//               );
//             },
//             child: Text('Start'),
//           ),
//         ],
//       ),
//     );
//   }
// }


