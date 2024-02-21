import 'package:flutter/material.dart';

class DateTimeEditingController extends ValueNotifier<DateTime?> {
  DateTimeEditingController([super.value]);

  void clear() {
    value = null;
  }

  void add(Duration duration) {
    value = value?.add(duration);
  }

  bool needChange(DateTime? other) {
    return value != other ||
        (other == null || value == null) ||
        value!.compareTo(other) == 0;
  }
}

class RestorableDateTimeEditingController
    extends RestorableChangeNotifier<DateTimeEditingController> {
  RestorableDateTimeEditingController({DateTime? date}) : _initialValue = date;

  final DateTime? _initialValue;

  @override
  DateTimeEditingController createDefaultValue() {
    return DateTimeEditingController(_initialValue);
  }

  @override
  DateTimeEditingController fromPrimitives(Object? data) {
    return DateTimeEditingController(_initialValue);
  }

  @override
  Object? toPrimitives() {
    return value;
  }
}
