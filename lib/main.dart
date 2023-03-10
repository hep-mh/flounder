import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:window_manager/window_manager.dart';
import 'package:simple_pip_mode/simple_pip.dart';

import 'home.dart';


void main() async {
  // Ensure initialization of all Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

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

  // Enable Picture-in-Picture mode on Android, if automatic
  // PiP mode is available on the current Android system
  if (Platform.isAndroid) { if (await SimplePip.isAutoPipAvailable) {
        SimplePip().setAutoPipMode();
  }}

  // Run the app
  runApp(const Flounder());
}
