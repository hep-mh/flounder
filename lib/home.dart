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
}


class FlounderHome extends StatefulWidget {
  const FlounderHome({Key? key}) : super(key: key);

  @override
  State<FlounderHome> createState() => _FlounderHomeState();
}


class _FlounderHomeState extends State<FlounderHome> {
  final ApplicationState state = ApplicationState();

  // The current list of items in the
  // DropdownMenu
  List< DropdownMenuItem<String> > dropdownItems = [];

  // The current value of the DropdownMenu
  late String dropdownValue;

  // A flag to check of the DropdownMenu
  // needs to be build on the next refresh
  // Initially true, since a build needs
  // to happe on the initial launch
  bool rebuildDropdownMenu = true;

  // The controllers used to update the content
  // of the different TextField objects
  final Map textFieldControllers = {
    'Talk'      : TextEditingController(),
    'Discussion': TextEditingController(),
    'Reminder@' : TextEditingController(),
  };

  // The Timer object driving the main clock
  late Timer runner;

  // The SharedPreferences object to
  // read user-defined presets
  late SharedPreferences prefs;

  // UTILITY FUNCTIONS ////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
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

  // HELPER FUNCTIONS /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  void _updateTextFormFields() {
    textFieldControllers['Talk'      ].text = state.profile.talkLength.toString();
    textFieldControllers['Discussion'].text = state.profile.discussionLength.toString();
    textFieldControllers['Reminder@' ].text = state.profile.reminderAt.toString();
  }

  // ACTION FUNCTIONS /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  void _onPlayButtonPressed() {
    setState(() {
      // START THE TIMER WHEN IDLE
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
      // STOP THE TIMER WHEN RUNNING
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
        state.profile = state.presets[dropdownValue].clone();
        // --> Reset timer on profile change
        state.resetTimer();

      }

      _updateTextFormFields();
    });
  }

  void _onDeleteButtonPressed() {
    // Only delete if the current profile is not custom
    if (dropdownValue == 'Custom') return;

    setState(() {
      state.presets.removeWhere((key, _) => key == dropdownValue);
      // -->
      rebuildDropdownMenu = true;

      if (state.presets.isEmpty) { // Keep the current profile
        dropdownValue = 'Custom';
      } else {
        state.profile = state.presets[state.presets.keys.first].clone();
        // --> Reset timer on profile change
        state.resetTimer();

        dropdownValue = state.profile.key();
      }
      
    });
  }

  void _onAnyTextFieldChanged(String? id, String? text) {
    if (text == '') return;

    setState(() {
      switch(id) {
        case 'Talk':
          state.profile.talkLength       = int.parse(text!);
          break;
        case 'Discussion':
          state.profile.discussionLength = int.parse(text!);
          break;
        case 'Reminder@':
          state.profile.reminderAt       = int.parse(text!);
          break;
      }
      // --> Reset timer on profile change
      state.resetTimer();

      if (state.presets.containsKey(state.profile.key())) {
        dropdownValue = state.profile.key();
      } else {
        dropdownValue = 'Custom';
      }
    });
  }

  void _onSaveButtonPressed() {
    // Only save if the current profile is custom
    if (dropdownValue != 'Custom') return;

    setState(() {
      state.presets[state.profile.key()] = state.profile.clone();
      // -->
      rebuildDropdownMenu = true;

      dropdownValue = state.profile.key();
    });
  }

  // INIT & DISPOSE FUNCTIONS /////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
   void _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();

    final List<String>? presetsFromPrefs = prefs.getStringList('presets');
    // If preferences are preset, override the defaults
    if (presetsFromPrefs != null) {
      Map presets = {};

      for (var presetStr in presetsFromPrefs) {
        TimerProfile profile = TimerProfile.fromString(presetStr);
        // -->
        presets[profile.key()] = profile;
      }

      state.swapPresets(presets);
    }
  }

  @override
  void initState() {
    super.initState();

    _loadPreferences();

    // Ensure that the navigation bar has
    // a matching color on Android devices
    if (!kIsWeb) { if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xff1f1f1f)
        )
      );
    }}

    dropdownValue = state.profile.key();
  }

  @override
  void dispose() {
    // Clean up the TextEditingController's
    textFieldControllers.forEach((key, value) {
      value.dispose();
    });

    super.dispose();
  }

  // BUILD FUNCTIONS //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  void _buildDropdownMenuIfNeeded() {
    // Only run if necessary
    if (!rebuildDropdownMenu) {
      return;
    } else {
      rebuildDropdownMenu = false;
    }

    dropdownItems.clear();
    // Fill the list of DropdownMenuItem's
    state.presets.forEach((key, _) {
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: key,
          child: Text(key, style: const TextStyle(color: Colors.white)),
        )
      );
    });
    dropdownItems.add(
      const DropdownMenuItem<String>(
        value: 'Custom',
        child: Text('Custom', style: TextStyle(color: Colors.white))
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _buildDropdownMenuIfNeeded();

    return Scaffold(
      backgroundColor: const Color(0xff1f1f1f),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      endDrawerEnableOpenDragGesture: false,
      // 1. FLOUNDER_BODY /////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////
      body: FlounderBody(state: state),
      // 2. FLOUNDER_ACTION_BAR ///////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////
      bottomNavigationBar: Builder(builder: (context) { return FlounderActionBar(
        state: state,
        onPressedL: _onBellButtonPressed,
        onPressedR: () {
          if ( state.mode.id == 'Idle' ) {
            _updateTextFormFields();
            Scaffold.of(context).openEndDrawer();
          }
        }
      );}),
      // 3. FLOUNDER_ACTION_BUTTON ////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////
      floatingActionButton: FlounderActionButton(
        state: state,
        onPressed: _onPlayButtonPressed,
      ),
      // 4. FLOUNDER_DRAWER //////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////
      endDrawer: FlounderDrawer(
        state: state,
        dropdownValue: dropdownValue,
        dropdownItems: dropdownItems,
        onDropdownValueChanged: _onDropdownValueChanged,
        onDeleteButtonPressed: _onDeleteButtonPressed,
        textFieldControllers: textFieldControllers,
        onAnyTextFieldChanged: _onAnyTextFieldChanged,
        onSaveButtonPressed: _onSaveButtonPressed,
      ),
    );
  }
}
