import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:window_size/window_size.dart';

import 'state.dart';
import 'home.dart';


final double MIN_WIDTH   = 450;
final double MIN_HEIGHT  = 600;


void main() {
  if ( kDebugMode ) {
    presets['2+1'] = Settings(2, 1, 2, true);
  }

  // Fill the list of dropdown menu items
  presets.forEach((key, value) => dropdownItems.add(
    DropdownMenuItem<String>(
      value: key,
      child: Text(value.toString(), style: TextStyle(color: Colors.white)),
    )
  ));
  dropdownItems.add(
    DropdownMenuItem<String>(
      value: 'Custom',
      child: Text('Custom', style: TextStyle(color: Colors.white))
    ),
  );

  // Set some window properties on desktop platforms
  if ( !kIsWeb ) {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      setWindowTitle('Flounder');
      setWindowMinSize(Size(MIN_WIDTH, MIN_HEIGHT));
    }
  }

  // Run the app
  runApp(const Flounder());
} // main
