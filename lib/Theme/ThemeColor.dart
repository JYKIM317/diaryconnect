import 'package:flutter/material.dart';

initializedColor(String theme) {
  var color;
  switch (theme) {
    case 'indigo':
      color = Colors.indigo;
      break;
    case 'deepPurple':
      color = Colors.deepPurple;
      break;
    case 'red':
      color = Colors.red;
      break;
    case 'lightBlue':
      color = Colors.lightBlue;
      break;
    case 'green':
      color = Colors.green;
      break;
    default:
      color = Colors.indigo;
  }
  return color;
}
