import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'state.dart';


// ignore: constant_identifier_names
const double MAGIC_WIDTH = 740;


class FlounderHeader extends StatelessWidget {
  final ApplicationState state;

  const FlounderHeader({Key? key, required this.state}) : super(key: key);

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
            // Increase visibility by coloring the
            // full box in the respective color
            color: state.mode.color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}


class FlounderTimer extends StatelessWidget {
  final ApplicationState state;

  const FlounderTimer({Key? key, required this.state}) : super(key: key);

  String _timerToText() {
    int min = state.timer ~/ 60;
    int sec = state.timer - min*60;

    String minStr = (min < 10) ? '0' + min.toString() : min.toString();
    String secStr = (sec < 10) ? '0' + sec.toString() : sec.toString();

    return minStr + ':' + secStr;
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 20;

    return Center(
      child: Padding(
        // For now, a constant -- context independent --
        // padding seems to look fine in all conditions
        padding: const EdgeInsets.all(padding),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            _timerToText(),
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
    );
  }
}


class FlounderBody extends StatelessWidget {
  final ApplicationState state;

  const FlounderBody({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          FlounderHeader(state: state),
          Expanded(
            child: FlounderTimer (state: state)
          )
        ],
      ),
    );
  }
}


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
    final double iconSize = _getActionBarScale(
      MediaQuery.of(context).size.width, MediaQuery.of(context).size.height
    );

    return BottomAppBar(
      color: state.mode.color,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Left Button
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
                state.profile.reminderAt.toString() + ' min',
                style: TextStyle(fontSize: 0.75*iconSize)
              ),
            ],
          ),
          // Right button
          Row(
            children: <Widget>[
              Text(
                (state.profile.talkLength + state.profile.discussionLength).toString() + ' min',
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
    final double buttonSize = _getActionBarScale(
      MediaQuery.of(context).size.width, MediaQuery.of(context).size.height, 2
    );

    return SizedBox(
      width: buttonSize, height: buttonSize,
      child: FloatingActionButton(
        child: Icon(
          (state.mode.id == 'Idle') ? Icons.play_arrow_rounded : Icons.sync_rounded,
          color: Colors.black,
          size: 0.6*buttonSize,
        ),
        onPressed: onPressed,
        backgroundColor: state.mode.color,
      ),
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> textFieldIds = ['Talk', 'Discussion', 'Reminder@'];

    List<Widget> textFieldWidgets = [];
    // Prepare the different text fields that are used
    // to get custom input from the user
    for (var id in textFieldIds) {
      textFieldWidgets.add(
        Focus(
          onFocusChange: onAnyTextFieldFocusChanged,
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
                // 1. The DROPDOWN_BUTTON to cycle the presets //////////////////
                /////////////////////////////////////////////////////////////////
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
                // 2. The ICON_BUTTON to delete the active preset ///////////////
                /////////////////////////////////////////////////////////////////
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
            // 3. The TEXT_FORM_FIELD's to capture user input ///////////////////
            /////////////////////////////////////////////////////////////////////
            ...textFieldWidgets,
            // 4. The ELEVATED_BUTTON to save the current preset ////////////////
            /////////////////////////////////////////////////////////////////////
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
            )
          ],
        ),
      ),
    );
  }
}
