import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/date_time_editing_controller.dart';

class DateTimeTextField extends StatefulWidget {
  const DateTimeTextField({
    super.key,
    this.controller,
    this.decoration,
    this.formatFromDate,
    this.restorationId,
    this.showDatePicker,
    this.onChanged,
    this.parseDate,
    AutovalidateMode? autovalidateMode,
    this.keyboardType,
  }) : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled;

  final DateTimeEditingController? controller;
  final InputDecoration? decoration;
  final String Function(DateTime date, BuildContext context)? formatFromDate;
  final String? restorationId;
  final FutureOr<DateTime?> Function(DateTime? currentValue)? showDatePicker;
  final ValueChanged<DateTime?>? onChanged;
  final AutovalidateMode autovalidateMode;
  final DateTime? Function(String value)? parseDate;
  final TextInputType? keyboardType;

  @override
  State<DateTimeTextField> createState() => DateTimeTextFieldState();
}

class DateTimeTextFieldState extends State<DateTimeTextField> {
  late final DateTimeEditingController _controller;
  final _key = GlobalKey<_FieldState>();

  String _format(DateTime date) {
    var format = widget.formatFromDate != null
        ? (DateTime date) => widget.formatFromDate!.call(date, context)
        : null;

    format ??= (DateTime date) {
      return MaterialLocalizations.of(context).formatCompactDate(date);
    };

    return format(date);
  }

  void _handler() {
    widget.onChanged?.call(_controller.value);
    final formatted =
        _controller.value != null ? _format(_controller.value!) : '';

    _key.currentState!._textEditingController.text = formatted;
  }

  void clear() {
    _controller.clear();
    _key.currentState!._clear();
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
    Widget? suffixIcon;

    if (widget.showDatePicker case final showDatePicker?) {
      suffixIcon = IconButton(
        onPressed: () => showDatePicker(_controller.value),
        icon: const Icon(Icons.calendar_month),
      );
    }

    return _Field(
      key: _key,
      initialText: _controller.value != null ? _format(_controller.value!) : '',
      restorationId: widget.restorationId,
      autovalidateMode: widget.autovalidateMode,
      decoration: effectiveDecoration.copyWith(
        suffixIcon: suffixIcon,
      ),
      parseDate: widget.parseDate,
      onChanged: (value) {
        if (value == null && _controller.value != null) {
        } else {
          _controller.value = value;
        }
      },
      keyboardType: widget.keyboardType,
    );
  }
}

/// customized [InputDatePickerFormField]
class _Field extends StatefulWidget {
  const _Field({
    super.key,
    required this.initialText,
    this.restorationId,
    required this.decoration,
    required this.onChanged,
    required this.autovalidateMode,
    this.parseDate, this.keyboardType,
  });

  final String initialText;
  final String? restorationId;
  final InputDecoration decoration;
  final ValueChanged<DateTime?> onChanged;
  final AutovalidateMode autovalidateMode;
  final DateTime? Function(String value)? parseDate;
  final TextInputType? keyboardType;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  String? _errorText;
  bool _hasInteractedByUser = false;

  late final TextEditingController _textEditingController;

  DateTime? _parseDate(String v) => widget.parseDate != null
      ? widget.parseDate!(v)
      : MaterialLocalizations.of(context).parseCompactDate(v);

  void _validate() {
    if (_parseDate(_textEditingController.text) == null) {
      _errorText = MaterialLocalizations.of(context).invalidDateFormatLabel;
    } else {
      _errorText = null;
    }
  }

  void _onChanged(String value) {
    final changed = _parseDate(value);
    widget.onChanged(changed);

    // validation
    setState(() {
      _hasInteractedByUser = true;
    });
  }

  void _clear() {
    setState(() {
      _textEditingController.clear();
      _errorText = null;
      _hasInteractedByUser = false;
    });
  }

  @override
  void initState() {
    _textEditingController = TextEditingController(text: widget.initialText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.autovalidateMode) {
      case AutovalidateMode.always:
        _validate();
      case AutovalidateMode.onUserInteraction:
        if (_hasInteractedByUser) {
          _validate();
        }
      case AutovalidateMode.disabled:
        break;
    }

    // WARNING: validate のためにここを TextFormField にすると、FormState.reset() などの挙動に影響されてしまうので、
    // TextField のままで運用する。
    return TextField(
      controller: _textEditingController,
      restorationId: widget.restorationId,
      decoration: widget.decoration.copyWith(
        errorText: _errorText ?? widget.decoration.errorText,
      ),
      keyboardType: TextInputType.datetime,
      onChanged: _onChanged,
    );
  }
}
