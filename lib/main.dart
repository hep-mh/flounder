import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:window_size/window_size.dart';

import 'state.dart';
import 'home.dart';


const double MIN_WIDTH   = 450;
const double MIN_HEIGHT  = 600;


void main() {
  // Ensure initialization of all Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  if ( kDebugMode ) {
    presets['2+1'] = Settings(2, 1, 2, true);
  }

  // Fill the list of dropdown menu items
  presets.forEach((key, value) => dropdownItems.add(
    DropdownMenuItem<String>(
      value: key,
      child: Text(value.toString(), style: const TextStyle(color: Colors.white)),
    )
  ));
  dropdownItems.add(
    const DropdownMenuItem<String>(
      value: 'Custom',
      child: Text('Custom', style: TextStyle(color: Colors.white))
    ),
  );

  // Set some window properties on desktop platforms
  if ( !kIsWeb ) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      setWindowTitle('Flounder');
      setWindowMinSize(const Size(MIN_WIDTH, MIN_HEIGHT));
    }
  }

  // Run the app
  runApp(const Flounder());
} // main
