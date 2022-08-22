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
  void _updateTextFields() {
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

        state.mode = ModeRegister.TALK;

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
                  state.mode  = ModeRegister.DISCUSSION;
                  state.timer = state.profile.discussionLength*60;
                  break;
                }
                // Discussion -> Overtime
                case 'Discussion': {
                  state.mode  = ModeRegister.OVERTIME;
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

        state.mode = ModeRegister.IDLE;
        state.reconfigure();

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
        state.profile = state.presets.at(dropdownValue);
        // --> Reconfigure state on profile change
        state.reconfigure();

      }

      _updateTextFields();
    });
  }

  void _onDeleteButtonPressed() {
    setState(() {
      state.presets.remove(dropdownValue);

      if (state.presets.keys().isEmpty) { // Keep the current profile
        dropdownValue = 'Custom';
      } else {
        state.profile = state.presets.first();
        // --> Reconfigure state on profile change
        state.reconfigure();

        dropdownValue = state.profile.key();
      }
      
      _updateTextFields();
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
      // --> Reconfigure state on profile change
      state.reconfigure();

      if (state.presets.includes(state.profile.key())) {
        dropdownValue = state.profile.key();
      } else {
        dropdownValue = 'Custom';
      }
    });
  }

  void _onSaveButtonPressed() {
    setState(() {
      state.presets.add(state.profile);

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
      ProfileCollection presets = ProfileCollection();

      for (var presetStr in presetsFromPrefs) {
        TimerProfile profile = TimerProfile.fromString(presetStr);
        // -->
        presets.add(profile);
      }

      state.presets.swap(presets);
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
    if (!state.presets.hasChanged()) return;
    
    state.presets.fixChanges();

    dropdownItems.clear();
    // Fill the list of DropdownMenuItem's
    for (var key in state.presets.keys()) {
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: key,
          child: Text(key, style: const TextStyle(color: Colors.white)),
        )
      );
    }
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
            _updateTextFields();
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
