import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'layout.dart';
import 'state.dart';


class FlounderHeader extends StatelessWidget {
  final ApplicationState state;

  final Size size;

  const FlounderHeader({
    Key? key,
    required this.state,
    required this.size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width  = size.width;
    final double height = size.height;

    // -->
    final double borderRadius = height/5;

    return Container(
      height: height, width: width,
      decoration: BoxDecoration(
        // Increase visibility by coloring the
        // full box in the respective color
        color: state.mode.color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FittedBox(fit: BoxFit.contain, child: Text(state.mode.id))
    );
  }
}


abstract class FlounderClock extends StatelessWidget {
  final ApplicationState state;

  const FlounderClock({Key? key, required this.state}) : super(key: key);

  String _getTimerText(); // abstract method

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Text(
        _getTimerText(),
        style: const TextStyle(
          // This is the maximal font size, which will
          // be scaled down by the FittedBox if needed
          fontSize: 400,
          // We keep the text white and update the remaining
          // colors of the UI to indicate the current state
          color: Colors.white,
        )
      )
    );
  }
}


class FlounderTimer extends FlounderClock {
  const FlounderTimer({Key? key, required state}) : super(key: key, state: state);

  @override
  String _getTimerText() {
    final int min = state.timer ~/ 60;
    final int sec = state.timer - min*60;

    final String minStr = (min < 10) ? '0${min.toString()}' : min.toString();
    final String secStr = (sec < 10) ? '0${sec.toString()}' : sec.toString();

    return '$minStr:$secStr';
  }
}


class FlounderStopwatch extends FlounderClock {
  const FlounderStopwatch({Key? key, required state}) : super(key: key, state: state);

  @override
  String _getTimerText() {
    late int inverseTimer;
    if (state.mode.id == 'Idle' || state.mode.id == 'Talk') {
      inverseTimer = state.profile.talkLength*60 - state.timer;
    } else if (state.mode.id == 'Discussion') {
      inverseTimer = state.profile.discussionLength*60 - state.timer;
    } else if (state.mode.id == 'Overtime') {
      inverseTimer = state.timer;
    }

    final int min = inverseTimer ~/ 60;
    final int sec = inverseTimer - min*60;

    final String minStr = (min < 10) ? '0${min.toString()}' : min.toString();
    final String secStr = (sec < 10) ? '0${sec.toString()}' : sec.toString();

    return '$minStr:$secStr';
  }
}


class FlounderPip extends StatelessWidget {
  final ApplicationState state;

  const FlounderPip({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FlounderClock primaryClock = state.timerIsPrimary ? FlounderTimer(state: state) : FlounderStopwatch(state: state);

    // Define the width of the indicator line
    final double indicatorWidth  = 0.4*MediaQuery.of(context).size.width;

    // Define a context-dependent padding
    final double padding = 0.1*MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Center(child: Padding(
          padding: EdgeInsets.all(padding),
          child: primaryClock
        )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: padding/2),
            child: Container(
              height: padding/2, width: indicatorWidth,
              decoration: BoxDecoration(
                color: state.mode.color,
                borderRadius: BorderRadius.circular(padding/4), // height = padding/2
              ),
              child: const SizedBox.shrink(),
            )
          )
        )
      ]
    );
  }
}


class FlounderBody extends StatelessWidget {
  final ApplicationState state;

  final VoidCallback onArrowButtonPressed;
  final VoidCallback onSecondaryClockPressed;

  // For now, a constant -- context independent --
  // padding seems to look fine in all conditions
  final double padding = bodyPadding;

  const FlounderBody({
    Key? key,
    required this.state,
    required this.onArrowButtonPressed,
    required this.onSecondaryClockPressed
  }) : super(key: key);

  Size _getHeaderSize(BuildContext context) {
    final double contextWidth  = MediaQuery.of(context).size.width;
    final double contextHeight = MediaQuery.of(context).size.height;

    final double maxWidth  = magicWidth - 2*padding;
    const double maxHeight = 150;

    double width = maxWidth;
    // The width needs to be adapted according
    // to the contextWidth. Hence, set width to
    //       contextWidth - 2*padding
    // if the box covers the full width of the
    // application
    if ( contextWidth < magicWidth ) {
      width = contextWidth - 2*padding;
    }
    // -->
    final double widthRatio = width/maxWidth;

    // The height needs to be adjusted according
    // to the contextHeight. Here, we force the
    // header to cover at most 20% of the full
    // height of the window
    double height = min(maxHeight, 0.2*contextHeight);
    // -->
    final double heightRatio = height/maxHeight;

    // Adjust height/width in such a way that the
    // ratio remains constant
    if ( widthRatio < heightRatio ) {
      height = widthRatio*maxHeight;
    } else {
      width  = heightRatio*maxWidth;
    }

    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    final double arrowSize = getDynamicScale(
      MediaQuery.of(context).size.width, MediaQuery.of(context).size.height, 1.25
    );

    final FlounderClock primaryClock   = state.timerIsPrimary ? FlounderTimer    (state: state) : FlounderStopwatch(state: state);
    final FlounderClock secondaryClock = state.timerIsPrimary ? FlounderStopwatch(state: state) : FlounderTimer    (state: state);

    return SafeArea(
      child: Column(
        children: [
          Center(child: Padding(
            padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
            // 1. The FLOUNDER_HEADER displaying the current mode ///////////////////////
            /////////////////////////////////////////////////////////////////////////////
            child: FlounderHeader(state: state, size: _getHeaderSize(context)),
          )),
          Expanded(
            child: Stack(
              children: [
                Center(child: Padding(
                  padding: EdgeInsets.all(padding),
                  // 2. The primary instance of FLOUNDER_CLOCK /////////////////////////
                  ///////////////////////////////////////////////////////////////////////
                  child: primaryClock
                )),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 3. The secondary instance of FLOUNDER_CLOCK ////////////////////
                      ///////////////////////////////////////////////////////////////////
                      MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(
                        onTap: onSecondaryClockPressed,
                        child: state.showSecondaryClock ?
                                 SizedBox(height: arrowSize+10, child: secondaryClock) : const SizedBox.shrink()
                      )),
                      // 4. The ICON_BUTTON to show/hide the secondary timer ////////////
                      ///////////////////////////////////////////////////////////////////
                      IconButton(
                        icon: Icon(
                          state.showSecondaryClock ? Icons.arrow_right_rounded : Icons.arrow_left_rounded,
                          color: Colors.white
                        ),
                        splashRadius: arrowSize/2,
                        onPressed: onArrowButtonPressed,
                        iconSize: arrowSize
                      )
                    ]
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }
}


class FlounderActionBar extends StatelessWidget {
  final ApplicationState state;

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
    final double iconSize = getDynamicScale(
      MediaQuery.of(context).size.width, MediaQuery.of(context).size.height
    );

    // For now, a constant -- context independent --
    // padding seems to look fine in all conditions
    const double padding = actionBarPadding;
    
    // Adapt the border raduis to the height of the action bar
    final double borderRadius = iconSize/4;

    return Container(
      padding: const EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        child: BottomAppBar(
          color: state.mode.color,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 1. Left ICON_BUTTON ////////////////////////////////////////////////////////
              ///////////////////////////////////////////////////////////////////////////////
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      (state.remindMe == true) ? Icons.notifications_active_outlined
                                               : Icons.notifications_off_outlined
                    ),
                    onPressed: onPressedL,
                    iconSize: iconSize,
                  ),
                  SizedBox(width: iconSize/4),
                  Text(
                    '${state.profile.reminderAt.toString()} min',
                    style: TextStyle(fontSize: 0.75*iconSize)
                  ),
                ],
              ),
              // 2. Right ICON_BUTTON ///////////////////////////////////////////////////////
              ///////////////////////////////////////////////////////////////////////////////
              Row(
                children: <Widget>[
                  Text(
                    '${state.profile.talkLength.toString()}+${state.profile.discussionLength.toString()} min',
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
              )
            ]
          )
        )
      )
    );
  }
}


class FlounderActionButton extends StatelessWidget {
  final ApplicationState state;

  final VoidCallback onPressed;

  const FlounderActionButton({
    Key? key,
    required this.state,
    required this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double buttonSize = getDynamicScale(
      MediaQuery.of(context).size.width, MediaQuery.of(context).size.height, 2
    );

    return SizedBox(
      width: buttonSize, height: buttonSize,
      child: FloatingActionButton(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(15))
        // ),
        onPressed: onPressed,
        backgroundColor: state.mode.color,
        child: Icon(
          (state.mode.id == 'Idle') ? Icons.play_arrow_rounded : Icons.sync_rounded,
          color: Colors.black,
          size: 0.6*buttonSize,
        )
      )
    );
  }
}


class FlounderDrawer extends StatelessWidget {
  final ApplicationState state;

  // DropdownButton properties
  final List<DropdownMenuItem<String>> dropdownItems;
  final String                         dropdownValue;
  //
  final Function(String?) onDropdownValueChanged;

  // IconButton properties
  final VoidCallback onDeleteButtonPressed;

  // TextFormField properties
  final Map textFieldControllers;
  //
  final Function(String?, String?) onAnyTextFieldChanged;
  final Function(bool?)            onAnyTextFieldFocusChanged;

  // ElevatedButton properties
  final VoidCallback onSaveButtonPressed;

  // The current version of Flounder
  final String version;

  const FlounderDrawer({
    Key? key,
    required this.state,
    required this.dropdownItems,
    required this.dropdownValue,
    required this.onDropdownValueChanged,
    required this.onDeleteButtonPressed,
    required this.textFieldControllers,
    required this.onAnyTextFieldChanged,
    required this.onAnyTextFieldFocusChanged,
    required this.onSaveButtonPressed,
    required this.version
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const List<String> textFieldIds = ['Talk', 'Discussion', 'Reminder@'];

    List<Widget> textFieldWidgets = [];
    // Prepare the different text fields that are used
    // to get custom input from the user
    for (var id in textFieldIds) {
      textFieldWidgets.add(
        Focus(
          onFocusChange: onAnyTextFieldFocusChanged,
          skipTraversal: true,
          child: TextFormField(
            controller: textFieldControllers[id],
            style: const TextStyle(fontSize: 25, color: Colors.white),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (String? text) { onAnyTextFieldChanged(id, text);},
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: id,
              labelStyle: const TextStyle(fontSize: 20, color: Colors.white),
              suffixText: 'min',
              suffixStyle: const TextStyle(fontSize: 25, color: Colors.white),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: state.mode.color, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white, width: 1),
              ),
            ),
          ),
        )
      );
      textFieldWidgets.add(
        const SizedBox(height: 15)
      );
    }

    return Drawer(
      backgroundColor: const Color(0xff1f1f1f),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text('Presets:', style: TextStyle(fontSize: 35, color: state.mode.color)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. The DROPDOWN_BUTTON to cycle the presets //////////////////////////
                /////////////////////////////////////////////////////////////////////////
                Expanded(
                  child: DropdownButton<String>(
                    underline: Container(height: 0, color: state.mode.color),
                    isExpanded: true,
                    value: dropdownValue,
                    items: dropdownItems,
                    dropdownColor: state.mode.color,
                    onChanged: onDropdownValueChanged,
                    style: const TextStyle(color: Colors.black, fontSize: 25),
                  ),
                ),
                // 2. The ICON_BUTTON to delete the active preset ///////////////////////
                /////////////////////////////////////////////////////////////////////////
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                  splashRadius: 17,
                  onPressed: onDeleteButtonPressed,
                )
              ]
            ),
            const SizedBox(height: 20),
            Text('Custom:', style: TextStyle(fontSize: 35, color: state.mode.color)),
            const SizedBox(height: 15),
            // 3. The TEXT_FORM_FIELD's to capture user input ///////////////////////////
            /////////////////////////////////////////////////////////////////////////////
            ...textFieldWidgets,
            // 4. The ELEVATED_BUTTON to save the current preset ////////////////////////
            /////////////////////////////////////////////////////////////////////////////
            Container(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save as preset', style: TextStyle(fontSize: 22, color: Colors.white)),
                onPressed: onSaveButtonPressed,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                  backgroundColor: MaterialStateProperty.all<Color>(state.mode.color),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: state.mode.color)),
                  ),
                ),
              )
            ),
            const SizedBox(height: 20),
            // 5. The TEXT to show the current version ////////////////////////////////
            ///////////////////////////////////////////////////////////////////////////
            Align(
              alignment: Alignment.centerRight,
              child: Text('v$version', style: const TextStyle(fontSize: 15, color: Colors.white))
            )
          ]
        )
      )
    );
  }
}
