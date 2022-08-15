import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'state.dart';


const double MAGIC_WIDTH = 740;


double _getActionBarScale(double contextWidth, double contextHeight, [double factor = 1]) {
  double maxSize = factor*min(40, 0.1*contextHeight);
  double minSize = maxSize/factor/2;

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
    final double contextHeight = MediaQuery.of(context).size.height;

    const double padding   = 20;
    const double maxWidth  = MAGIC_WIDTH - 2*padding;
    const double maxHeight = 150;

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
    final double widthRatio = width/maxWidth;

    // Let the header only cover at most a certain
    // percentage of the full height
    double height = min(maxHeight, 0.25*contextHeight);
    // -->
    final double heightRatio = height/maxHeight;

    // Adjust height/width in such a way that the
    // ratio remains constant
    if ( widthRatio < heightRatio ) {
      height = widthRatio*maxHeight;
    } else {
      width  = heightRatio*maxWidth;
    }

    // Finally, the corner radius is best
    // adapted to the actual height of the box
    final double borderRadius = height/5;

    return Center(
      child: Padding(
        // We omit the padding at the bottom as this
        // is handled by FlounderTimer instead
        padding: const EdgeInsets.fromLTRB(padding, padding, padding, 0),
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
    const double padding = 20;

    return Expanded(
      child: Center(
        child: Padding(
          // For now, a constant -- context independent --
          // padding seems to look fine in all conditions
          padding: const EdgeInsets.all(padding),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              _buildTimerText(),
              style: const TextStyle(
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
    final double iconSize = _getActionBarScale(
      MediaQuery.of(context).size.width, MediaQuery.of(context).size.height
    );

    return BottomAppBar(
      color: state.mode.color,
      //shape: const CircularNotchedRectangle(),
      child: Row(
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
                style: TextStyle(fontSize: 0.75*iconSize)
              ),
            ],
          ),
          // Right button
          Row(
            children: <Widget>[
              Text(
                (state.settings.talkLength + state.settings.discussionLength).toString() + ' min',
                style: TextStyle(fontSize: 0.75*iconSize)
              ),
              SizedBox(width: iconSize/4),
              IconButton(
                icon: const Icon(Icons.access_time_rounded),
                onPressed: onPressedR,
                iconSize: iconSize,
                color: (state.mode.id == 'Idle') ? Colors.black : const Color(0x2b2b2bff),
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
    final double buttonSize = _getActionBarScale(
      MediaQuery.of(context).size.width, MediaQuery.of(context).size.height, 2
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
  final Map controllers;

  // ButtonProperties
  final VoidCallback onSaveButtonPressed;

  const FlounderDrawer({
    Key? key,
    required this.state,
    required this.dropdownValue,
    required this.onDropdownValueChanged,
    required this.onSaveButtonPressed,
    required this.controllers,
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
          controller: controllers[key]..text = textFieldValues[key].toString(),
          style: const TextStyle(fontSize: 25, color: Colors.white),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: key,
            labelStyle: const TextStyle(fontSize: 20, color: Colors.white),
            suffixText: 'min',
            suffixStyle: const TextStyle(fontSize: 25, color: Colors.white),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: state.mode.color,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        ),
      );
      customSection.add(const SizedBox(height: 15));
    });
    // Add the button to save the configuration
    customSection.add(
      ElevatedButton(
        child: const Text('Save', style: TextStyle(fontSize: 35, color: Colors.white)),
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
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'Presets:',
            style: TextStyle(fontSize: 35, color: state.mode.color),
          ),
          const SizedBox(height: 15),
          DropdownButton<String>(
            underline: Container(height: 0, color: state.mode.color),
            isExpanded: true,
            value: dropdownValue,
            items: dropdownItems,
            dropdownColor: state.mode.color,
            onChanged: onDropdownValueChanged,
            style: const TextStyle(color: Colors.black, fontSize: 25),
          ),
          const SizedBox(height: 20),
          Text(
            'Custom:',
            style: TextStyle(fontSize: 35, color: state.mode.color),
          ),
          const SizedBox(height: 15), ...customSection
        ],
      ),
    );
  } // FlounderDrawer.build
} // FlounderDrawer
