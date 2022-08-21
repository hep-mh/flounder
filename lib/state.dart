import 'package:flutter/material.dart';


class TimerProfile {
  int  talkLength;
  int  discussionLength;
  int  reminderAt;

  TimerProfile(this.talkLength, this.discussionLength, [this.reminderAt = -1]) {
    if ( reminderAt <= 0 ) {
      reminderAt = discussionLength;
    }
  }

  static TimerProfile fromString(String? profileStr) {
    List<String> entries = profileStr!.split("-");

    int  talkLength       = int.parse(entries[0]);
    int  discussionLength = int.parse(entries[1]);
    int  reminderAt       = int.parse(entries[2]);


    return TimerProfile(talkLength, discussionLength, reminderAt);
  }

  @override
  String toString() {
    String talkStr       = talkLength.toString();
    String discussionStr = discussionLength.toString();
    String reminderStr   = reminderAt.toString();


    return talkStr + '-' + discussionStr + '-' + reminderStr;
  }

  String key() {
    String talkStr       = talkLength.toString();
    String discussionStr = discussionLength.toString();
    String reminderStr   = reminderAt.toString();

    return talkStr + '+' + discussionStr + ' (' + reminderStr + ')';
  }

  TimerProfile copy() {
    return TimerProfile(talkLength, discussionLength, reminderAt);
  }
}


Map defaultPresets = {
  '20+5 (5)': TimerProfile(20, 5),
  '16+4 (4)': TimerProfile(16, 4),
  '12+3 (3)': TimerProfile(12, 3),
   '8+2 (2)': TimerProfile( 8, 2),
};


class Mode {
  final String id;
  final Color  color;
  final int    increment;

  Mode(this.id, this.color, this.increment);
}


class ModeRegister {
  static final Mode idle       = Mode('Idle'      , Colors.green ,  0);
  static final Mode talk       = Mode('Talk'      , Colors.green , -1);
  static final Mode discussion = Mode('Discussion', Colors.orange, -1);
  static final Mode overtime   = Mode('Overtime'  , Colors.red   ,  1);
}


class ApplicationState {
  // The current mode, i.e. either
  // IDLE, TALK, DISCUSSION or OVERTIME
  Mode mode = ModeRegister.idle;
  // The main timer that keeps
  // track of the remaining time
  late int timer;

  // A map of all available presets
  Map presets = defaultPresets;
  // The currently selected profile
  late TimerProfile profile;

  // LOCAL SETTINGS
  // A flag to determine whether
  // to save custom profiles
  bool save     = false;
  // A flag to determine whether to
  // play an additional reminder
  // DURING the talk
  bool remindMe = false;

  ApplicationState() {
    // Initially set the profile to the
    // first element in 'presets' and...
    profile = presets[presets.keys.first].copy();
    // ...initialize the timer accordingly
    timer = profile.talkLength*60;
  }

  void swapPresets(Map newPresets) {
    presets = newPresets;
    // Select a new profile, as
    // the old one might be invalid
    profile = presets[presets.keys.first].copy();
  }

  List<String> exportPresets() {
    List<String> exportList = [];

    // Fill the list with every
    // available preset
    presets.forEach((key, value) {
      exportList.add(value.toString());
    });

    return exportList;
  }

  void resetTimer() {
    timer = profile.talkLength*60;
  }
}
