import 'package:flutter/cupertino.dart';

const _letterSpacingMultiplier = 1.0;

class Typographies {
  static TextStyle boldH1 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 29 / 24,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );

  static TextStyle semiBoldH2 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 25 / 20,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );
  static TextStyle regularH3 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 22 / 18,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );
  static TextStyle regularBody = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 21 / 16,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );
  static TextStyle regularBody2 = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 18 / 14,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );

  static TextStyle regularButton = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 20 / 16,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );
  static TextStyle regularInput = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 20 / 16,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );
  static TextStyle regularOverlineUpper = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 15 / 12,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );
  static TextStyle regularOverlineLower = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 15 / 12,
    letterSpacing: _letterSpacingMultiplier * -0.3,
  );
}
