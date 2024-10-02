import 'package:core/util/routing/router.dart';
import 'package:core/widget/common/form.dart';
import 'package:flutter/material.dart';

class MessageOperationPopup<T extends Object> extends StatefulWidget {
  final String title;
  final String message;
  final String buttonName;
  final Future<T> Function() operation;
  final void Function(T data)? onSuccess;

  const MessageOperationPopup(
      {required this.title,
      required this.message,
      required this.buttonName,
      required this.operation,
      this.onSuccess});

  @override
  State<MessageOperationPopup<T>> createState() =>
      _MessageOperationPopupState<T>();
}

class _MessageOperationPopupState<T extends Object>
    extends State<MessageOperationPopup<T>> {
  final _formKey = GlobalKey<TFormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 30),
        TForm(
            formKey: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                widget.message,
                style: const TextStyle(fontSize: 16),
              ),
            ])),
        const SizedBox(height: 40),
        TFormPopupButtons(
            formKey: _formKey,
            operation: () async {
              return widget.operation();
            },
            onSuccess: (data) {
              SRRouter.pop(context);
              widget.onSuccess?.call(data);
            },
            buttonName: widget.buttonName)
      ],
    );
  }
}
