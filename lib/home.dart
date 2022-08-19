import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock/wakelock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state.dart';
import 'widgets.dart';


class Flounder extends StatelessWidget {
  const Flounder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flounder',
      home: const FlounderHome(),
      theme: ThemeData(
        primaryColor: const Color(0xff1f1f1f),
      ),
    );
  }
} // Flounder


class FlounderHome extends StatefulWidget {
  const FlounderHome({Key? key}) : super(key: key);

  @override
  State<FlounderHome> createState() => _FlounderHomeState();
} // FlounderHome


class _FlounderHomeState extends State<FlounderHome> {
  FlounderState state = FlounderState();

  // DropdownMenu
  String dropdownValue = FlounderState.initialPresetKey;

  // TextFields
  final Map textEditingControllers = {
    'Talk'      : TextEditingController(),
    'Discussion': TextEditingController(),
    'Reminder@' : TextEditingController(),
  };

  // The Timer for async execution of timer changes
  // This initializer executes on empty function once
  Timer runner = Timer(Duration.zero, () {});

  void _playSound() async {
    AudioPlayer player = AudioPlayer();

    await player.play( AssetSource('ding.mp3') );
  }

  void _toggleWakelock(bool enable) {
    if (kIsWeb) {
      Wakelock.toggle(enable: enable);
    } else {
      // Wacklock currently does not work on Linux
      if (!Platform.isLinux) { Wakelock.toggle(enable: enable); }
    }
  }

  void _rebuildDropdownMenu() {
    dropdownItems.clear();

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
  }

  // Actions
  void _onPlayButtonPressed() {
    setState(() {
      // START TIMER
      if ( state.mode.id == 'Idle' ) {
        // Enable the wakelock when the timer is started
        _toggleWakelock(true);

        state.mode = ModeRegister.talk;

        runner = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() {
            // Check if a reminder needs to be given
            if ( state.timer == state.profile.reminderAt*60 ) {
              if ( state.profile.remindMe && state.mode.id == 'Talk' ) { _playSound(); }
            }

            // Check if switch to discussion/overtime is necessary
            if ( state.timer == 0 && state.mode.id != 'Overtime' ) {
              _playSound();

              switch(state.mode.id) {
                // Talk -> Discussion
                case 'Talk': {
                  state.mode  = ModeRegister.discussion;
                  state.timer = state.profile.discussionLength*60;
                  break;
                }
                // Discussion -> Overtime
                case 'Discussion': {
                  state.mode  = ModeRegister.overtime;
                  break;
                }
              }
            } else {
              // Increment the timer
              state.timer += state.mode.increment;
            }
          });
        });
      // STOP TIMER
      } else {
        // Disable the wakelock when the timer is stopped
        _toggleWakelock(false);

        state.mode = ModeRegister.idle;
        state.resetTimer();

        runner.cancel();
      }
    });
  }

  void _onBellButtonPressed() {
    setState(() { state.profile.remindMe = !state.profile.remindMe; });
  }

  void _onDropdownValueChanged(String? value) {
    setState(() {
      dropdownValue = value!;

      if (value != 'Custom') {
        state.profile = defaultPresets[dropdownValue].copy();
        state.resetTimer();
      }
    });
  }

  void _onSaveButtonPressed() {
    setState(() {
      String talkText       = textEditingControllers['Talk'].text;
      String discussionText = textEditingControllers['Discussion'].text;
      String reminderText   = textEditingControllers['Reminder@'].text;

      if (talkText != "") {
        state.profile.talkLength = int.parse(talkText);
      }
      if (discussionText != "") {
        state.profile.discussionLength = int.parse(discussionText);
      }
      if (reminderText != "") {
        state.profile.reminderAt = int.parse(reminderText);
      }

      // Reset the timer
      state.resetTimer();

      // Set the value of the dropdown menu to 'custom'
      dropdownValue = 'Custom';
    });
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      state.save = !state.save;
    });
  }

  @override
  void initState() {
    super.initState();

    _rebuildDropdownMenu();

    if (!kIsWeb) { if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xff1f1f1f)
        )
      );
    }}
  }

  @override
  void dispose() {
    // Clean up the TextEditingController's
    textEditingControllers.forEach((key, value) {
      value.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f1f1f),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      endDrawerEnableOpenDragGesture: false,
      body: FlounderBody(state: state),
      bottomNavigationBar: Builder(builder: (context) { return FlounderActionBar(
        state: state,
        onPressedL: _onBellButtonPressed,
        onPressedR: () {
          if ( state.mode.id == 'Idle' ) {
            Scaffold.of(context).openEndDrawer();
          }
        }
      );}),
      floatingActionButton: FlounderActionButton(
        state: state,
        onPressed: _onPlayButtonPressed,
      ),
      endDrawer: Builder(builder: (context) { return FlounderDrawer(
        state: state,
        dropdownValue: dropdownValue,
        onDropdownValueChanged: (String? value) {
          _onDropdownValueChanged(value);
          if (value != 'Custom') { Navigator.of(context).pop(); }
        },
        onSaveButtonPressed: () {
          _onSaveButtonPressed();
          Navigator.of(context).pop();
        },
        onCheckboxChanged: _onCheckboxChanged,
        controllers: textEditingControllers,
      );}),
    );
  } // _FlounderHomeState.build
} // _FlounderHomeState
