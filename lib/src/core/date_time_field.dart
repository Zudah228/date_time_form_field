import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/date_time_editing_controller.dart';

class DateTimeTextField extends StatefulWidget {
  const DateTimeTextField({
    super.key,
    this.controller,
    this.decoration,
    this.format,
    this.restorationId,
    this.showDatePicker,
  });

  final DateTimeEditingController? controller;
  final InputDecoration? decoration;
  final String Function(DateTime date, BuildContext context)? format;
  final String? restorationId;
  final FutureOr<DateTime?> Function(DateTime? currentValue)? showDatePicker;

  @override
  State<DateTimeTextField> createState() => DateTimeTextFieldState();
}

class DateTimeTextFieldState extends State<DateTimeTextField> {
  late final DateTimeEditingController _controller;
  final _key = GlobalKey<_FieldState>();

  String _format(DateTime date) {
    var format = widget.format != null
        ? (DateTime date) => widget.format!.call(date, context)
        : null;

    format ??= (DateTime date) {
      return MaterialLocalizations.of(context).formatCompactDate(date);
    };

    return format(date);
  }

  void _handler() {
    final formatted =
        _controller.value != null ? _format(_controller.value!) : '';

    _key.currentState!.textEditingController.text = formatted;
  }

  void clear() {
    _controller.clear();
    _key.currentState!.textEditingController.clear();
  }

  @override
  void initState() {
    _controller = widget.controller ?? DateTimeEditingController();
    _controller.addListener(_handler);

    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_handler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = (widget.decoration ?? const InputDecoration())
        .applyDefaults(Theme.of(context).inputDecorationTheme);
    Widget? prefixIcon;

    if (widget.showDatePicker case final showDatePicker?) {
      prefixIcon = IconButton(
        onPressed: () => showDatePicker(_controller.value),
        icon: const Icon(Icons.calendar_month),
      );
    }

    return _Field(
      key: _key,
      initialText: _controller.value != null ? _format(_controller.value!) : '',
      restorationId: widget.restorationId,
      decoration: effectiveDecoration.copyWith(
        prefixIcon: prefixIcon,
      ),
      onChanged: (value) {
        if (value == null && _controller.value != null) {
        } else {
          _controller.value = value;
        }
      },
    );
  }
}

/// customized [InputDatePickerFormField]
class _Field extends StatefulWidget {
  const _Field({
    super.key,
    required this.initialText,
    this.restorationId,
    this.decoration,
    required this.onChanged,
  });

  final String initialText;
  final String? restorationId;
  final InputDecoration? decoration;
  final ValueChanged<DateTime?> onChanged;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final TextEditingController textEditingController;

  DateTime? _convert(String v) =>
      MaterialLocalizations.of(context).parseCompactDate(v);

  @override
  void initState() {
    textEditingController = TextEditingController(text: widget.initialText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // WARNING: validate のためにここを TextFormField にすると、FormState.reset() などの挙動に影響されてしまうので、
    // TextField のままで運用する。
    return TextField(
      controller: textEditingController,
      restorationId: widget.restorationId,
      decoration: widget.decoration,
      keyboardType: TextInputType.datetime,
      onChanged: (value) {
        final changed = _convert(value);
        widget.onChanged(changed);
      },
    );
  }
}
