import 'package:flutter/material.dart';


class Settings {
  int  talkLength;
  int  discussionLength;
  int  reminderAt;
  bool remindMe;

  Settings(this.talkLength, this.discussionLength, [this.reminderAt = -1, this.remindMe = false]) {
    if ( reminderAt <= 0 ) {
      reminderAt = discussionLength;
    }
  }

  @override
  String toString() {
    String talkStr       = talkLength.toString();
    String discussionStr = discussionLength.toString();

    return talkStr + '+' + discussionStr;
  }

  Settings copy() {
    return Settings(talkLength, discussionLength, reminderAt, remindMe);
  }
} // Settings


Map presets = {
  '20+5': Settings(20,  5),
  '16+4': Settings(16,  4),
  '12+3': Settings(12,  3),
   '8+2': Settings( 8,  2),
};
// -->
List< DropdownMenuItem<String> > dropdownItems = [];


class Mode {
  final String id;
  final Color  color;
  final int    increment;

  Mode(this.id, this.color, this.increment);
} // Mode


class ModeRegister {
  static final Mode IDLE       = Mode('Idle'      , Colors.green ,  0);
  static final Mode TALK       = Mode('Talk'      , Colors.green , -1);
  static final Mode DISCUSSION = Mode('Discussion', Colors.orange, -1);
  static final Mode OVERTIME   = Mode('Overtime'  , Colors.red   ,  1);
} // ModeRegister


class FlounderState {
  int      timer = 0;
  Mode     mode  = ModeRegister.IDLE;
  Settings settings;

  // Static members
  static final String DEFAULT_PRESET_KEY = presets.keys.toList().first;

  FlounderState(this.settings) {
    resetTimer();
  }

  void resetTimer() {
    timer = settings.talkLength*60;
  }
} // FlounderState
