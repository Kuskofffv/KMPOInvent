import 'package:core/core_dependencies.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/globals.dart';
import 'package:core/util/theme/colors.dart';
import 'package:core/util/widget/adaptation.dart';
import 'package:core/widget/common/clear_text_suffix_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/exception/exception_parser.dart';
import '../../util/routing/router.dart';
import 'button.dart';
import 'drop_select.dart';
import 'popup_menu_button.dart';

/// The maximum width of the form.
double get _maxWidthConstraint => 750;

double get _titleWidthConstraint => 270;

/// The minimum operation time in milliseconds.
int get _minOperationTimeMs => 2000;

/// The form text widget.
class TFormTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String title;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final Widget? suffixIcon;
  final bool multiline;
  final TextInputType? keyboardType;
  final InputCounterWidgetBuilder? buildCounter;
  final int? maxLength;

  const TFormTextField({
    required this.title,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.suffixIcon,
    this.keyboardType,
    this.multiline = false,
    this.buildCounter,
    this.maxLength,
  });

  @override
  State<TFormTextField> createState() => _TFormTextFieldState();
}

class _TFormTextFieldState extends State<TFormTextField> {
  late final _focusNode = FocusNode();

  /// The controller for the text field.
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = TAdaptation.of(context).isMobile;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : _maxWidthConstraint),
      child: _buildRow(
          title: widget.title,
          field: _buildNameField(context, isMobile),
          isMobile: isMobile),
    );
  }

  Widget _buildNameField(BuildContext context, bool isMobile) {
    return TextFormField(
        maxLength: widget.maxLength,
        buildCounter: widget.buildCounter,
        focusNode: _focusNode,
        controller: widget.controller,
        enabled: widget.enabled,
        maxLines: widget.multiline ? null : 1,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
            fillColor: TColors.grey30,
            filled: !widget.enabled,
            suffixIcon: widget.suffixIcon,
            // labelText: isMobile
            //     ? (widget.enabled ? widget.hint ?? widget.title : null)
            //     : null,
            hintText: isMobile && _focusNode.hasFocus
                ? null
                : (widget.hint ?? widget.title)),
        validator: _validatorWithAutoscroll(context, widget.validator));
  }
}

class TFormPopupMenuButton<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) textBuilder;
  final String? Function(T?)? validator;
  final T? value;
  final void Function(T) onChanged;
  final double? errorOffset;

  const TFormPopupMenuButton({
    required this.title,
    required this.items,
    required this.textBuilder,
    required this.onChanged,
    this.validator,
    this.value,
    this.errorOffset,
  });

  @override
  State<TFormPopupMenuButton<T>> createState() =>
      _TFormPopupMenuButtonState<T>();
}

class _TFormPopupMenuButtonState<T> extends State<TFormPopupMenuButton<T>> {
  @override
  Widget build(BuildContext context) {
    final isMobile = TAdaptation.of(context).isMobile;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : _maxWidthConstraint),
      child: _buildRow(
          title: widget.title,
          field: _buildDropDown(context, isMobile),
          isMobile: isMobile),
    );
  }

  Widget _buildDropDown(BuildContext context, bool isMobile) {
    return FormField<T>(
      builder: (state) {
        Widget childWidget = TPopupMenuButton<T>(
          items: widget.items,
          value: widget.value,
          onSelected: (value) {
            widget.onChanged(value);
            state.didChange(value);
          },
          textBuilder: widget.textBuilder,
          hint: widget.title,
        );

        if (state.hasError) {
          childWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              childWidget,
              Padding(
                padding: EdgeInsets.only(
                    left: widget.errorOffset ??
                        (Theme.of(context).inputDecorationTheme.contentPadding!
                                as EdgeInsets)
                            .left,
                    top: 6),
                child: Text(
                  state.errorText!,
                  style: Theme.of(context).inputDecorationTheme.errorStyle,
                ),
              )
            ],
          );
        }
        return childWidget;
      },
      validator:
          _validatorWithAutoscroll(context, widget.validator, widget.value),
    );
  }
}

class TFormDropSelect<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) textBuilder;
  final String? Function(T?)? validator;
  final T? value;
  final void Function(T?) onChanged;
  final double? errorOffset;

  const TFormDropSelect({
    required this.title,
    required this.items,
    required this.textBuilder,
    required this.onChanged,
    this.validator,
    this.value,
    this.errorOffset,
  });

  @override
  State<TFormDropSelect<T>> createState() => _TFormFormDropSelectState<T>();
}

class _TFormFormDropSelectState<T> extends State<TFormDropSelect<T>> {
  @override
  Widget build(BuildContext context) {
    final isMobile = TAdaptation.of(context).isMobile;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : _maxWidthConstraint),
      child: _buildRow(
          title: widget.title,
          field: _buildDropDown(context, isMobile),
          isMobile: isMobile),
    );
  }

  Widget _buildDropDown(BuildContext context, bool isMobile) {
    return FormField<T>(
      builder: (state) {
        Widget childWidget = TDropSelect<T>(
            value: widget.value,
            hint: widget.title,
            items: widget.items.toList(),
            maxLines: null,
            onSelected: (value) {
              widget.onChanged(value);
              state.didChange(value);
            },
            textBuilder: widget.textBuilder);

        if (state.hasError) {
          childWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              childWidget,
              Padding(
                padding: EdgeInsets.only(
                    left: widget.errorOffset ??
                        (Theme.of(context).inputDecorationTheme.contentPadding!
                                as EdgeInsets)
                            .left,
                    top: 6),
                child: Text(
                  state.errorText!,
                  style: Theme.of(context).inputDecorationTheme.errorStyle,
                ),
              )
            ],
          );
        }
        return childWidget;
      },
      validator:
          _validatorWithAutoscroll(context, widget.validator, widget.value),
    );
  }
}

class TFormDropMultiSelect<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) textBuilder;
  final String? Function(List<T>)? validator;
  final List<T> value;
  final void Function(List<T>) onChanged;
  final double? errorOffset;

  const TFormDropMultiSelect({
    required this.title,
    required this.value,
    required this.items,
    required this.textBuilder,
    required this.onChanged,
    this.validator,
    this.errorOffset,
  });

  @override
  State<TFormDropMultiSelect<T>> createState() =>
      _TFormDropMultiSelectState<T>();
}

class _TFormDropMultiSelectState<T> extends State<TFormDropMultiSelect<T>> {
  @override
  Widget build(BuildContext context) {
    final isMobile = TAdaptation.of(context).isMobile;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : _maxWidthConstraint),
      child: _buildRow(
          title: widget.title,
          field: _buildDropDown(context, isMobile),
          isMobile: isMobile),
    );
  }

  Widget _buildDropDown(BuildContext context, bool isMobile) {
    return FormField<List<T>>(
      builder: (state) {
        final childWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: widget.value
                        .map((el) => Chip(
                            label: Text(widget.textBuilder(el)),
                            deleteButtonTooltipMessage: "",
                            onDeleted: () {
                              setState(() {
                                final newValue = List<T>.from(widget.value)
                                  ..remove(el);
                                widget.onChanged(newValue);
                                state.didChange(newValue);
                              });
                            }))
                        .toList()),
              ),
            TDropSelect<T>(
                value: null,
                hint: widget.title,
                items: widget.items
                    .filter((element) => !widget.value.contains(element))
                    .toList(),
                onSelected: (value) {
                  if (value != null) {
                    final newValue = List<T>.from(widget.value)..add(value);
                    widget.onChanged(newValue);
                    state.didChange(newValue);
                  }
                },
                textBuilder: widget.textBuilder),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(
                    left: widget.errorOffset ??
                        (Theme.of(context).inputDecorationTheme.contentPadding!
                                as EdgeInsets)
                            .left,
                    top: 6),
                child: Text(
                  state.errorText!,
                  style: Theme.of(context).inputDecorationTheme.errorStyle,
                ),
              )
          ],
        );

        return childWidget;
      },
      validator:
          _validatorWithAutoscroll(context, widget.validator, widget.value),
    );
  }
}

class TFormRadioSelectorField<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) textBuilder;
  final String? Function(T?)? validator;
  final T? value;
  final void Function(T?) onChanged;
  final double? errorOffset;

  const TFormRadioSelectorField({
    required this.title,
    required this.value,
    required this.items,
    required this.textBuilder,
    required this.onChanged,
    this.validator,
    this.errorOffset,
  });

  @override
  State<TFormRadioSelectorField<T>> createState() =>
      _TFormRadioSelectorFieldState<T>();
}

class _TFormRadioSelectorFieldState<T>
    extends State<TFormRadioSelectorField<T>> {
  @override
  Widget build(BuildContext context) {
    final isMobile = TAdaptation.of(context).isMobile;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : _maxWidthConstraint),
      child: _buildRow(
          title: widget.title,
          field: _buildRadio(context, isMobile),
          isMobile: isMobile),
    );
  }

  Widget _buildRadio(BuildContext context, bool isMobile) {
    return FormField<T>(
      builder: (state) {
        final childWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            Wrap(
              children: [
                ...widget.items.map((e) => InkWell(
                      canRequestFocus: false,
                      onTap: () {
                        widget.onChanged(e);
                        state.didChange(e);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<T>(
                            value: e,
                            groupValue: widget.value,
                            onChanged: (value) {
                              widget.onChanged(value);
                              state.didChange(value);
                            },
                          ),
                          Text(widget.textBuilder(e)),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ))
              ],
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(
                    left: widget.errorOffset ??
                        (Theme.of(context).inputDecorationTheme.contentPadding!
                                as EdgeInsets)
                            .left,
                    top: 6),
                child: Text(
                  state.errorText!,
                  style: Theme.of(context).inputDecorationTheme.errorStyle,
                ),
              )
          ],
        );

        return childWidget;
      },
      validator:
          _validatorWithAutoscroll(context, widget.validator, widget.value),
    );
  }
}

/// The form custom field widget.
class TFormCustomField extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext, void Function() onChanged) builder;
  final String? Function(Object?)? validator;
  final double? errorOffset;
  final bool showTitleOnMobile;

  const TFormCustomField(
      {required this.title,
      required this.builder,
      super.key,
      this.validator,
      this.showTitleOnMobile = false,
      this.errorOffset});

  @override
  Widget build(BuildContext context) {
    final isMobile = TAdaptation.of(context).isMobile;
    return _buildRow(
        title: title,
        field: FormField(
          validator: _validatorWithAutoscroll(context, validator),
          builder: (state) {
            Widget childWidget = builder(context, () {
              state.didChange(null);
            });
            if (state.hasError) {
              childWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  childWidget,
                  Padding(
                    padding: EdgeInsets.only(
                        left: errorOffset ??
                            (Theme.of(context)
                                    .inputDecorationTheme
                                    .contentPadding! as EdgeInsets)
                                .left),
                    child: Text(
                      state.errorText!,
                      style: Theme.of(context).inputDecorationTheme.errorStyle,
                    ),
                  )
                ],
              );
            }
            return childWidget;
          },
        ),
        isMobile: !showTitleOnMobile && isMobile);
  }
}

/// The date editing controller.
class DateEditingController extends ValueNotifier<DateTime?> {
  DateEditingController({DateTime? date}) : super(date);

  DateTime? get date => value;

  set date(DateTime? date) {
    value = date;
  }
}

/// The form date field widget.
class TFormDateField extends StatefulWidget {
  final String title;
  final String formatter;
  final DateEditingController controller;
  final FormFieldValidator<DateTime>? validator;

  const TFormDateField(
      {required this.formatter,
      required this.controller,
      required this.title,
      this.validator});

  @override
  State<TFormDateField> createState() => _TFormDateFieldState();
}

class _TFormDateFieldState extends State<TFormDateField> {
  late final _focusNode = FocusNode();
  late final _textController = TextEditingController(
      text: widget.controller.value != null
          ? DateFormat(widget.formatter).format(widget.controller.value!)
          : '');

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final text = _textController.text.trim();
      if (text.isEmpty) {
        widget.controller.value = null;
      } else {
        try {
          widget.controller.value = DateFormat(widget.formatter).parse(text);
        } catch (e) {
          widget.controller.value = null;
        }
      }
    });
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant TFormDateField oldWidget) {
    if (oldWidget.controller != widget.controller) {
      _textController.text = widget.controller.value != null
          ? DateFormat(widget.formatter).format(widget.controller.value!)
          : '';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TFormTextField(
      title: widget.title,
      controller: _textController,
      suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            _selectDate(context);
          }),
      validator: _validatorWithAutoscroll(context, (value) {
        DateTime? date;
        if (value != null && value.isNotEmpty) {
          try {
            date = DateFormat(widget.formatter).parse(value);
          } catch (e) {
            return 'Неверный формат даты';
          }
        }
        return widget.validator?.call(date);
      }),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime.now().add(const Duration(days: 50 * 365)));
    if (selectedDate != null) {
      _textController.text = DateFormat(widget.formatter).format(selectedDate);
      setState(() {});
    }
  }
}

/// The date editing controller.
class PeriodEditingController
    extends ValueNotifier<({DateTime? from, DateTime? to})> {
  PeriodEditingController({DateTime? from, DateTime? to})
      : super((from: from, to: to));

  ({DateTime? from, DateTime? to}) get period => value;

  set period(({DateTime? from, DateTime? to}) period) {
    value = period;
  }
}

/// The form date field widget.
class TFormPeriodField extends StatefulWidget {
  final String title;
  final String formatter;
  final PeriodEditingController controller;
  final double? errorOffset;
  final FormFieldValidator<({DateTime? from, DateTime? to})>? validator;

  const TFormPeriodField(
      {required this.formatter,
      required this.controller,
      required this.title,
      this.validator,
      this.errorOffset});

  @override
  State<TFormPeriodField> createState() => _TFormPeriodFieldState();
}

class _TFormPeriodFieldState extends State<TFormPeriodField> {
  late final _focusFromNode = FocusNode();
  late final _focusToNode = FocusNode();
  late final _textFromController = TextEditingController(
      text: widget.controller.value.from != null
          ? DateFormat(widget.formatter).format(widget.controller.value.from!)
          : '');
  late final _textToController = TextEditingController(
      text: widget.controller.value.to != null
          ? DateFormat(widget.formatter).format(widget.controller.value.to!)
          : '');

  @override
  void initState() {
    super.initState();
    _textFromController.addListener(() {
      final text = _textFromController.text.trim();
      if (text.isEmpty) {
        widget.controller.value = (from: null, to: widget.controller.value.to);
      } else {
        try {
          widget.controller.value = (
            from: DateFormat(widget.formatter).parse(text),
            to: widget.controller.value.to
          );
        } catch (e) {
          widget.controller.value =
              (from: null, to: widget.controller.value.to);
        }
      }
    });
    _textToController.addListener(() {
      final text = _textToController.text.trim();
      if (text.isEmpty) {
        widget.controller.value =
            (from: widget.controller.value.from, to: null);
      } else {
        try {
          widget.controller.value = (
            from: widget.controller.value.from,
            to: DateFormat(widget.formatter).parse(text)
          );
        } catch (e) {
          widget.controller.value =
              (from: widget.controller.value.from, to: null);
        }
      }
    });
    _focusFromNode.addListener(() {
      setState(() {});
    });
    _focusToNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant TFormPeriodField oldWidget) {
    if (oldWidget.controller != widget.controller) {
      _textFromController.text = widget.controller.value.from != null
          ? DateFormat(widget.formatter).format(widget.controller.value.from!)
          : '';
      _textToController.text = widget.controller.value.to != null
          ? DateFormat(widget.formatter).format(widget.controller.value.to!)
          : '';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _textFromController.dispose();
    _textToController.dispose();
    _focusFromNode.dispose();
    _focusToNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = TAdaptation.of(context).isMobile;

    final formField = FormField(
      validator: _validatorWithAutoscroll(context, (value) {
        DateTime? dateFrom;
        if (_textFromController.text.isNotNullOrEmptyTrimmed()) {
          try {
            dateFrom = DateFormat(widget.formatter)
                .parse(_textFromController.text.trim());
          } catch (e) {
            return 'Неверный формат даты';
          }
        }

        DateTime? dateTo;
        if (_textToController.text.isNotNullOrEmptyTrimmed()) {
          try {
            dateTo = DateFormat(widget.formatter)
                .parse(_textToController.text.trim());
          } catch (e) {
            return 'Неверный формат даты';
          }
        }
        if (dateFrom != null && dateTo != null && dateFrom.isAfter(dateTo)) {
          return 'Дата начала периода должна быть раньше даты окончания';
        }

        return widget.validator?.call((from: dateFrom, to: dateTo));
      }),
      builder: (state) {
        Widget childWidget = Row(
          children: [
            Expanded(
                child: TextFormField(
              focusNode: _focusFromNode,
              controller: _textFromController,
              maxLines: 1,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () {
                        _selectDateFrom(context);
                      }),
                  // labelText: isMobile ? (widget.title) : null,
                  hintText: isMobile && _focusFromNode.hasFocus
                      ? null
                      : widget.title),
            )),
            const SizedBox(
              width: 40,
              child: Center(
                  child: Text("-",
                      style: TextStyle(fontSize: 16, color: TColors.grey90))),
            ),
            Expanded(
                child: TextFormField(
              focusNode: _focusToNode,
              controller: _textToController,
              maxLines: 1,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () {
                        _selectDateTo(context);
                      }),
                  // labelText: isMobile ? (widget.title) : null,
                  hintText:
                      isMobile && _focusToNode.hasFocus ? null : widget.title),
            )),
          ],
        );
        if (state.hasError) {
          childWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              childWidget,
              Padding(
                padding: EdgeInsets.only(
                    left: widget.errorOffset ??
                        (Theme.of(context).inputDecorationTheme.contentPadding!
                                as EdgeInsets)
                            .left),
                child: Text(
                  state.errorText!,
                  style: Theme.of(context).inputDecorationTheme.errorStyle,
                ),
              )
            ],
          );
        }
        return childWidget;
      },
    );

    return _buildRow(title: widget.title, field: formField, isMobile: isMobile);
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
        // ignore: lines_longer_than_80_chars
        context: context,
        firstDate: DateTime(1900),
        currentDate: widget.controller.period.from,
        lastDate: DateTime.now().add(const Duration(days: 50 * 365)));
    if (selectedDate != null) {
      _textFromController.text =
          DateFormat(widget.formatter).format(selectedDate);
      setState(() {});
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        currentDate: widget.controller.period.to,
        lastDate: DateTime.now().add(const Duration(days: 50 * 365)));
    if (selectedDate != null) {
      _textToController.text =
          DateFormat(widget.formatter).format(selectedDate);
      setState(() {});
    }
  }
}

/// The form single row widget.
Widget _buildRow(
    {required String title, required Widget field, required bool isMobile}) {
  if (isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: TColors.grey90,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        field
      ],
    );
  }

  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: _maxWidthConstraint),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: _titleWidthConstraint,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: TColors.grey90,
            ),
          ),
        ),
      ),
      Expanded(flex: 16, child: field)
    ]),
  );
}

/// The form widget.
class TForm extends StatefulWidget {
  final GlobalKey<TFormState> formKey;
  final Widget child;
  final PopInvokedCallback? onPopInvoked;
  final bool? canPop;
  final AutovalidateMode? autovalidateMode;
  final VoidCallback? onChanged;
  final EdgeInsets padding;

  const TForm({
    required this.formKey,
    required this.child,
    this.onPopInvoked,
    this.canPop,
    this.autovalidateMode,
    this.onChanged,
    this.padding = EdgeInsets.zero,
  }) : super(key: formKey);

  @override
  State<TForm> createState() => TFormState();
}

class TFormState extends State<TForm> {
  final _formKey = GlobalKey<FormState>();
  String? _errorText;
  final GlobalKey _errorKey = GlobalKey();
  _TFormButtonState? _buttonState;

  @override
  Widget build(BuildContext context) {
    final errorWidget = AnimatedSize(
      duration: const Duration(milliseconds: 100),
      alignment: Alignment.topLeft,
      child: _errorText != null
          ? Padding(
              key: _errorKey,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2, right: 4),
                    child: Icon(
                      Icons.close,
                      color: TColors.systemRed,
                      size: 18,
                    ),
                  ),
                  Flexible(
                    child: Text(_errorText ?? "",
                        maxLines: null,
                        style: const TextStyle(
                            fontSize: 16, color: TColors.systemRed)),
                  ),
                ],
              ),
            )
          : emptyWidget,
    );
    return Padding(
      padding: widget.padding,
      child: Form(
          key: _formKey,
          autovalidateMode:
              widget.autovalidateMode ?? AutovalidateMode.disabled,
          canPop: widget.canPop,
          onPopInvoked: widget.onPopInvoked,
          onChanged: () {
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
            widget.onChanged?.call();
          },
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            errorWidget,
            widget.child,
          ])),
    );
  }

  bool _validate() {
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
    return _formKey.currentState!.validate();
  }

  void _error(String errorText) {
    setState(() {
      _errorText = errorText;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_errorKey.currentContext != null &&
          widget.formKey.currentContext != null) {
        Scrollable.maybeOf(context)?.position.animateTo(0,
            duration: const Duration(microseconds: 150),
            curve: Curves.easeInOut);
      }
    });
  }

  void submitForm() {
    _buttonState?.submitForm();
  }
}

class TFormButton<T extends Object> extends StatefulWidget {
  final ButtonType type;
  final ButtonSize size;

  final Color? color;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget child;
  final Future<T> Function() operation;
  final void Function(T result) onSuccess;
  final GlobalKey<TFormState> formKey;

  const TFormButton({
    required this.type,
    required this.size,
    required this.operation,
    required this.onSuccess,
    required this.formKey,
    required this.child,
    Key? key,
    this.color,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  State<TFormButton<T>> createState() => _TFormButtonState<T>();
}

class _TFormButtonState<T extends Object> extends State<TFormButton<T>> {
  bool _isInProcess = false;

  @override
  Widget build(BuildContext context) {
    widget.formKey.currentState?._buttonState = this;
    final button = TButton(
      type: widget.type,
      size: widget.size,
      onPressed: submitForm,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      color: widget.color,
      child: _isInProcess
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: widget.color?.opposite ?? Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          : widget.child,
    );

    return button;
  }

  Future submitForm() async {
    if (widget.formKey.currentState == null) {
      SRRouter.showMessagePopup(context,
          title: "Произошла ошибка",
          message: "Нужно добавить TForm в дерево виджетов");
      return;
    }

    if (widget.formKey.currentState?._validate() == true) {
      final stopwatch = Stopwatch()..start();
      SRRouter.showProgress(visible: false);
      setState(() {
        _isInProcess = true;
      });
      T? result;
      Object? exception;
      try {
        result = await widget.operation();
      } catch (e, s) {
        exception = e;
        logger.e(ExceptionParser.parseException(e), error: e, stackTrace: s);
      }
      if (mounted) {
        await (stopwatch.elapsedMilliseconds < _minOperationTimeMs
            ? Future.delayed(Duration(
                milliseconds:
                    _minOperationTimeMs - stopwatch.elapsedMilliseconds))
            : Future.value());
      }
      SRRouter.hideProgress();
      if (mounted) {
        setState(() {
          _isInProcess = false;
        });
        if (result != null) {
          widget.onSuccess(result);
        } else if (exception != null) {
          widget.formKey.currentState
              ?._error(ExceptionParser.parseException(exception));
        }
      }
    }
  }
}

class LargePrimaryFormButton<T extends Object> extends TFormButton<T> {
  const LargePrimaryFormButton({
    required Future<T> Function() operation,
    required void Function(T) onSuccess,
    required GlobalKey<TFormState> formKey,
    required Widget child,
    Color? color,
    super.key,
  }) : super(
            type: ButtonType.primary,
            size: ButtonSize.large,
            child: child,
            color: color,
            operation: operation,
            onSuccess: onSuccess,
            formKey: formKey);
}

class MediumPrimaryFormButton<T extends Object> extends TFormButton<T> {
  const MediumPrimaryFormButton({
    required Future<T> Function() operation,
    required void Function(T) onSuccess,
    required GlobalKey<TFormState> formKey,
    required Widget child,
    Color? color,
    super.key,
  }) : super(
            type: ButtonType.primary,
            size: ButtonSize.medium,
            child: child,
            operation: operation,
            onSuccess: onSuccess,
            formKey: formKey,
            color: color);
}

class TFormPopupButtons<T extends Object> extends StatelessWidget {
  final String buttonName;
  final GlobalKey<TFormState> formKey;
  final Future<T> Function() operation;
  final void Function(T result) onSuccess;

  const TFormPopupButtons({
    required this.formKey,
    required this.operation,
    required this.onSuccess,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = TAdaptation.of(context).isMobile;

    final Widget cancelButton = MediumSecondaryButton(
        child: const Text("Отменить"),
        onPressed: () {
          Navigator.pop(context);
        });

    final Widget operationButton = MediumPrimaryFormButton(
      formKey: formKey,
      operation: operation,
      onSuccess: onSuccess,
      child: Text(buttonName),
    );

    if (isMobile) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        operationButton,
        const SizedBox(height: 10),
        cancelButton
      ]);
    }

    return Row(
      children: [
        Expanded(child: cancelButton),
        const SizedBox(width: 12),
        Expanded(
          child: operationButton,
        )
      ],
    );
  }
}

class TSearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? hintText;

  const TSearchTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_outlined),
        prefixIconColor: _iconColor,
        suffixIconColor: _iconColor,
        suffixIcon: ClearTextSuffixButton(
          text: controller?.text ?? '',
          onTap: () {
            controller?.clear();
            onChanged?.call('');
          },
        ),
        prefixIconConstraints:
            const BoxConstraints(maxHeight: 22, minWidth: 40),
        constraints: const BoxConstraints(maxWidth: 400),
      ),
    );
  }

  WidgetStateColor get _iconColor {
    return WidgetStateColor.resolveWith(
      (states) => !states.contains(WidgetState.focused)
          ? TColors.grey80
          : TColors.accent,
    );
  }
}

final _queueValidator = WorkerManager.queue();

String? Function(T value)? _validatorWithAutoscroll<T>(
    BuildContext context, dynamic validator,
    [T? value]) {
  if (validator == null) {
    return null;
  }
  return (valueLocal) {
    final result = validator(value ?? valueLocal);
    if (result != null) {
      if (!_queueValidator.inProcess) {
        _queueValidator.add(() => Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 200)));
      }
    }
    return result;
  };
}
