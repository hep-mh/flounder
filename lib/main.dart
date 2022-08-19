import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:window_manager/window_manager.dart';

import 'state.dart';
import 'home.dart';


void main() async {
  // Ensure initialization of all Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Fill the list of dropdown menu items
  defaultPresets.forEach((key, value) => dropdownItems.add(
    DropdownMenuItem<String>(
      value: key,
      child: Text(value.dropdownEntry(), style: const TextStyle(color: Colors.white)),
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
      // Ensure initialization of window_manager
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        title: 'Flounder',
        minimumSize: Size(450, 600)
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  // Run the app
  runApp(const Flounder());
} // main
