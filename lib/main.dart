import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart';


final double MIN_WIDTH  = 450;
final double MIN_HEIGHT = 600;

final double MAGIC_WIDTH = 740;


// CONFIGURATION ////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////


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

  String toString() {
    String talkStr       = talkLength.toString();
    String discussionStr = discussionLength.toString();

    return talkStr + '+' + discussionStr;
  }
} // Settings


Map _presets = {
  '20+5': Settings(20,  5),
  '16+4': Settings(16,  4),
  '12+3': Settings(12,  3),
   '8+2': Settings( 8,  2),
};
//-->
final String INITIAL_PRESET_KEY = _presets.keys.toList().first;

class Mode {
  final String id;
  final Color  color;
  final int    increment;

  Mode(this.id, this.color, this.increment);
} // Mode


class ModeRegister {
  static final Mode IDLE       = Mode('Idle', Colors.green, 0);
  static final Mode TALK       = Mode('Talk', Colors.green, -1);
  static final Mode DISCUSSION = Mode('Discussion', Colors.orange, -1);
  static final Mode OVERTIME   = Mode('Overtime', Colors.red, 1);
} // ModeRegister


class FlounderState {
  int      timer = 0;
  Mode     mode = ModeRegister.IDLE;
  Settings settings;

  FlounderState(this.settings) {
    reset_timer();
  }

  void reset_timer() {
    timer = settings.talkLength*60;
  }
} // FlounderState

// SUB-WIDGETS //////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

double _scaledSize(double contextWidth, double minSize, double maxSize) {
  double size = maxSize;
  if ( contextWidth < MAGIC_WIDTH ) {
    final double scale = contextWidth/MAGIC_WIDTH;

    size = minSize + (maxSize - minSize)*scale;
  }

  return size;
}


class FlounderHeader extends StatelessWidget {
  final FlounderState state;

  const FlounderHeader({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double contextWidth  = MediaQuery.of(context).size.width;

    final double padding   =  20;
    final double maxWidth  = MAGIC_WIDTH - 2*padding;
    final double maxHeight = 150;

    double width = maxWidth;
    // The width needs to be adapted according
    // to the contextWidth. Hence, set width to
    // contextWidth - 2*padding
    // if the box covers the full width of the
    // application
    if ( contextWidth < MAGIC_WIDTH ) {
      width = contextWidth - 2*padding;
    }
    // -->
    final double ratio = width/maxWidth;

    // Adjust the height in such a way that the
    // ratio remains constant
    final double height = ratio*maxHeight;

    // Finally, the corner radius is best
    // adapted to the actual height of the box
    final double borderRadius = height/5;

    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
        child: Container(
          height: height, width: width,
          child: FittedBox(fit: BoxFit.contain, child: Text(state.mode.id)),
          decoration: BoxDecoration(
            color: state.mode.color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  } // FlounderHeader.build
} // FlounderHeader


class FlounderTimer extends StatelessWidget {
  final FlounderState state;

  const FlounderTimer({Key? key, required this.state}) : super(key: key);

  String _get_timer_text() {
    int min = state.timer ~/ 60;
    int sec = state.timer - min*60;

    String minStr = (min < 10) ? '0' + min.toString() : min.toString();
    String secStr = (sec < 10) ? '0' + sec.toString() : sec.toString();

    return minStr + ':' + secStr;
  }

  @override
  Widget build(BuildContext context) {
    final double padding = 20;

    return Expanded(
      child: Center(
        child: Padding(
          // For now, a constant -- context independent --
          // padding seems to look fine in all conditions
          padding: EdgeInsets.all(padding),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              _get_timer_text(),
              style: TextStyle(
                // This is the maximal font size, which will
                // be scaled down by the FittedBox if needed
                fontSize: 400,
                // We keep the text white and update the remaining
                // colors of the UI to indicate the current state
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  } // FlounderTimer.build
} // FlounderTimer


class FlounderActionBar extends StatelessWidget {
  final FlounderState state;

  final VoidCallback onPressedL;
  final VoidCallback onPressedR;

  const FlounderActionBar({
    Key? key,
    required this.state,
    required this.onPressedL,
    required this.onPressedR
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double iconSize = _scaledSize(
      MediaQuery.of(context).size.width, 20, 40
    );

    return BottomAppBar(
      color: state.mode.color,
      shape: const CircularNotchedRectangle(),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // LeftButton
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  (state.settings.remindMe == true) ? Icons.notifications_active_outlined
                                                    : Icons.notifications_none
                ),
                onPressed: onPressedL,
                iconSize: iconSize,
              ),
              SizedBox(width: iconSize/4),
              Text(
                state.settings.reminderAt.toString() + ' min',
                style: TextStyle(fontSize: 20)
              ),
            ],
          ),
          // Right button
          Row(
            children: <Widget>[
              Text(
                (state.settings.talkLength + state.settings.discussionLength).toString() + ' min',
                style: TextStyle(fontSize: 20)
              ),
              SizedBox(width: iconSize/4),
              IconButton(
                icon: Icon(Icons.access_time_rounded),
                onPressed: onPressedR,
                iconSize: iconSize,
              ),
            ],
          ),
        ],
      ),
    );
  } // FlounderActionBar.build
} // FlounderActionBar


class FlounderActionButton {
}

// HOMEPAGE /////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

List< DropdownMenuItem<String> > dropdownItems = [];


class Flounder extends StatelessWidget {
  const Flounder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flounder',
      home: const FlounderHome(),
    );
  }
} // Flounder


class FlounderHome extends StatefulWidget {
  const FlounderHome({Key? key}) : super(key: key);

  @override
  State<FlounderHome> createState() => _FlounderHomeState();
} // FlounderHome


class _FlounderHomeState extends State<FlounderHome> {
  // The initial state of the application
  String selectedItem = INITIAL_PRESET_KEY;
  // -->
  FlounderState state = FlounderState(_presets[INITIAL_PRESET_KEY]);

  // The runner for async execution of the time
  // This initializer executes on empty function once
  Timer runner = Timer(Duration.zero, () {});

  void _playSound() {
    print('Sound!');
  }

  void _onPlayButtonPressed() {
    setState(() {
      if ( state.mode.id == 'Idle' ) {
        state.mode = ModeRegister.TALK;

        runner = Timer.periodic(Duration(seconds: 1), (Timer t) {
          setState(() {
            // Check if a reminder needs to be given
            if ( state.timer == state.settings.reminderAt*60 ) {
              if ( state.settings.remindMe && state.mode.id == 'Talk' ) { _playSound(); }
            }

            // Increment the timer
            state.timer += state.mode.increment;

            // Check if switch to discussion/overtime is necessary
            if ( state.timer == 0 ) {
              _playSound();

              switch(state.mode.id) {
                // Talk -> Discussion
                case 'Talk': {
                  state.mode  = ModeRegister.DISCUSSION;
                  state.timer = state.settings.discussionLength*60;
                  break;
                }
                // Discussion -> Overtime
                case 'Discussion': {
                  state.mode  = ModeRegister.OVERTIME;
                  break;
                }
              }
            }
          });
        });
      } else {
        state.mode = ModeRegister.IDLE;
        state.reset_timer();

        runner.cancel();
      }
    });
  }

  void _onBellButtonPressed() {
    setState(() { state.settings.remindMe = !state.settings.remindMe; });
  }

  void _onDropdownItemChange(String? value) {
    setState(() {
      selectedItem = value!;

      state.settings = _presets[selectedItem];
      state.reset_timer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = _scaledSize(
      MediaQuery.of(context).size.width, 20, 80
    );

    return Scaffold(
      backgroundColor: const Color(0xff1f1f1f),
      body: Column(
        children: <Widget>[
          FlounderHeader(state: state),
          FlounderTimer (state: state)
        ],
      ),
      bottomNavigationBar: Builder(builder: (context) {
        return FlounderActionBar(
          state: state,
          onPressedL: _onBellButtonPressed,
          onPressedR: () {
            if ( state.mode.id == 'Idle' ) {
              Scaffold.of(context).openEndDrawer();
            }
          }
        );
      }),
      floatingActionButton: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
          child: Icon(
            (state.mode.id == 'Idle') ? Icons.play_arrow_rounded : Icons.sync_rounded,
            color: Colors.black,
          ),
          onPressed: _onPlayButtonPressed,
          backgroundColor: state.mode.color,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Builder(builder: (context) {
          return Drawer(
          backgroundColor: const Color(0xff1f1f1f),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: <Widget>[
              Text(
                'Presets:',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              DropdownButton<String>(
                underline: Container(height: 2, color: state.mode.color),
                isExpanded: true,
                value: selectedItem,
                items: dropdownItems,
                dropdownColor: const Color(0xff1f1f1f),
                onChanged: (String? value) {_onDropdownItemChange(value!); Navigator.of(context).pop();},
                style: TextStyle(color: Colors.black, fontSize: 25),
              ),
              SizedBox(height: 20),
              Text(
                'Custom:',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
            ]
          ),
        );
      }),
    );
  }
} // _FlounderHomeState


// MAIN /////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

void main() {
  if ( kDebugMode ) {
    _presets['2+1'] = Settings(2, 1);
  }

  _presets.forEach((key, value) => dropdownItems.add(
    DropdownMenuItem<String>(
      value: key,
      child: Text(value.toString(), style: TextStyle(color: Colors.white)),
    )
  ));

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    setWindowTitle('Flounder');
    setWindowMinSize(Size(MIN_WIDTH, MIN_HEIGHT));
  }

  runApp(const Flounder());
} // main
