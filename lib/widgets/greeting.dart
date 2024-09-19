import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
String getGreeting() {
  var now = DateTime.now();
  var hour = now.hour;
  if (hour < 12) {
    return 'Good Morning\n';
  } else if (hour < 16) {
    return 'Good Afternoon\n';
  } else if (hour < 21) {
    return 'Good Evening\n';
  } else {
    return 'Good Night\n';
  }
}

@override
Widget build(BuildContext context) {
  return Text(
    getGreeting(),
    style: TextStyle(fontSize: 16, color: Colors.white,),
  );
}
}