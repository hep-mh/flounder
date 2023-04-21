import 'dart:math';

// The padding that is used for the body
const double bodyPadding = 30;

// The padding that is used for the action bar
const double actionBarPadding = 10;

// The parameter to determine the maximal width of FlounderHeader
const double magicWidth = 700 + 2*bodyPadding;


double getDynamicScale(double contextWidth, double contextHeight, [double factor = 1]) {
  double maxSize = factor*min(40, 0.1*contextHeight);
  double minSize = maxSize/factor/2;

  double size = maxSize;
  if ( contextWidth < magicWidth ) {
    final double scale = contextWidth/magicWidth;

    size = minSize + (maxSize - minSize)*scale;
  }

  return size;
}