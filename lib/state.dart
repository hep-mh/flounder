import 'package:flutter/material.dart';


class Profile {
  int  talkLength;
  int  discussionLength;
  int  reminderAt;
  bool remindMe;
  bool isUserDefined;

  Profile(this.talkLength, this.discussionLength, [this.reminderAt = -1, this.remindMe = false, this.isUserDefined = false]) {
    if ( reminderAt <= 0 ) {
      reminderAt = discussionLength;
    }
  }

  String dropdownEntry() {
    String talkStr       = talkLength.toString();
    String discussionStr = discussionLength.toString();

    return talkStr + '+' + discussionStr;
  }

  @override
  String toString() {
    String talkStr       = talkLength.toString();
    String discussionStr = discussionLength.toString();
    String reminderStr   = reminderAt.toString();
    String remindMeStr   = remindMe.toString();
    String isUserStr     = isUserDefined.toString();


    return talkStr + ' ' + discussionStr + ' ' + reminderStr + ' ' + remindMeStr + ' ' + isUserStr;
  }

  Profile copy() {
    return Profile(talkLength, discussionLength, reminderAt, remindMe, isUserDefined);
  }
} // Profile


Map presets = {
  '20+5': Profile(20,  5),
  '16+4': Profile(16,  4),
  '12+3': Profile(12,  3),
   '8+2': Profile( 8,  2),
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

  // The currently selected profile
  Profile  profile;
  // The state of the CheckBoxTile
  bool     save = true;

  // Static members
  static final String DEFAULT_PRESET_KEY = presets.keys.toList().first;

  FlounderState(this.profile) {
    resetTimer();
  }

  void resetTimer() {
    timer = profile.talkLength*60;
  }
} // FlounderState
