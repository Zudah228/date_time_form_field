import 'package:flutter/material.dart';

@immutable
class DateTimeTextEditingValue {
  const DateTimeTextEditingValue(this.date, {this.text = ''});

  final DateTime? date;
  final String text;

  static const DateTimeTextEditingValue empty = DateTimeTextEditingValue(null);

  @override
  bool operator ==(other) {
    return other is DateTimeTextEditingValue &&
        date == other.date &&
        text == other.text;
  }

  @override
  int get hashCode => Object.hash(date, text);
}
