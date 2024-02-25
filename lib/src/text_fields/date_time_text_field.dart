import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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
    this.invalidDateFormatLabel,
    this.calenderIcon,
  }) : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled;

  @internal
  const DateTimeTextField.allRequired({
    required super.key,
    required this.controller,
    required this.decoration,
    required this.formatFromDate,
    required this.restorationId,
    required this.showDatePicker,
    required this.onChanged,
    required this.parseDate,
    required AutovalidateMode? autovalidateMode,
    required this.keyboardType,
    required this.invalidDateFormatLabel,
    required this.calenderIcon,
  }) : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled;

  final DateTimeEditingController? controller;
  final InputDecoration? decoration;
  final String Function(DateTime date)? formatFromDate;
  final String? restorationId;
  final FutureOr<DateTime?> Function(DateTime? currentValue)? showDatePicker;
  final ValueChanged<DateTime?>? onChanged;
  final AutovalidateMode autovalidateMode;
  final DateTime? Function(String value)? parseDate;
  final TextInputType? keyboardType;
  final String? invalidDateFormatLabel;
  final Widget? calenderIcon;

  @override
  State<DateTimeTextField> createState() => DateTimeTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTimeEditingController>(
        'controller', controller));
    properties
        .add(DiagnosticsProperty<InputDecoration>('decoration', decoration));
    properties.add(DiagnosticsProperty<String Function(DateTime date)>(
        'formatFromDate', formatFromDate));
    properties.add(DiagnosticsProperty<String>('restorationId', restorationId));
    properties.add(DiagnosticsProperty<
        FutureOr<DateTime?> Function(
            DateTime? currentValue)>('showDatePicker', showDatePicker));
    properties.add(
        DiagnosticsProperty<ValueChanged<DateTime?>>('onChanged', onChanged));
    properties.add(DiagnosticsProperty<AutovalidateMode>(
        'autovalidateMode', autovalidateMode));
    properties.add(DiagnosticsProperty<DateTime? Function(String value)>(
        'parseDate', parseDate));
    properties
        .add(DiagnosticsProperty<TextInputType>('keyboardType', keyboardType));
  }
}

class DateTimeTextFieldState extends State<DateTimeTextField> {
  late final DateTimeEditingController _controller;
  final _key = GlobalKey<_TextFieldState>();

  String _format(DateTime date) {
    var format = widget.formatFromDate != null
        ? (DateTime date) => widget.formatFromDate!.call(date)
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

  bool validate() {
    return _key.currentState!._validate();
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
        icon: widget.calenderIcon ?? const Icon(Icons.calendar_today),
      );
    }

    return _TextField(
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
      invalidDateFormatLabel: widget.invalidDateFormatLabel,
    );
  }
}

/// customized [InputDatePickerFormField]
class _TextField extends StatefulWidget {
  const _TextField({
    super.key,
    required this.initialText,
    required this.restorationId,
    required this.decoration,
    required this.onChanged,
    required this.autovalidateMode,
    required this.parseDate,
    required this.keyboardType,
    required this.invalidDateFormatLabel,
  });

  final String initialText;
  final String? restorationId;
  final InputDecoration decoration;
  final ValueChanged<DateTime?> onChanged;
  final AutovalidateMode autovalidateMode;
  final DateTime? Function(String value)? parseDate;
  final TextInputType? keyboardType;
  final String? invalidDateFormatLabel;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  String? _errorText;
  bool _hasInteractedByUser = false;

  late final TextEditingController _textEditingController;

  String get _invalidDateFormatLabel =>
      widget.invalidDateFormatLabel ??
      MaterialLocalizations.of(context).invalidDateFormatLabel;

  DateTime? _parseDate(String v) => widget.parseDate != null
      ? widget.parseDate!(v)
      : MaterialLocalizations.of(context).parseCompactDate(v);

  bool _validate() {
    if (_textEditingController.text.isNotEmpty &&
        _parseDate(_textEditingController.text) == null) {
      _errorText = _invalidDateFormatLabel;
    } else {
      _errorText = null;
    }

    return _errorText == null;
  }

  void _onChanged(String value) {
    final changed = _parseDate(value);
    widget.onChanged(changed);

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