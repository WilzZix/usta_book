import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/presentation/sign_up/profile_settings/profile_settings.dart';

import '../../../core/ui_kit/components/inputs/otp.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  static const String tag = '/otp-page';

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(tr.sign_up.back, style: Typographies.regularBody),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 36),
            Text(tr.sign_up.welcome, style: Typographies.boldH1),
            SizedBox(height: 8),
            Text(
              tr.sign_up.enter_otp_code(phone: '+998(94) 691-49-77'),
              style: Typographies.regularBody,
            ),
            SizedBox(height: 36),
            OtpInput(),
            SizedBox(height: 12),
            OtpTimerWidget(
              seconds: 60,
              onExpired: () {
                // разблокировать кнопку "Отправить повторно"
                print('OTP истёк — разрешить повтор отправки');
              },
            ),
            SizedBox(height: 36),
            MainButton.primary(
              title: tr.buttons.confirm_and_continue,
              onTap: () {
                context.pushNamed(ProfileSettings.tag);
              },
            ),
            Spacer(),
            Text(
              tr.sign_up.user_privacy,
              style: Typographies.regularBody,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

/// Генератор обратного отсчёта в секундах.
/// Возвращает значения: 60, 59, ..., 0 (последнее значение 0)
Stream<int> countdown(int seconds) async* {
  for (int remaining = seconds; remaining >= 0; remaining--) {
    yield remaining;
    if (remaining > 0) {
      await Future.delayed(Duration(seconds: 1));
    }
  }
}

class OtpTimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback onExpired;

  const OtpTimerWidget({Key? key, this.seconds = 60, required this.onExpired})
    : super(key: key);

  @override
  _OtpTimerWidgetState createState() => _OtpTimerWidgetState();
}

class _OtpTimerWidgetState extends State<OtpTimerWidget> {
  late final Stream<int> _countdownStream;

  @override
  void initState() {
    super.initState();
    _countdownStream = countdown(widget.seconds);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return StreamBuilder<int>(
      stream: _countdownStream,
      initialData: widget.seconds,
      builder: (context, snapshot) {
        final remaining = snapshot.data ?? 0;

        if (remaining == 0) {
          // Можно вызвать колбэк истечения
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.onExpired(),
          );
        }

        final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
        final seconds = (remaining % 60).toString().padLeft(2, '0');

        return Center(
          child: Text(
            tr.sign_up.timer(time: '$minutes:$seconds'),
            style: Typographies.regularBody2,
          ),
        );
      },
    );
  }
}
