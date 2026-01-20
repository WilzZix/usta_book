import 'package:url_launcher/url_launcher.dart';

mixin PhoneCallMixin {
  Future<void> makePhoneCall(String firebasePhoneNumber) async {
    final String cleanNumber = firebasePhoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $launchUri');
    }
  }
}
