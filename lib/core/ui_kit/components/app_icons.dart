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
  static final icArrowLeft = _svgAsset("ic_arrow_left.svg");
  static final icArrowRight = _svgAsset("ic_arrow_right.svg");
  static final icPerson = _svgAsset("ic_person.svg");
  static final icAddCustomer = _svgAsset("ic_add_customer.svg");
  static final icLogout = _svgAsset("ic_logout.svg");
  static final icCustomersUnselected = _svgAsset("ic_customers_unselected.svg");
  static final icCustomersSelected = _svgAsset("ic_customers_selected.svg");
  static final icClose = _svgAsset("ic_close.svg");
  static final icMasterSettingsUnselected = _svgAsset(
    "ic_master_settings_unselected.svg",
  );
  static final icMasterSettingsSelected = _svgAsset(
    "ic_master_settings_selected.svg",
  );
  static final icMasterStatisticsUnselected = _svgAsset(
    "ic_master_statistics_unselected.svg",
  );
  static final icMasterStatisticsSelected = _svgAsset(
    "ic_master_statistics_selected.svg",
  );
  static final icBottomNavCalendarUnselected = _svgAsset(
    "ic_bottom_nav_calendar_unselected.svg",
  );
  static final icBottomNavCalendarSelected = _svgAsset(
    "ic_bottom_nav_calendar_selected.svg",
  );
}
