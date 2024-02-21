import 'dart:async';

import 'package:date_time_form_field/src/core/date_time_field.dart';
import 'package:date_time_form_field/src/components/cupertino_date_picker.dart';
import 'package:flutter/material.dart';

import '../controller/date_time_editing_controller.dart';

class DateTimeFormField extends FormField<DateTime?> {
  DateTimeFormField({
    super.key,
    this.showTimePicker,
    this.controller,
    super.autovalidateMode,
    super.enabled,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    this.decoration,
    this.onChanged,
    this.format,
  }) : super(
          builder: (state) {
            final field = state as DateTimeFormFieldState;

            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            Future<DateTime?> Function()? showDatePickerHandler;

            if (showTimePicker != null) {
              showDatePickerHandler = () async {
                final result = await showTimePicker(field);

                // showTimePicker の動作にも AutovalidateMode の動作を適用させる
                switch (autovalidateMode) {
                  case null:
                  case AutovalidateMode.disabled:
                    break;
                  case AutovalidateMode.always:
                  case AutovalidateMode.onUserInteraction:
                    field.validate();
                }
                if (result != null) {
                  field
                    ..didChange(result)
                    ..setValue(result);
                }
                return result;
              };
            }

            void onChangedHandler(DateTime? value) {
              onChanged?.call(value);
              field.didChange(value);
            }

            return UnmanagedRestorationScope(
              bucket: field.bucket,
              child: DateTimeTextField(
                key: field._fieldKey,
                controller: field._effectiveController,
                decoration: effectiveDecoration.copyWith(
                  errorText: field.errorText,
                ),
                onChanged: onChangedHandler,
                format: format,
                showDatePicker: showDatePickerHandler != null
                    ? (_) async => showDatePickerHandler?.call()
                    : null,
              ),
            );
          },
        );

  static const materialPicker = _DateTimeFormFieldWithMaterialPicker.new;
  static const cupertinoPicker = _DateTimeFormFieldWithCupertinoPicker.new;

  final InputDecoration? decoration;
  final ValueChanged<DateTime?>? onChanged;
  final DateTimeEditingController? controller;
  final String Function(DateTime date, BuildContext context)? format;
  final FutureOr<DateTime?> Function(DateTimeFormFieldState state)?
      showTimePicker;
  @override
  DateTimeFormFieldState createState() {
    return DateTimeFormFieldState();
  }
}

class DateTimeFormFieldState extends FormFieldState<DateTime?> {
  RestorableDateTimeEditingController? _controller;
  DateTimeEditingController get _effectiveController =>
      _dateFormField.controller ?? _controller!.value;

  DateTimeFormField get _dateFormField => super.widget as DateTimeFormField;

  final _fieldKey = GlobalKey<DateTimeTextFieldState>();

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }

    setValue(_effectiveController.value);
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([DateTime? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableDateTimeEditingController()
        : RestorableDateTimeEditingController(date: value);

    if (!restorePending) {
      _registerController();
    }
  }

  void _handleControllerChanged() {
    if (_effectiveController.needChange(value)) {
      didChange(_effectiveController.value);
    }
  }

  @override
  void setValue(DateTime? value) {
    super.setValue(value);
  }

  @override
  void reset() {
    _effectiveController.value = widget.initialValue;
    super.reset();
    _fieldKey.currentState!.clear();
    _dateFormField.onChanged?.call(_effectiveController.value);
  }

  @override
  void initState() {
    if (_dateFormField.controller == null) {
      _createLocalController(widget.initialValue);
    } else {
      _effectiveController.addListener(_handleControllerChanged);
    }
    super.initState();
  }

  @override
  void didChange(DateTime? value) {
    super.didChange(value);
    if (_effectiveController.needChange(value)) {
      _effectiveController.value = value;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _dateFormField.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(DateTimeFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dateFormField.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _dateFormField.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && _dateFormField.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (_dateFormField.controller != null) {
        setValue(_dateFormField.controller!.value);
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }
}

class _DateTimeFormFieldWithMaterialPicker extends DateTimeFormField {
  _DateTimeFormFieldWithMaterialPicker({
    super.key,
    super.controller,
    super.autovalidateMode,
    super.enabled,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    super.decoration,
    required DateTime firstDate,
    required DateTime lastDate,
    RouteSettings? datePickerDialogRouteSettings,
    super.onChanged,
    super.format,
  }) : super(
            showTimePicker: (DateTimeFormFieldState state) => showDatePicker(
                  context: state.context,
                  routeSettings: datePickerDialogRouteSettings,
                  initialDate: state.value,
                  firstDate: firstDate,
                  lastDate: lastDate,
                ));
}

enum CupertinoDatePickerReactiveMode {
  reactive,
  onClosed,
  ;
}

class _DateTimeFormFieldWithCupertinoPicker extends DateTimeFormField {
  _DateTimeFormFieldWithCupertinoPicker({
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    super.decoration,
    super.onChanged,
    super.format,
    super.controller,
    DateTime? firstDate,
    DateTime? lastDate,
    ValueChanged<DateTime>? onDatePickerChanged,
    CupertinoDatePickerReactiveMode pickerReactiveMode =
        CupertinoDatePickerReactiveMode.reactive,
  }) : super(
          showTimePicker: (state) => showCupertinoDatePicker(
            state.context,
            initialDateTime: state.value,
            minimumDate: firstDate,
            maximumDate: lastDate,
            onChanged: (value) {
              switch (pickerReactiveMode) {
                case CupertinoDatePickerReactiveMode.reactive:
                  state.didChange(value);

                case CupertinoDatePickerReactiveMode.onClosed:
                  break;
              }
              onDatePickerChanged?.call(value);
            },
          ),
        );
}
