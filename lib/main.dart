import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:window_size/window_size.dart';
import 'package:just_audio/just_audio.dart';

import 'state.dart';


final double MIN_WIDTH   = 450;
final double MIN_HEIGHT  = 600;

final double MAGIC_WIDTH = 740;


// SUB-WIDGETS //////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

double _dynamicSize(double contextWidth, double minSize, double maxSize) {
  double size = maxSize;
  if ( contextWidth < MAGIC_WIDTH ) {
    final double scale = contextWidth/MAGIC_WIDTH;

    size = minSize + (maxSize - minSize)*scale;
  }

  return size;
}


class _FlounderHeader extends StatelessWidget {
  final FlounderState state;

  const _FlounderHeader({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double contextWidth  = MediaQuery.of(context).size.width;

    final double padding   = 20;
    final double maxWidth  = MAGIC_WIDTH - 2*padding;
    final double maxHeight = 150;

    double width = maxWidth;
    // The width needs to be adapted according
    // to the contextWidth. Hence, set width to
    //       contextWidth - 2*padding
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
        // We omit the padding at the bottom as this
        // is handled by FlounderTimer instead
        padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
        child: Container(
          height: height, width: width,
          child: FittedBox(fit: BoxFit.contain, child: Text(state.mode.id)),
          decoration: BoxDecoration(
            // Increase vivibility by coloring the
            // full box in the respective color
            color: state.mode.color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  } // _FlounderHeader.build
} // _FlounderHeader


class _FlounderTimer extends StatelessWidget {
  final FlounderState state;

  const _FlounderTimer({Key? key, required this.state}) : super(key: key);

  String _buildTimerText() {
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
              _buildTimerText(),
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
  } // _FlounderTimer.build
} // _FlounderTimer


class FlounderBody extends StatelessWidget {
  final FlounderState state;

  const FlounderBody({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FlounderHeader(state: state),
        _FlounderTimer (state: state)
      ],
    );
  } // FlounderBody.build
} // FlounderBody


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
    final double iconSize = _dynamicSize(
      MediaQuery.of(context).size.width, 20, 40
    );

    return BottomAppBar(
      color: state.mode.color,
      //shape: const CircularNotchedRectangle(),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Left Button
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
                color: (state.mode.id == 'Idle') ? Colors.black : Color(0x2b2b2bff),
              ),
            ],
          ),
        ],
      ),
    );
  } // FlounderActionBar.build
} // FlounderActionBar


class FlounderActionButton extends StatelessWidget {
  final FlounderState state;

  final VoidCallback onPressed;

  const FlounderActionButton({
    Key? key,
    required this.state,
    required this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double buttonSize = _dynamicSize(
      MediaQuery.of(context).size.width, 20, 80
    );

    return SizedBox(
      width: buttonSize, height: buttonSize,
      child: FloatingActionButton(
        child: Icon(
          (state.mode.id == 'Idle') ? Icons.play_arrow_rounded : Icons.sync_rounded,
          color: Colors.black,
        ),
        onPressed: onPressed,
        backgroundColor: state.mode.color,
      ),
    );
  } // FlounderActionButton.build
} // FlounderActionButton


class FlounderDrawer extends StatelessWidget {
  final FlounderState state;

  // DropdownButtonProperties
  final String                 dropdownValue;
  final ValueChanged<String?>? onDropdownValueChanged;

  // TextFieldProperties
  final Map controllerMap;

  // ButtonProperties
  final VoidCallback onSaveButtonPressed;

  const FlounderDrawer({
    Key? key,
    required this.state,
    required this.dropdownValue,
    required this.onDropdownValueChanged,
    required this.onSaveButtonPressed,
    required this.controllerMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map textFieldValues = {
      'Talk'      : state.settings.talkLength,
      'Discussion': state.settings.discussionLength,
      'Reminder@' : state.settings.reminderAt,
    };

    List<Widget> customSection = [];
    // Build the input fields with appropriate spacing
    textFieldValues.forEach((key, value) {
      customSection.add(
        TextFormField(
          //initialValue: value.toString(),
          controller: controllerMap[key]..text = textFieldValues[key].toString(),
          style: TextStyle(fontSize: 25, color: Colors.white),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: key,
            labelStyle: TextStyle(fontSize: 20, color: Colors.white),
            suffixText: 'min',
            suffixStyle: TextStyle(fontSize: 25, color: Colors.white),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: state.mode.color,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        ),
      );
      customSection.add(SizedBox(height: 15));
    });
    // Add the button to save the configuration
    customSection.add(
      ElevatedButton(
        child: Text('Save', style: TextStyle(fontSize: 35, color: Colors.white)),
        onPressed: onSaveButtonPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(state.mode.color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: state.mode.color)
            ),
          ),
        ),
      ),
    );

    return Drawer(
      backgroundColor: const Color(0xff1f1f1f),
      child: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'Presets:',
            style: TextStyle(fontSize: 35, color: state.mode.color),
          ),
          SizedBox(height: 15),
          DropdownButton<String>(
            underline: Container(height: 0, color: state.mode.color),
            isExpanded: true,
            value: dropdownValue,
            items: dropdownItems,
            dropdownColor: state.mode.color,
            onChanged: onDropdownValueChanged,
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
          SizedBox(height: 20),
          Text(
            'Custom:',
            style: TextStyle(fontSize: 35, color: state.mode.color),
          ),
          SizedBox(height: 15)
        ]..addAll(customSection),
      ),
    );
  } // FlounderDrawer.build
} // FlounderDrawer


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
      theme: ThemeData(
        primaryColor: const Color(0xff1f1f1f),
      ),
    );
  }
} // Flounder


class FlounderHome extends StatefulWidget {
  const FlounderHome({Key? key}) : super(key: key);

  @override
  State<FlounderHome> createState() => _FlounderHomeState();
} // FlounderHome


class _FlounderHomeState extends State<FlounderHome> {
  FlounderState state = FlounderState(
    presets[FlounderState.DEFAULT_PRESET_KEY]
  );

  // Widget properties
  String dropdownValue = FlounderState.DEFAULT_PRESET_KEY;

  final Map textEditingControllers = {
    'Talk'      : TextEditingController(),
    'Discussion': TextEditingController(),
    'Reminder@' : TextEditingController(),
  };


  // The Timer for async execution of timer changes
  // This initializer executes on empty function once
  Timer runner = Timer(Duration.zero, () {});


  void _playSound() async {
    /*AudioPlayer player = AudioPlayer();
    await player.setAsset('ding.mp3');
    player.play();*/
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
        state.resetTimer();

        runner.cancel();
      }
    });
  }

  void _onBellButtonPressed() {
    setState(() { state.settings.remindMe = !state.settings.remindMe; });
  }

  void _onDropdownValueChanged(String? value) {
    setState(() {
      dropdownValue = value!;

      state.settings = presets[dropdownValue];
      state.resetTimer();
    });
  }

  void _onSaveButtonPressed() {
    setState(() {
      String talkText       = textEditingControllers['Talk'].text;
      String discussionText = textEditingControllers['Discussion'].text;
      String reminderText   = textEditingControllers['Reminder@'].text;

      if (talkText != "") {
        state.settings.talkLength = int.parse(talkText);
      }
      if (discussionText != "") {
        state.settings.discussionLength = int.parse(discussionText);
      }
      if (reminderText != "") {
        state.settings.reminderAt = int.parse(reminderText);
      }

      state.resetTimer();
    });
  }


  @override
  void dispose() {
    // Clean up the TextEditingController's
    textEditingControllers.forEach((key, value) {
      value.dispose();
    });

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f1f1f),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      endDrawerEnableOpenDragGesture: false,
      body: FlounderBody(state: state),
      bottomNavigationBar: Builder(builder: (context) { return FlounderActionBar(
        state: state,
        onPressedL: _onBellButtonPressed,
        onPressedR: () {
          if ( state.mode.id == 'Idle' ) {
            Scaffold.of(context).openEndDrawer();
          }
        }
      );}),
      floatingActionButton: FlounderActionButton(
        state: state,
        onPressed: _onPlayButtonPressed,
      ),
      endDrawer: Builder(builder: (context) { return FlounderDrawer(
        state: state,
        dropdownValue: dropdownValue,
        onDropdownValueChanged: (String? value) {
          _onDropdownValueChanged(value);
          Navigator.of(context).pop();
        },
        onSaveButtonPressed: () {
          _onSaveButtonPressed();
          Navigator.of(context).pop();
        },
        controllerMap: textEditingControllers,
      );}),
    );
  }
} // _FlounderHomeState


// MAIN /////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

void main() {
  if ( kDebugMode ) {
    presets['2+1'] = Settings(2, 1, 2, true);
  }

  // Fill the list of dropdown menu items
  presets.forEach((key, value) => dropdownItems.add(
    DropdownMenuItem<String>(
      value: key,
      child: Text(value.toString(), style: TextStyle(color: Colors.white)),
    )
  ));

  // Set some window properties on desktop platforms
  if ( !kIsWeb ) {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      setWindowTitle('Flounder');
      setWindowMinSize(Size(MIN_WIDTH, MIN_HEIGHT));
    }
  }

  // Run the app
  runApp(const Flounder());
} // main
