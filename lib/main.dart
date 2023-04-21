import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

import 'home.dart';


void main() async {
  // Ensure initialization of all Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Set some window properties on desktop platforms
  if ( !kIsWeb ) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // Ensure initialization of window_manager
      await windowManager.ensureInitialized();

      const WindowOptions windowOptions = WindowOptions(
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
}
