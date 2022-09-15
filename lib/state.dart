import 'package:flutter/material.dart';


class Mode {
  final String id;
  final Color  color;
  final int    increment;

  Mode(this.id, this.color, this.increment);
}


class ModeRegister {
  //ignore: non_constant_identifier_names
  static final Mode IDLE       = Mode('Idle'      , Colors.green ,  0);
  //ignore: non_constant_identifier_names
  static final Mode TALK       = Mode('Talk'      , Colors.green , -1);
  //ignore: non_constant_identifier_names
  static final Mode DISCUSSION = Mode('Discussion', Colors.orange, -1);
  //ignore: non_constant_identifier_names
  static final Mode OVERTIME   = Mode('Overtime'  , Colors.red   ,  1);
}


class Profile {
  int  talkLength;
  int  discussionLength;
  int  reminderAt;

  Profile(this.talkLength, this.discussionLength, [this.reminderAt = -1]) {
    if ( reminderAt <= 0 ) {
      reminderAt = discussionLength;
    }
  }

  static Profile fromString(String? profileStr) {
    List<String> entries = profileStr!.split("-");

    int  talkLength       = int.parse(entries[0]);
    int  discussionLength = int.parse(entries[1]);
    int  reminderAt       = int.parse(entries[2]);


    return Profile(talkLength, discussionLength, reminderAt);
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

  Profile clone() {
    return Profile(talkLength, discussionLength, reminderAt);
  }
}


class ProfileCollection {
// Always clone any profile

  // The central data structure
  final Map _data = {};

  // A flag to check wether the data structure has been
  // changed since the last call to the commit function
  bool _hasChanged = false;

  ProfileCollection();
  // Empty constructor

  ProfileCollection.from(List<Profile> profiles) {
    for (var profile in profiles) {
      _data[profile.key()] = profile.clone();
    }

    _hasChanged = true;
  }

  Profile at(String id) {
    return _data[id].clone();
  }

  Profile first() {
    if (isEmpty()) return Profile(0, 0);
    
    return _data[_data.keys.first].clone();
  }

  bool includes(id) {
    return _data.containsKey(id);
  }

  List<dynamic> keys() {
    return _data.keys.toList();
  }

  bool isEmpty() {
    return _data.keys.isEmpty;
  }

  bool hasChanged() {
    return _hasChanged;
  }

  void commit() {
    _hasChanged = false;
  }

  void add(Profile profile) {
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

    // Fill the list with every available profiles
    _data.forEach((_, profile) {
      exportList.add(profile.toString());
    });

    return exportList;
  }
}


ProfileCollection defaultPresets = ProfileCollection.from([
  Profile(20, 5), Profile(16, 4),
  Profile(12, 3), Profile( 8, 2),
]);


class ApplicationState {
  // MAIN COMPONENTS //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  // The main timer that keeps track of the remaining time
  int timer = 0;

  // The current mode, i.e. either IDLE, TALK, DISCUSSION or OVERTIME
  Mode mode = ModeRegister.IDLE;

  // A map of all available presets
  ProfileCollection presets = ProfileCollection();

  // The currently selected profile
  Profile profile = Profile(0, 0);

  // LOCAL SETTINGS ///////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  // A flag to determine whether to play an additional reminder DURING the talk
  bool remindMe = true;

  // A flag to determine whether to show the secondary timer
  bool showSecondaryTimer = false;

  // MEMBER FUNCTIONS /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  ApplicationState();
  // Empty constructor

  void reset() {
    timer = profile.talkLength*60;
  }
}
