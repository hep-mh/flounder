import 'dart:math';
import 'dart:ui';


// The minimal width that is used to render the UI
const double minRenderWidth  = 300;
// The minimal width that is used to render the UI
const double minRenderHeight = 200;


// FLOUNDER_HEADER //////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

// The padding that is used for the header
const double headerPadding      = 30;
// The maximal width of the header
const double headerMaxWidth     = 700;
// The maximal height of the header
// (in percent of the total height)
const double headerMaxHeightPct = 0.2;
// The aspect ratio of the header
const double headerAspectRatio  = 14/3;

// Function to dynamically calculate the 
// size (width, height) of the header
Size getHeaderSize(Size contextSize) {
  final double contextWidth  = contextSize.width;
  final double contextHeight = contextSize.height;

  const double maxWidth  = headerMaxWidth;
  const double maxHeight = maxWidth/headerAspectRatio;

  double width = maxWidth;
  // Adapt the width to the width of the
  // context. Here, we set the width to
  //       contextWidth - 2*padding
  // if the box covers the full width of the
  // application
  if ( contextWidth < maxWidth + 2*headerPadding ) {
    width = contextWidth - 2*headerPadding;
  }
  // -->
  final double widthRatio = width/maxWidth;

  // Adapt the height to the height of the
  // context. Here, we force the header to
  // cover at most a certain percentage of
  // the total height of the window
  double height = min(maxHeight, headerMaxHeightPct*contextHeight);
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

// -->
const double magicWidth = headerMaxWidth + 2*headerPadding;

// -->
// Function to dynamically calculate the
// scale of various widgets in the tree
double _getDynamicScale(Size contextSize, double maxSize, double maxSizePct, [double a = 0.5]) {
  final double contextWidth  = contextSize.width;
  final double contextHeight = contextSize.height;

  // Adapt the height to the width of the
  // context. Here, we vary the height
  // between maxHeight and a*maxHeight
  // depending on the width of the context
  double maxSizebyWidth = maxSize;
  if (contextWidth < magicWidth) {
    final double scaling = contextWidth/magicWidth;

    maxSizebyWidth *= a + (1-a)*scaling;
  }

  // Adapt the height to the height of the
  // context. Here, we force the action bar
  // to cover at most a certain percentage
  // of the total height of the window
  return min(maxSizebyWidth, maxSizePct*contextHeight);
}


// FLOUNDER_BODY ////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

// The left and right padding that is
// used for the body
const double bodyPaddingLR = headerPadding;
// The top and bottom pading that is
// used for the body
const double bodyPaddingTB = 15;


// FLOUNDER_ACTION_BAR //////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

// The padding that is used for the action bar
const double actionBarPadding      = 10;
// The maximal height of the action bar
const double actionBarMaxHeight    = 60;
// The maximal height of the action bar
// (in percent of the total height)
const double actionBarMaxHeightPct = 0.15;

// Function to dynamically calculate the
// height of the action bar
double getActionBarHeight(Size contextSize) {
  return _getDynamicScale(contextSize, actionBarMaxHeight, actionBarMaxHeightPct);
}


// FLOUNDER_ACTION_BUTTON ///////////////////////////////////////////

// The maximal scale of the action button
const double actionButtonMaxScale    = 80;
// The maximal scale of the actiom button
// (in percent of the total height)
const double actionButtonMaxScalePct = 0.2;


// Function to dynamically calculate the
// height = width of the action button
double getActionButtonScale(Size contextSize) {
  return _getDynamicScale(contextSize, actionButtonMaxScale, actionButtonMaxScalePct);
}


// FLOUNDER_CLOCK_SWITCHER /////////////////////////////////////////

// The maximal scale of the clock switcher
const double clockSwitcherMaxScale    = 75;
// The maximal scale of the clock switcher
// (in percent of the total height)
const double clockSwitcherMaxScalePct = 0.1;

// Function to dynamically calculate the
// ~width of the clock switcher
double getClockSwitcherScale(Size contextSize) {
  return _getDynamicScale(contextSize, clockSwitcherMaxScale, clockSwitcherMaxScalePct, 0.3);
}


// FLOUNDER_DRAWER //////////////////////////////////////////////////

// The padding that is used for the drawer
const double drawerPadding = 20;