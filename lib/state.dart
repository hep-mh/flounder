import 'package:flutter/material.dart';


class Profile {
  int  talkLength;
  int  discussionLength;
  int  reminderAt;

  Profile(this.talkLength, this.discussionLength, [this.reminderAt = -1]) {
    if ( reminderAt <= 0 ) {
      reminderAt = discussionLength;
    }
  }

  String key() {
    String talkStr       = talkLength.toString();
    String discussionStr = discussionLength.toString();
    String reminderStr   = reminderAt.toString();

    return talkStr + '+' + discussionStr + ' (' + reminderStr + ')';
  }

  @override
  String toString() {
    String talkStr       = talkLength.toString();
    String discussionStr = discussionLength.toString();
    String reminderStr   = reminderAt.toString();


    return talkStr + '-' + discussionStr + '-' + reminderStr;
  }

  static Profile fromString(String? profileStr) {
    List<String>? entries = profileStr?.split("-");

    int  talkLength       = int.parse(entries![0]);
    int  discussionLength = int.parse(entries[1]);
    int  reminderAt       = int.parse(entries[2]);


    return Profile(talkLength, discussionLength, reminderAt);
  }

  Profile copy() {
    return Profile(talkLength, discussionLength, reminderAt);
  }
} // Profile


Map defaultPresets = {
  '20+5 (5)': Profile(20,  5),
  '16+4 (4)': Profile(16,  4),
  '12+3 (3)': Profile(12,  3),
   '8+2 (2)': Profile( 8,  2),
};
// --> TODO Should not be here
List< DropdownMenuItem<String> > dropdownItems = [];


class Mode {
  final String id;
  final Color  color;
  final int    increment;

  Mode(this.id, this.color, this.increment);
} // Mode


class ModeRegister {
  static final Mode idle       = Mode('Idle'      , Colors.green ,  0);
  static final Mode talk       = Mode('Talk'      , Colors.green , -1);
  static final Mode discussion = Mode('Discussion', Colors.orange, -1);
  static final Mode overtime   = Mode('Overtime'  , Colors.red   ,  1);
} // ModeRegister


class FlounderState {
  int  timer = 0;
  Mode mode  = ModeRegister.idle;

  // The available presets
  late Map     presets; // FlounderState -> setPresets
  // The current profile selected
  // from the available presets
  late Profile profile; // FlounderState -> setPresets

  // The flag to determine wether to
  // save custom profiles
  bool         save     = true;
  // A flag to determine wether to play
  // a reminder during the talk
  bool         remindMe = false;

  FlounderState() {
    // First set the list of all presets to its default
    // value; Later update the set if preferences are found
    swapPresets(defaultPresets);
    resetTimer();
  }

  void swapPresets(Map newPresets) {
    presets = newPresets;

    // -->
    profile = presets[presets.keys.toList().first].copy();
  }

  void resetTimer() {
    timer = profile.talkLength*60;
  }
} // FlounderState
