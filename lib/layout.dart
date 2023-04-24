import 'dart:math';
import 'dart:ui';


// The padding that is used for the body
const double bodyPadding = 30;
// The padding that is used for the action bar
const double actionBarPadding = 10;


// The parameter to determine the maximal width of FlounderHeader
const double magicWidth = 700 + 2*bodyPadding;


// The minimal width that is used to render the UI
const double minRenderWidth = 400;
// The minimal width that is used to render the UI
const double minRenderHeight = 300;


// The size of the resize indicator
const double indicatorSize = 70;


double getDynamicScale(Size contextSize, [double factor = 1]) {
  final double maxSize = factor*min(40, 0.1*contextSize.height);
  final double minSize = maxSize/factor/2;

  double size = maxSize;
  if (contextSize.width < magicWidth) {
    final double scale = contextSize.width/magicWidth;

    size = minSize + (maxSize - minSize)*scale;
  }

  return size;
}