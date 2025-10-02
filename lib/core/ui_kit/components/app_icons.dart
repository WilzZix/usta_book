import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

SvgPicture _svgAsset(String assetName) {
  final path = 'assets/images/$assetName';
  return SvgPicture.asset(path);
}

Image _pngAsset(String assetName) {
  final path = 'assets/images/$assetName';
  return Image.asset(path);
}

class AppIcons {
  const AppIcons._();

  static final icCheckMark = _svgAsset("ic_check_mark.svg");
  static final icFieldCalendar = _svgAsset("ic_field_calendar.svg");
  static final icFieldTime = _svgAsset("ic_field_time.svg");
  static final icProfile = _svgAsset("ic_profile.svg");
  static final icCamera = _svgAsset("ic_camera.svg");
  static final icWatch = _svgAsset("ic_watch.svg");
  static final icUzb = _pngAsset("ic_uzb.png");
  static final icRus = _pngAsset("ic_rus.png");
  static final icNotification = _pngAsset("ic_notification.png");
  static final icCalendar = _pngAsset("calendar.png");
}
