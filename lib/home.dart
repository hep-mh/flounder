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
        fontFamily: "Roboto"
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

  // The current list of items in the DropdownMenu
  List< DropdownMenuItem<String> > dropdownItems = [];

  // The current value of the DropdownMenu
  String dropdownValue = 'Custom';

  // The controllers used to update the content
  // of the different TextField objects
  final Map textFieldControllers = {
    'Talk'      : TextEditingController(),
    'Discussion': TextEditingController(),
    'Reminder@' : TextEditingController(),
  };

  // The Timer object driving the main clock
  Timer? _runner;

  // The SharedPreferences object to read the
  // user-defined presets
  SharedPreferences? _prefs;

  // The AudioPlayer to play the reminder sound
  final AudioPlayer _player = AudioPlayer();
  // A flag to check if audio is currently playing
  bool _audioIsPlaying = false;

  // UTILITY FUNCTIONS ////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  Future<void> _playSound() async {
    // Only play if not already playing
    if (_audioIsPlaying) return;

    _audioIsPlaying = true;

    await _player.resume();
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
  void _updateTextFields([bool onlyIfEmpty = false]) {
    String talkText       = textFieldControllers['Talk'      ].text;
    String discussionText = textFieldControllers['Discussion'].text;
    String reminderText   = textFieldControllers['Reminder@' ].text;

    if (!onlyIfEmpty || talkText == '') {
      textFieldControllers['Talk'].text = state.profile.talkLength.toString();
    }
    if (!onlyIfEmpty || discussionText == '') {
      textFieldControllers['Discussion'].text = state.profile.discussionLength.toString();
    }
    if (!onlyIfEmpty || reminderText == '') {
      textFieldControllers['Reminder@'].text = state.profile.reminderAt.toString();
    }
  }

  // ACTION FUNCTIONS /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  void _onArrowButtonPressed() {
    setState(() { state.showSecondaryClock = !state.showSecondaryClock;});

    _prefs!.setBool('showSecondaryClock', state.showSecondaryClock);
  }

  void _onSecondaryClockPressed() {
    setState(() { state.timerIsPrimary = !state.timerIsPrimary;});

    _prefs!.setBool('timerIsPrimary', state.timerIsPrimary);
  }
  
  void _onPlayButtonPressed() {
    setState(() {
      // START THE TIMER WHEN IDLE
      if ( state.mode.id == 'Idle' ) {
        // Enable the wakelock when the timer is started
        _toggleWakelock(true);

        state.mode = ModeRegister.TALK;

        _runner = Timer.periodic(const Duration(seconds: 1), (Timer t) {
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
        state.reset();

        _runner!.cancel();
      }
    });
  }

  void _onBellButtonPressed() {
    setState(() { state.remindMe = !state.remindMe; });

    _prefs!.setBool('remindMe', state.remindMe);
  }

  void _onDropdownValueChanged(String? value) {
    setState(() {
      /**/ dropdownValue = value!;

      if (dropdownValue != 'Custom') {
        state.profile = state.presets.at(dropdownValue);
        // --> Reset state on profile change
        state.reset();
      }

      _updateTextFields();
    });
  }

  void _onDeleteButtonPressed() {
    if (dropdownValue == 'Custom') return;

    setState(() {
      state.presets.remove(dropdownValue);

      if (state.presets.isEmpty()) {
        // Keep the current profile
        /**/ dropdownValue = 'Custom';
      } else {
        state.profile = state.presets.first();
        // --> Reset state on profile change
        state.reset();

        /**/ dropdownValue = state.profile.key();
      }
      
      _updateTextFields();
    });

    _prefs!.setStringList('presets', state.presets.export());
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
      // --> Reset state on profile change
      state.reset();

      if (state.presets.includes(state.profile.key())) {
        /**/ dropdownValue = state.profile.key();
      } else {
        /**/ dropdownValue = 'Custom';
      }
    });
  }

  void _onSaveButtonPressed() {
    if (dropdownValue != 'Custom') return;

    setState(() {
      state.presets.add(state.profile);

      /**/ dropdownValue = state.profile.key();
    });

    _prefs!.setStringList('presets', state.presets.export());
  }

  // INIT & DISPOSE FUNCTIONS /////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  Future<void> _loadSoundAssets() async {
    await _player.setSourceAsset('ding.mp3');

    _player.onPlayerComplete.listen((event) {
      _audioIsPlaying = false;
    });
  }
  
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Load the data
    final List<String>? presetsFromPrefs = _prefs!.getStringList('presets');

    final bool? remindMeFromPrefs           = _prefs!.getBool('remindMe');
    final bool? showSecondaryClockFromPrefs = _prefs!.getBool('showSecondaryClock');
    final bool? timerIsPrimaryFromPrefs     = _prefs!.getBool('timerIsPrimary');

    Timer.periodic(const Duration(milliseconds: 5), (Timer t) {
      // Wait for the state to initialize before calling setState
      if (!mounted) return;

      setState(() {
        // 1. PRESETS /////////////////////////////////////////////////////////
        if (presetsFromPrefs != null) {
          ProfileCollection sharedPresets = ProfileCollection();

          for (var presetStr in presetsFromPrefs) {
            Profile profile = Profile.fromString(presetStr);
            // -->
            sharedPresets.add(profile);
          }

          state.presets.swap(sharedPresets);
        } else {
          state.presets.swap(defaultPresets);
        }

        state.profile = state.presets.first();
        // --> Reset state on profile change
        state.reset();

        if (presetsFromPrefs?.isNotEmpty ?? true) {
          /**/ dropdownValue = state.profile.key();
        } // else remain 'Custom'

        _updateTextFields();

        // 2. REMIND_ME ///////////////////////////////////////////////////////
        if (remindMeFromPrefs != null) {
          state.remindMe = remindMeFromPrefs;
        }

        // 3. SHOW_SECONDARY_CLOCK ////////////////////////////////////////////
        if (showSecondaryClockFromPrefs != null) {
          state.showSecondaryClock = showSecondaryClockFromPrefs;
        }

        // 4. TIMER_IS_PRIMARY ////////////////////////////////////////////////
        if (timerIsPrimaryFromPrefs != null) {
          state.timerIsPrimary = timerIsPrimaryFromPrefs;
        }
      });

      t.cancel();
    });
  }

  @override
  void initState() {
    super.initState();

    Future.wait([
      _loadSoundAssets(),
      _loadPreferences()
    ]);

    // Ensure that the navigation bar has a matching color on
    // Android devices
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
    // Dispose of the Timer
    _runner!.cancel();

    // Dispose of the AudioPlayer
    _player.dispose();

    // Dispose of the TextEditingController's
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
    
    state.presets.commit();

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
    // If the height is too small, do not draw anything at all
    final double contextHeight = MediaQuery.of(context).size.height;
    if (contextHeight < 200) {
      return const Scaffold(backgroundColor: Color(0xff1f1f1f));
    }

    _buildDropdownMenuIfNeeded();

    return Scaffold(
      backgroundColor: const Color(0xff1f1f1f),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      endDrawerEnableOpenDragGesture: (state.mode.id == 'Idle'),
      // 1. FLOUNDER_BODY /////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////
      body: FlounderBody(
        state: state,
        onArrowButtonPressed: _onArrowButtonPressed,
        onSecondaryClockPressed: _onSecondaryClockPressed
      ),
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
      endDrawer: FlounderDrawer(
        state: state,
        dropdownValue: dropdownValue,
        dropdownItems: dropdownItems,
        onDropdownValueChanged: _onDropdownValueChanged,
        onDeleteButtonPressed: _onDeleteButtonPressed,
        textFieldControllers: textFieldControllers,
        onAnyTextFieldChanged: _onAnyTextFieldChanged,
        onAnyTextFieldFocusChanged: (bool? hasFocus) {
          setState(() {
            if (!hasFocus!) {
            _updateTextFields(true); // onlyIfEmpty
            }
          });
        },
        onSaveButtonPressed: _onSaveButtonPressed,
      ),
    );
  }
}
