import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:floating/floating.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'layout.dart';
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
        textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionColor: Colors.grey,
            selectionHandleColor: Colors.grey,
        ),
        fontFamily: 'Roboto'
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

  // The PackageInfo object to extract the
  // current Flounder version
  PackageInfo? _packageInfo;

  // The Floating object to enable PiP on Android
  final Floating _floating = Floating();
  // A flag to store whether the device supports (automatic) PiP
  bool _pipIsSupported = false;

  // The AudioPlayer object to play the reminder sound
  final AudioPlayer _player = AudioPlayer();
  // A flag to check if audio is currently playing
  bool _audioIsPlaying = false;

  // A flag to check whether the state is fully initialized
  bool _stateIsInitialized = false;

  // The current version of Flounder
  String _version = '0.0.0';

  // UTILITY FUNCTIONS //////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  Future<void> _playSound() async {
    // Only play if not already playing
    if (_audioIsPlaying) return;

    _audioIsPlaying = true;

    //await _player.play( AssetSource('ding.mp3') );
    await _player.resume();
  }

  void _toggleWakelock(bool enable) {
    WakelockPlus.toggle(enable: enable);
  }

  void _toggleAutoPip(bool enable) {
    if (_pipIsSupported) {
      _floating.toggleAutoPip(autoEnter: enable);
    }
  }

  // HELPER FUNCTIONS ///////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  void _updateTextFields([bool onlyIfEmpty = false]) {
    final String talkText       = textFieldControllers['Talk'      ].text;
    final String discussionText = textFieldControllers['Discussion'].text;
    final String reminderText   = textFieldControllers['Reminder@' ].text;

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

  // ACTION FUNCTIONS ///////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
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
        // Enable the wakelock while the timer is running
        _toggleWakelock(true);
        // Enable automatic PiP mode while the timer is running
        _toggleAutoPip(true);

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
        // Disable automatic PiP mode when the timer is stopped
        _toggleAutoPip(false);

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

    /**/ _prefs!.setString('activeDropdownValue', dropdownValue);
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

    /**/ _prefs!.setString('activeDropdownValue', dropdownValue);
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

    if ( dropdownValue != 'Custom' ) {
      /**/ _prefs!.setString('activeDropdownValue', dropdownValue);
    }
  }

  void _onSaveButtonPressed() {
    if (dropdownValue != 'Custom') return;

    setState(() {
      state.presets.add(state.profile);

      /**/ dropdownValue = state.profile.key();
    });

    _prefs!.setStringList('presets', state.presets.export());

    /**/ _prefs!.setString('activeDropdownValue', dropdownValue);
  }

  // INIT & DISPOSE FUNCTIONS ///////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  Future<void> _loadSoundAssets() async {
     await _player.setSource(AssetSource('ding.mp3'));

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

    final String? activeDropdownValueFromPrefs = _prefs!.getString('activeDropdownValue');

    Timer.periodic(const Duration(milliseconds: 5), (Timer t) {
      // Wait for the state to initialize before calling setState
      if (!mounted) return;

      setState(() {
        // 1. PRESETS /////////////////////////////////////////////////////////
        if (presetsFromPrefs != null) {
          final ProfileCollection sharedPresets = ProfileCollection();

          for (var presetStr in presetsFromPrefs) {
            final Profile profile = Profile.fromString(presetStr);
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

        // 5. ACTIVE_DROPDOWN_VALUE ///////////////////////////////////////////
        if (activeDropdownValueFromPrefs != null) {
          if (state.presets.includes(activeDropdownValueFromPrefs)) {
            state.profile = state.presets.at(activeDropdownValueFromPrefs);
            // --> Reset state on profile change
            state.reset();

            /**/ dropdownValue = state.profile.key();
          } // else do nothing, e.g. if 'Custom'
        }

        // CLEANUP
        _updateTextFields();

        // Mark the state as initialized
        _stateIsInitialized = true;
      });

      t.cancel();
    });
  }

  Future<void> _loadPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();

    _version = _packageInfo!.version;
  }

  Future<void> _checkAutoPipAvailability() async {
    if (!kIsWeb) { if (Platform.isAndroid) {
      _pipIsSupported = await _floating.isAutoPipAvailable;
    }}
  }

  @override
  void initState() {
    super.initState();

    // Check if the current device supports PiP
    Future.wait([_checkAutoPipAvailability()]);

    // Load the relevant assets and preferences
    Future.wait([
      _loadSoundAssets(),
      _loadPreferences(),
      _loadPackageInfo()
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

    // Dispose of the Floating object
    _floating.dispose();

    // Dispose of the AudioPlayer
    _player.dispose();

    // Dispose of the TextEditingController's
    textFieldControllers.forEach((key, value) {
      value.dispose();
    });

    super.dispose();
  }

  // BUILD FUNCTIONS ////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  void _buildDropdownMenuIfNeeded() {
    // Only run if necessary
    if (!state.presets.hasChanged()) return;
    // Otherwise commit and rebuild
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
    // If the state is not yet fully initialized (i.e. the settings have
    // not yet been read), draw an empty container. This way, the timer
    // does not jump from 00:00 to its initial value
    if (!_stateIsInitialized) {
      return Container(color: const Color(0xff1f1f1f));
    }

    _buildDropdownMenuIfNeeded();

    // Build the PIP_SCREEN /////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////
    final Widget pip = Material(
      color: const Color(0xff1f1f1f),
      child: FlounderPip(state: state)
    );

    // Build the MAIN_SCREEN ////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////
    Widget home = Scaffold(
      backgroundColor: const Color(0xff1f1f1f),
      resizeToAvoidBottomInset: false,
      endDrawerEnableOpenDragGesture: (state.mode.id == 'Idle'),
      // 1. FLOUNDER_BODY ///////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////
      body: FlounderBody(
        state: state,
        onArrowButtonPressed: _onArrowButtonPressed,
        onSecondaryClockPressed: _onSecondaryClockPressed
      ),
      // 2. FLOUNDER_ACTION_BAR /////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////
      bottomNavigationBar: Builder(builder: (context) { return FlounderActionBar(
        state: state,
        onPressedL: _onBellButtonPressed,
        onPressedR: () {
          if (state.mode.id == 'Idle') {
            Scaffold.of(context).openEndDrawer();
          }
        }
      );}),
      // 3. FLOUNDER_ACTION_BUTTON //////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////
      floatingActionButton: FlounderActionButton(
        state: state,
        onPressed: _onPlayButtonPressed,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // 4. FLOUNDER_DRAWER /////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////////////////////////////////////
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
        version: _version
      ),
    );

    // If the height of the window is too small, draw an empty container instead
    // (potentially with a resize indicator)
    final Size contextSize = MediaQuery.of(context).size;
    if (contextSize.height < minRenderHeight || contextSize.width < minRenderWidth) {
      home = Container(color: const Color(0xff1f1f1f));
    }

    // RETURN ///////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////
    if (_pipIsSupported) {
      return PiPSwitcher(
        childWhenDisabled: home,
        childWhenEnabled: pip
      );
    }

    // in any other case
    return home;
  }
}
