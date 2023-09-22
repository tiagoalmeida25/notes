import 'package:flutter/material.dart';

class AppColors {
  static const tagColors = [
    Color.fromRGBO(165, 226, 251, 1),
    Color.fromRGBO(111, 173, 245, 1),
    Color.fromRGBO(200, 239, 138, 1),
    Color.fromRGBO(132, 196, 197, 1),
    Color.fromRGBO(230, 205, 248, 1),
    Color.fromRGBO(187, 126, 235, 1),
    Color.fromRGBO(251, 159, 193, 1),
    Color.fromRGBO(250, 164, 122, 1),

    Color.fromRGBO(236, 105, 96, 1),
    Color.fromRGBO(250, 208, 178, 1),
    Color.fromRGBO(252, 163, 129, 1),
    Color.fromRGBO(250, 237, 169, 1),
    Color.fromRGBO(252, 215, 115, 1),
  ];
}

List<Color> darkColors = [
  Colors.black,
  const Color.fromRGBO(101, 110, 117, 1),
  const Color.fromRGBO(84, 110, 122, 1),
  const Color.fromARGB(255, 176, 82, 76),
  const Color.fromRGBO(56, 142, 60, 1),
  const Color.fromRGBO(25, 82, 148, 1),
  const Color.fromRGBO(176, 178, 199, 1)
];

List<Color> lightColors = [
  Colors.white,
  const Color.fromRGBO(209, 196, 233, 1),
  const Color.fromRGBO(236, 176, 47, 1),
  const Color.fromRGBO(255, 224, 178, 1),
  const Color.fromRGBO(220, 237, 200, 1),
  const Color.fromRGBO(255, 249, 196, 1),
  const Color.fromRGBO(187, 222, 251, 1),
  const Color.fromRGBO(252, 228, 236, 1),
];


String setStringFromColor(Color color) {
  if (color == Colors.black) {
    return 'black';
  } else if(color == const Color.fromRGBO(101, 110, 117, 1)){
    return 'darkgrey';
  }
  else if(color == const Color.fromRGBO(84, 110, 122, 1)){
    return 'bluegrey';
  }
  else if(color == const Color.fromRGBO(176, 178, 199, 1)){
    return 'grey';
  }
  else if(color == Colors.white){
    return 'white';
  }
  else if(color == const Color.fromARGB(255, 176, 82, 76)){
    return 'red';
  }
  else if(color == const Color.fromRGBO(56, 142, 60, 1)){
    return 'darkgreen';
  }
  else if(color == const Color.fromRGBO(236, 176, 47, 1)){
    return 'yellow';
  }
  else if(color == const Color.fromRGBO(25, 82, 148, 1)){
    return 'darkblue';
  }
  else if(color == const Color.fromRGBO(209, 196, 233, 1)){
    return 'lightpurple';
  }
  else if(color == const Color.fromRGBO(255, 224, 178, 1)){
    return 'lightorange';
  }
  else if(color == const Color.fromRGBO(220, 237, 200, 1)){
    return 'lightgreen';
  }
  else if(color == const Color.fromRGBO(255, 249, 196, 1)){
    return 'lightyellow';
  }
  else if(color == const Color.fromRGBO(187, 222, 251, 1)){
    return 'lightblue';
  }
  else if(color == const Color.fromRGBO(252, 228, 236, 1)){
    return 'lightpink';
  } 
  else if(color == const Color.fromRGBO(165, 226, 251, 1)){
    return 'Color.fromRGBO(165, 226, 251, 1)';
  }else if(color == const Color.fromRGBO(111, 173, 245, 1)){
    return 'Color.fromRGBO(111, 173, 245, 1)';
  }
  else if( color == const Color.fromRGBO(200, 239, 138, 1)){
    return 'Color.fromRGBO(200, 239, 138, 1)';
  }
  else if( color == const Color.fromRGBO(132, 196, 197, 1)){
    return 'Color.fromRGBO(132, 196, 197, 1)';
  }
  else if( color == const Color.fromRGBO(230, 205, 248, 1)){
    return 'Color.fromRGBO(230, 205, 248, 1)';
  }
  else if( color == const Color.fromRGBO(187, 126, 235, 1)){
    return 'Color.fromRGBO(187, 126, 235, 1)';
  }
  else if( color == const Color.fromRGBO(251, 159, 193, 1)){
    return 'Color.fromRGBO(251, 159, 193, 1)';
  }
  else if( color == const Color.fromRGBO(250, 164, 122, 1)){
    return 'Color.fromRGBO(250, 164, 122, 1)';
  }
  else if( color == const Color.fromRGBO(236, 105, 96, 1)){
    return 'Color.fromRGBO(236, 105, 96, 1)';
  }
  else if( color == const Color.fromRGBO(250, 208, 178, 1)){
    return 'Color.fromRGBO(250, 208, 178, 1)';
  }
  else if( color == const Color.fromRGBO(252, 163, 129, 1)){
    return 'Color.fromRGBO(252, 163, 129, 1)';
  }else if( color == const Color.fromRGBO(250, 237, 169, 1)){
    return 'Color.fromRGBO(250, 237, 169, 1)';
  }else if( color == const Color.fromRGBO(252, 215, 115, 1)){
    return 'Color.fromRGBO(252, 215, 115, 1)';
  }  else {
    return 'white';
  }
}

Color getColorFromString(String colorString) {
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
    case 'Color.fromRGBO(165, 226, 251, 1)':
      return const Color.fromRGBO(165, 226, 251, 1);
    case 'Color.fromRGBO(111, 173, 245, 1)':
      return const Color.fromRGBO(111, 173, 245, 1);
    case 'Color.fromRGBO(200, 239, 138, 1)':
      return const Color.fromRGBO(200, 239, 138, 1);
    case 'Color.fromRGBO(132, 196, 197, 1)':
      return const Color.fromRGBO(132, 196, 197, 1);
    case 'Color.fromRGBO(230, 205, 248, 1)':
      return const Color.fromRGBO(230, 205, 248, 1);
    case 'Color.fromRGBO(187, 126, 235, 1)':
      return const Color.fromRGBO(187, 126, 235, 1);
    case 'Color.fromRGBO(251, 159, 193, 1)':  
      return const Color.fromRGBO(251, 159, 193, 1);
    case 'Color.fromRGBO(250, 164, 122, 1)': 
      return const Color.fromRGBO(250, 164, 122, 1);
    case 'Color.fromRGBO(236, 105, 96, 1)':
      return const Color.fromRGBO(236, 105, 96, 1);
    case 'Color.fromRGBO(250, 208, 178, 1)':
      return const Color.fromRGBO(250, 208, 178, 1);
    case 'Color.fromRGBO(252, 163, 129, 1)':
      return const Color.fromRGBO(252, 163, 129, 1);
    case 'Color.fromRGBO(250, 237, 169, 1)':
      return const Color.fromRGBO(250, 237, 169, 1);
    case 'Color.fromRGBO(252, 215, 115, 1)':
      return const Color.fromRGBO(252, 215, 115, 1);
    default:
      return Colors.white;
  }
}
