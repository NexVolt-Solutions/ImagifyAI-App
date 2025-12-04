// import 'package:flutter/material.dart';

// extension SizeExtension on BuildContext {
//   /// Screen width and height
//   double get width => MediaQuery.of(this).size.width;
//   double get height => MediaQuery.of(this).size.height;

//   /// Percent width/height
//   double w(double percent) => width * percent;
//   double h(double percent) => height * percent;

//   /// Safe area paddings
//   // EdgeInsets get safePadding => MediaQuery.of(this).padding;
//   /// Responsive padding (horizontal)
//   double padH(double percent) => width * percent;

//   /// Responsive padding (vertical)
//   double padV(double percent) => height * percent;

//   /// Responsive radius (based on smallest side)
//   double radius(double percent) =>
//       MediaQuery.of(this).size.shortestSide * percent;

//   /// Default spacing values (based on width)
//   double get s4 => width * 0.01; // ~4px
//   double get s8 => width * 0.02; // ~8px
//   double get s12 => width * 0.03; // ~12px
//   double get s16 => width * 0.04; // ~16px
//   double get s20 => width * 0.05; // ~20px
// }
// // 3:48
// // final topPadding = context.safePadding.top;
// // 3:48
// // padding: EdgeInsets.symmetric(horizontal: context.padH(0.05)),

import 'package:flutter/material.dart';

extension SizeExtension on BuildContext {
  // Screen width & height
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  // Width & Height (no percentage)
  double w(double value) => value;
  double h(double value) => value;

  // Padding Horizontal + Vertical
  double padH(double value) => value;
  double padV(double value) => value;

  // 🔥 Padding All (always in pixels)
  EdgeInsets padAll(double value) => EdgeInsets.all(value);

  // Padding symmetric
  EdgeInsets padSym({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  // Radius
  double radius(double value) => value;

  // Text size (only numbers)
  double text(double value) => value;

  // Predefined spacing (pixels)
  double get s4 => 4;
  double get s8 => 8;
  double get s12 => 12;
  double get s16 => 16;
  double get s20 => 20;

  // Predefined text sizes
  double get smallText => 12;
  double get mediumText => 16;
  double get largeText => 20;
}

// padding: context.padAll(20), // 20 px
// borderRadius: BorderRadius.circular(context.radius(12)),
// padding: context.padSym(h: 10, v: 30),
// height: context.h(200),
// width: context.w(150),
