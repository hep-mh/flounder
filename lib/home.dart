import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';

import 'state.dart';
import 'subw.dart';


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
  FlounderState state = FlounderState(
    presets[FlounderState.DEFAULT_PRESET_KEY]
  );

  // Widget properties
  String dropdownValue = FlounderState.DEFAULT_PRESET_KEY;

  final Map textEditingControllers = {
    'Talk'      : TextEditingController(),
    'Discussion': TextEditingController(),
    'Reminder@' : TextEditingController(),
  };


  // The Timer for async execution of timer changes
  // This initializer executes on empty function once
  Timer runner = Timer(Duration.zero, () {});


  void _playSound() async {
    print('Sound!');

    AudioPlayer player = AudioPlayer();
    await player.setAsset('ding.mp3');
    player.play();
  }


  void _onPlayButtonPressed() {
    setState(() {
      if ( state.mode.id == 'Idle' ) {
        state.mode = ModeRegister.TALK;

        runner = Timer.periodic(Duration(seconds: 1), (Timer t) {
          setState(() {
            // Check if a reminder needs to be given
            if ( state.timer == state.settings.reminderAt*60 ) {
              if ( state.settings.remindMe && state.mode.id == 'Talk' ) { _playSound(); }
            }

            // Check if switch to discussion/overtime is necessary
            if ( state.timer == 0 ) {
              _playSound();

              switch(state.mode.id) {
                // Talk -> Discussion
                case 'Talk': {
                  state.mode  = ModeRegister.DISCUSSION;
                  state.timer = state.settings.discussionLength*60;
                  break;
                }
                // Discussion -> Overtime
                case 'Discussion': {
                  state.mode  = ModeRegister.OVERTIME;
                  break;
                }
              }
            }

            // Increment the timer
            state.timer += state.mode.increment;
          });
        });
      } else {
        state.mode = ModeRegister.IDLE;
        state.resetTimer();

        runner.cancel();
      }
    });
  }


  void _onBellButtonPressed() {
    setState(() { state.settings.remindMe = !state.settings.remindMe; });
  }


  void _onDropdownValueChanged(String? value) {
    setState(() {
      dropdownValue = value!;

      if (value != 'Custom') {
        state.settings = presets[dropdownValue];
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
        state.settings.talkLength = int.parse(talkText);
      }
      if (discussionText != "") {
        state.settings.discussionLength = int.parse(discussionText);
      }
      if (reminderText != "") {
        state.settings.reminderAt = int.parse(reminderText);
      }

      // Reset the timer
      state.resetTimer();

      // Set the value of the dropdown menu to 'custom'
      dropdownValue = 'Custom';
    });
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
        controllers: textEditingControllers,
      );}),
    );
  } // _FlounderHomeState.build
} // _FlounderHomeState
