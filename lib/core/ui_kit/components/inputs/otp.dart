import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;

  /// Increment to clear all fields (e.g. after invalid code).
  final int clearSignal;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.clearSignal = 0,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant OtpInput old) {
    super.didUpdateWidget(old);
    if (old.clearSignal != widget.clearSignal) {
      _isClearing = true;
      for (final c in _controllers) {
        c.clear();
      }
      _isClearing = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNodes.first.requestFocus();
        widget.onChanged('');
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.length, (i) {
        final isFirst = i == 0;
        final isLast = i == widget.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: isFirst ? 0 : 6,
              right: isLast ? 0 : 6,
            ),
            child: SizedBox(
              height: 64,
              child: TextFormField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction:
                    isLast ? TextInputAction.done : TextInputAction.next,
                enableSuggestions: false,
                autocorrect: false,
                inputFormatters: [LengthLimitingTextInputFormatter(1)],
                onChanged: (value) {
                  if (_isClearing) return;
                  if (value.isNotEmpty && !isLast) {
                    _focusNodes[i + 1].requestFocus();
                  } else if (value.isEmpty && !isFirst) {
                    _focusNodes[i - 1].requestFocus();
                  } else if (value.isNotEmpty && isLast) {
                    _focusNodes[i].unfocus();
                  }
                  _emit();
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
