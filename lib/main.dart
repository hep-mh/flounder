import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:window_size/window_size.dart';

import 'state.dart';
import 'home.dart';


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
      setWindowMinSize(const Size(450, 600));
    }
  }

  // Run the app
  runApp(const Flounder());
} // main
