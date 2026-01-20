import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

enum ButtonType { primary, secondary, logOut }

enum _ButtonState { def, disabled }

class MainButton extends StatefulWidget {
  const MainButton._({
    required this.title,
    required this.type,
    this.icon,
    this.onTap,
    required this.isLoading,
    super.key,
  });

  const MainButton.primary({required String title, VoidCallback? onTap, Widget? icon, bool isLoading = false, Key? key})
    : this._(key: key, icon: icon, title: title, type: ButtonType.primary, onTap: onTap, isLoading: isLoading);

  const MainButton.secondary({
    required String title,
    VoidCallback? onTap,
    Widget? icon,
    bool isLoading = false,
    Key? key,
  }) : this._(key: key, icon: icon, title: title, type: ButtonType.secondary, isLoading: isLoading);

  const MainButton.logout({required String title, VoidCallback? onTap, Widget? icon, bool isLoading = false, Key? key})
    : this._(key: key, icon: icon, title: title, type: ButtonType.logOut, onTap: onTap, isLoading: isLoading);

  final String title;
  final Widget? icon;
  final ButtonType type;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  State<MainButton> createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton> {
  final WidgetStatesController _inkStateController = WidgetStatesController();
  late final ValueNotifier<_ButtonState> _onPressState;

  @override
  void initState() {
    super.initState();
    if (widget.onTap == null) {
      _onPressState = ValueNotifier(_ButtonState.disabled);
    } else {
      _onPressState = ValueNotifier(_ButtonState.def);
    }
    _inkStateController.addListener(() {
      final value = _inkStateController.value;
      if (value.isNotEmpty) {
        if (value.first == WidgetState.pressed) {
          _onPressState.value = _ButtonState.def;
        }
      } else {
        _onPressState.value = _ButtonState.def;
      }
    });
  }

  @override
  void didUpdateWidget(covariant MainButton oldWidget) {
    if (oldWidget.onTap != null && widget.onTap == null) {
      _onPressState.value = _ButtonState.disabled;
    } else if (oldWidget.onTap == null && widget.onTap != null) {
      _onPressState.value = _ButtonState.def;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _inkStateController.dispose();
    _onPressState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        statesController: _inkStateController,
        onTap: widget.isLoading ? null : widget.onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          decoration: _boxDecoration(widget.type),
          child: widget.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 24,
                      child: Center(child: CircularProgressIndicator(color: LightAppColors.body, strokeWidth: 2)),
                    ),
                  ],
                )
              : ValueListenableBuilder(
                  valueListenable: _onPressState,
                  builder: (_, state, __) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (widget.icon != null) ...[widget.icon ?? SizedBox(), const SizedBox(width: 8)],
                        Text(widget.title, style: _textStyleType(widget.type)),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration(ButtonType type) {
    switch (type) {
      case ButtonType.primary:
        return BoxDecoration(borderRadius: BorderRadius.circular(8), color: LightAppColors.primary);

      case ButtonType.secondary:
        return _secondaryDecoration();
      case ButtonType.logOut:
        return BoxDecoration(
          border: Border.all(color: StateColor.error.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(8),
          color: StateColor.error.withValues(alpha: 0.05),
        );
    }
  }

  BoxDecoration _secondaryDecoration() {
    return BoxDecoration(
      border: Border.all(color: LightAppColors.border, width: 1),
      borderRadius: BorderRadius.circular(8),
    );
  }

  TextStyle _textStyleType(ButtonType type) {
    switch (type) {
      case ButtonType.primary:
        return Typographies.regularButton.copyWith(color: LightAppColors.secondaryBg);

      case ButtonType.secondary:
        return Typographies.regularButton.copyWith(color: LightAppColors.primary);
      case ButtonType.logOut:
        return Typographies.regularButton.copyWith(color: StateColor.error);
    }
  }
}
