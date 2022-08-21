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

  // The controllers used to obtain the content
  // of the different TextField objects
  final Map textEditingControllers = {
    'Talk'      : TextEditingController(),
    'Discussion': TextEditingController(),
    'Reminder@' : TextEditingController(),
  };

  // The Timer object driving the main clock
  late Timer runner;

  // The SharedPreferences object to
  // read user-defined presets
  late SharedPreferences prefs;

  // HELPER FUNCTIONS /////////////////////////////////////////////////////////
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
        state.profile = state.presets[dropdownValue].copy();
        state.resetTimer();
      }
    });
  }

  void _onDeleteButtonPressed() {
    setState(() {
      // Only delete if the current value is not 'Custom'
      if (dropdownValue == 'Custom') return;

      state.presets.removeWhere((key, _) => key == dropdownValue);
      // -->
      rebuildDropdownMenu = true;

      if (state.presets.isEmpty) { // Keep the current profile
        dropdownValue = 'Custom';
      } else {
        state.profile = state.presets[state.presets.keys.first].copy();

        dropdownValue = state.profile.key();
      }

      state.resetTimer();
    });
  }

  void _onApplyButtonPressed() {
    setState(() {
      String talkText       = textEditingControllers['Talk'      ].text;
      String discussionText = textEditingControllers['Discussion'].text;
      String reminderText   = textEditingControllers['Reminder@' ].text;

      // Create a new profile from the data
      // in the different text fields
      int talkLength       = (talkText       != "") ? int.parse(talkText)       : state.profile.talkLength;
      int discussionLength = (discussionText != "") ? int.parse(discussionText) : state.profile.discussionLength;
      int reminderAt       = (reminderText   != "") ? int.parse(reminderText)   : state.profile.reminderAt;
      
      // -->
      TimerProfile profile = TimerProfile(talkLength, discussionLength, reminderAt);

      // Key does already exist
      // --> Saving does not matter
      if (state.presets.containsKey(profile.key())) {
        state.profile = state.presets[profile.key()].copy();
        dropdownValue = profile.key();
      // Key does not exist yet
      // --> Saving does matter
      } else {
        if (state.save) {
          state.presets[profile.key()] = profile;
          // -->
          rebuildDropdownMenu = true;
        
          state.profile = state.presets[profile.key()].copy();
          dropdownValue = profile.key();
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
    // -->
    dropdownValue = state.profile.key();

    // Ensure that the navigation bar has
    // a matching color on Android devices
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
      endDrawerEnableOpenDragGesture: true,
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
      endDrawer: Builder(builder: (context) { return FlounderDrawer(
        state: state,
        dropdownValue: dropdownValue,
        dropdownItems: dropdownItems,
        onDropdownValueChanged: _onDropdownValueChanged,
        onDeleteButtonPressed: _onDeleteButtonPressed,
        onApplyButtonPressed: () {
          _onApplyButtonPressed();
          Navigator.of(context).pop();
        },
        onCheckboxChanged: _onCheckboxChanged,
        textControllers: textEditingControllers,
      );}),
    );
  }
}
