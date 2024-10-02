import 'package:flutter/material.dart';

class AutofillPlantainFix {
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  Key get autofillGroupKey => ValueKey(_autofillBroken);

  final Stopwatch _stopwatchAutofill = Stopwatch()..start();
  bool _autofillBroken = false;
  final VoidCallback callback;

  AutofillPlantainFix(this.callback) {
    userNameFocusNode.addListener(() {
      if (userNameFocusNode.hasFocus) {
        _stopwatchAutofill.reset();
      } else if (_stopwatchAutofill.elapsedMilliseconds < 500 &&
          !_autofillBroken) {
        _autofillBroken = true;
        callback();
        Future.delayed(
            const Duration(milliseconds: 100), passwordFocusNode.requestFocus);
      }
    });
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        _stopwatchAutofill.reset();
      } else if (_stopwatchAutofill.elapsedMilliseconds < 500 &&
          !_autofillBroken) {
        _autofillBroken = true;
        callback();
      }
    });
  }

  Iterable<String>? get userNameAutofillHints {
    return _autofillBroken ? null : const [AutofillHints.username];
  }

  Iterable<String>? get passwordAutofillHints {
    return _autofillBroken ? null : const [AutofillHints.password];
  }

  void dispose() {
    userNameFocusNode.dispose();
    passwordFocusNode.dispose();
  }
}
