import 'package:intl/intl.dart';

import '../enums/enums.dart';

extension StringExt on String {
  String strToUzbSum() {
    final number = int.parse(this);
    final formatter = NumberFormat('#,###', 'ru');
    return "${formatter.format(number).replaceAll(',', ' ')} so'm";
  }
}

extension ClientStatusX on ClientStatus {
  static ClientStatus fromString(String value) {
    switch (value) {
      case "waiting":
        return ClientStatus.waiting;
      case "inProgress":
        return ClientStatus.inProgress;
      case "done":
        return ClientStatus.done;
      case "rejected":
        return ClientStatus.rejected;
      default:
        return ClientStatus.waiting;
    }
  }
}
