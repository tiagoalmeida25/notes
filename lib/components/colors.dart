import 'package:flutter/material.dart';

String setStringFromColor(Color colorString) {
  if (colorString == Colors.black) {
    return 'black';
  } else if(colorString == const Color.fromRGBO(101, 110, 117, 1)){
    return 'darkgrey';
  }
  else if(colorString == const Color.fromRGBO(84, 110, 122, 1)){
    return 'bluegrey';
  }
  else if(colorString == const Color.fromRGBO(176, 178, 199, 1)){
    return 'grey';
  }
  else if(colorString == Colors.white){
    return 'white';
  }
  else if(colorString == const Color.fromARGB(255, 176, 82, 76)){
    return 'red';
  }
  else if(colorString == const Color.fromRGBO(56, 142, 60, 1)){
    return 'darkgreen';
  }
  else if(colorString == const Color.fromRGBO(236, 176, 47, 1)){
    return 'yellow';
  }
  else if(colorString == const Color.fromRGBO(25, 82, 148, 1)){
    return 'darkblue';
  }
  else if(colorString == const Color.fromRGBO(209, 196, 233, 1)){
    return 'lightpurple';
  }
  else if(colorString == const Color.fromRGBO(255, 224, 178, 1)){
    return 'lightorange';
  }
  else if(colorString == const Color.fromRGBO(220, 237, 200, 1)){
    return 'lightgreen';
  }
  else if(colorString == const Color.fromRGBO(255, 249, 196, 1)){
    return 'lightyellow';
  }
  else if(colorString == const Color.fromRGBO(187, 222, 251, 1)){
    return 'lightblue';
  }
  else if(colorString == const Color.fromRGBO(252, 228, 236, 1)){
    return 'lightpink';
  } else {
    return 'white';
  }
}

Color getColorFromString(String? colorString) {
  switch (colorString) {
    case 'black':
      return Colors.black;
    case 'darkgrey':
      return const Color.fromRGBO(101, 110, 117, 1);
    case 'bluegrey':
      return const Color.fromRGBO(84, 110, 122, 1);
    case 'grey':
      return const Color.fromRGBO(176, 178, 199, 1);
    case 'white':
      return Colors.white;
    case 'red':
      return const Color.fromARGB(255, 176, 82, 76);
    case 'darkgreen':
      return const Color.fromRGBO(56, 142, 60, 1);
    case 'yellow':
      return const Color.fromRGBO(236, 176, 47, 1);
    case 'darkblue':
      return const Color.fromRGBO(25, 82, 148, 1);
    case 'lightpurple':
      return const Color.fromRGBO(209, 196, 233, 1);
    case 'lightorange':
      return const Color.fromRGBO(255, 224, 178, 1);
    case 'lightgreen':
      return const Color.fromRGBO(220, 237, 200, 1);
    case 'lightyellow':
      return const Color.fromRGBO(255, 249, 196, 1);
    case 'lightblue':
      return const Color.fromRGBO(187, 222, 251, 1);
    case 'lightpink':
      return const Color.fromRGBO(252, 228, 236, 1);
    default:
      return Colors.white;
  }
}