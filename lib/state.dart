// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';


class Mode {
  final String id;
  final Color  color;
  final int    increment;

  Mode(this.id, this.color, this.increment);
}


class ModeRegister {
  static final Mode IDLE       = Mode('Idle'      , Colors.green ,  0);
  static final Mode TALK       = Mode('Talk'      , Colors.green , -1);
  static final Mode DISCUSSION = Mode('Discussion', Colors.orange, -1);
  static final Mode OVERTIME   = Mode('Overtime'  , Colors.red   ,  1);
}


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

  TimerProfile clone() {
    return TimerProfile(talkLength, discussionLength, reminderAt);
  }
}


class ProfileCollection {
  final Map _data = {};

  bool _hasChanged = false;

  ProfileCollection();

  ProfileCollection.from(List<TimerProfile> profiles) {
    for (var profile in profiles) {
      _data[profile.key()] = profile.clone();
    }

    _hasChanged = true;
  }

  TimerProfile at(String id) {
    return _data[id].clone();
  }

  TimerProfile first() {
    return _data[_data.keys.first].clone();
  }

  bool includes(id) {
    return _data.containsKey(id);
  }

  List<dynamic> keys() {
    return _data.keys.toList();
  }

  bool hasChanged() {
    return _hasChanged;
  }

  void fixChanges() {
    _hasChanged = false;
  }

  void add(TimerProfile profile) {
    if (!includes(profile.key())) {
      _data[profile.key()] = profile.clone();

      _hasChanged = true;
    }
  }

  void remove(String id) {
    if (includes(id)) {
      _data.removeWhere((key, _) => key == id);

      _hasChanged = true;
    }
  }

  void swap(ProfileCollection profiles) {
    _data.clear();

    for (var key in profiles.keys()) {
      _data[key] = profiles.at(key).clone();
    }

    _hasChanged = true;
  }

  List<String> export() {
    List<String> exportList = [];

    // Fill the list with every available preset
    _data.forEach((_, profile) {
      exportList.add(profile.toString());
    });

    return exportList;
  }
}


ProfileCollection _defaultPresets = ProfileCollection.from([
  TimerProfile(20, 5), TimerProfile(16, 4),
  TimerProfile(12, 3), TimerProfile( 8, 2),
]);


class ApplicationState {
  // MAIN COMPONENTS //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  ///// The main timer that keeps track of the remaining time
  late int timer;

  // The current mode, i.e. either IDLE, TALK, DISCUSSION
  // or OVERTIME
  Mode mode = ModeRegister.IDLE;

  // A map of all available presets
  ProfileCollection presets = _defaultPresets;

  // The currently selected profile
  late TimerProfile profile;

  // LOCAL SETTINGS ///////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  // A flag to determine whether to play an additional
  // reminder DURING the talk
  bool remindMe = false;

  // MEMBER FUNCTIONS /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  ApplicationState() {
    // Initially set the profile to the
    // first element in 'presets' and...
    profile = presets.first();
    // ...reconfigure the state
    reconfigure();
  }

  void reconfigure() {
    timer = profile.talkLength*60;
  }
}
