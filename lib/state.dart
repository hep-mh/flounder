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
    String isUserDefStr  = isUserDefined.toString();


    return talkStr + '-' + discussionStr + '-' + reminderStr + '-' + remindMeStr + '-' + isUserDefStr;
  }

  static Profile fromString(String? profileStr) {
    List<String>? entries = profileStr?.split("-");

    int  talkLength       = int.parse(entries![0]);
    int  discussionLength = int.parse(entries[1]);
    int  reminderAt       = int.parse(entries[2]);
    bool remindMe         = (entries[3] == '0') ? false : true;
    bool isUserDefined    = (entries[4] == '0') ? false : true;


    return Profile(talkLength, discussionLength, reminderAt, remindMe, isUserDefined);
  }

  Profile copy() {
    return Profile(talkLength, discussionLength, reminderAt, remindMe, isUserDefined);
  }
} // Profile


Map defaultPresets = {
  '20+5': Profile(20,  5),
  '16+4': Profile(16,  4),
  '12+3': Profile(12,  3),
   '8+2': Profile( 8,  2),
};
// --> TODO
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
  int      timer = 0;
  Mode     mode  = ModeRegister.idle;

  // The currently selected profile
  Profile  profile;
  // The state of the CheckBoxTile
  bool     save = true;
  // The available presets
  Map presets = {};

  // The initial preset to display
  // TODO
  static final String initialPresetKey = defaultPresets.keys.toList().first;

  FlounderState(this.profile) {
    resetTimer();
  }

  void resetTimer() {
    timer = profile.talkLength*60;
  }
} // FlounderState
