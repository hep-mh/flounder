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
  final FlounderState state = FlounderState();

  // DropdownMenu
  String dropdownValue = "";

  // TextFields
  final Map textEditingControllers = {
    'Talk'      : TextEditingController(),
    'Discussion': TextEditingController(),
    'Reminder@' : TextEditingController(),
  };

  // Timer
  Timer runner = Timer(Duration.zero, () {});

  // SharedPreferences
  // initState -> _initPreferences
  late SharedPreferences prefs;

  // HELPER FUNCTIONS
  void _initPreferences() async {
    prefs = await SharedPreferences.getInstance();

    final List<String>? presetsFromPrefs = prefs.getStringList('presets');
    // If preferences are preset, override defaults
    if (presetsFromPrefs != null) {
      Map presets = {};

      for (var preset in presetsFromPrefs) {
        Profile profile = Profile.fromString(preset);

        presets[profile.key()] = profile;
      }

      state.swapPresets(presets);
    }

    // -->
    _rebuildDropdownMenu();
  }

  void _rebuildDropdownMenu() {
    dropdownValue = state.profile.key();

    dropdownItems.clear();
    // Fill the list of dropdown menu items
    state.presets.forEach((key, value) => dropdownItems.add(
      DropdownMenuItem<String>(
        value: key,
        child: Text(value.key(), style: const TextStyle(color: Colors.white)),
      )
    ));
    dropdownItems.add(
      const DropdownMenuItem<String>(
        value: 'Custom',
        child: Text('Custom', style: TextStyle(color: Colors.white))
      ),
    );
  }

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

  // ACTION FUNCTIONS
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
              if ( state.remindMe && state.mode.id == 'Talk' ) { _playSound(); }
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
    setState(() { state.remindMe = !state.remindMe; });
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
      String talkText       = textEditingControllers['Talk'      ].text;
      String discussionText = textEditingControllers['Discussion'].text;
      String reminderText   = textEditingControllers['Reminder@' ].text;

      // Create a new Profile
      int talkLength       = (talkText       != "") ? int.parse(talkText)       : state.profile.talkLength;
      int discussionLength = (discussionText != "") ? int.parse(discussionText) : state.profile.discussionLength;
      int reminderAt       = (reminderText   != "") ? int.parse(reminderText)   : state.profile.reminderAt;
      
      // -->
      Profile profile = Profile(talkLength, discussionLength, reminderAt);

      // Set the profile (and potentially save it)
      // Key does exist already
      // Saving does not matter
      if (state.presets.containsKey(profile.key())) {
        state.profile = state.presets[profile.key()];
        dropdownValue = profile.key();
      // Key does not exist yet
      // Saving does matter
      } else {
        if (state.save) {
          state.presets[profile.key()] = profile;

          state.profile = state.presets[profile.key()];
          _rebuildDropdownMenu();
        } else {
          state.profile = profile;
          dropdownValue = 'Custom';
        }
      }

      // Reset the timer
      state.resetTimer();
    });
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      state.save = !state.save;
    });
  }

  // BUILD FUNCTIONS
  @override
  void initState() {
    super.initState();

    _initPreferences();

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
