import 'package:flutter/material.dart';

String setStringFromColor(Color colorString) {
  if (colorString == Colors.black) {
    return 'black';
  } else if (colorString == Colors.grey[800]) {
    return 'grey[800]';
  } else if (colorString == Colors.grey[600]) {
    return 'grey[600]';
  } else if (colorString == Colors.grey[400]) {
    return 'grey[400]';
  } else if (colorString == Colors.grey[200]) {
    return 'grey[200]';
  } else if (colorString == Colors.pink[50]) {
    return 'pink[50]';
  } else if (colorString == Colors.white) {
    return 'white';
  } else if(colorString == Colors.blue[100]) {
    return 'blue[100]';
  } else if(colorString == Colors.orange[100]){
    return 'orange[100]';
  }
  
  else {
    return 'white';
  }
}

Color getColorFromString(String? colorString) {
  switch (colorString) {
    case 'black':
      return Colors.black;
    case 'grey[800]':
      return const Color.fromRGBO(66, 66, 66, 1);
    case 'grey[600]':
      return const Color.fromRGBO(117, 117, 117, 1);
    case 'grey[400]':
      return const Color.fromRGBO(189, 189, 189, 1);
    case 'grey[200]':
      return const Color.fromRGBO(238, 238, 238, 1);
    case 'white':
      return Colors.white;
    case 'pink[50]':
      return Colors.pink[50]!;
    case 'blue[100]':
      return Color.fromRGBO(187, 222, 251, 1);
    case 'orange[100]':
      return Color.fromRGBO(255, 224, 178, 1);
    default:
      return Colors.white;
  }
}
