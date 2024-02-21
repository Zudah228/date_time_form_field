import 'package:date_time_form_field/date_time_form_field.dart';
import 'package:flutter/material.dart';

class DateTimeFormClearButton extends StatelessWidget {
  const DateTimeFormClearButton({super.key, this.icon});

  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.findAncestorStateOfType<DateTimeFormFieldState>()?.reset();
        context.findAncestorStateOfType<DateTimeTextFieldState>()?.clear();
      },
      icon: icon ?? const Icon(Icons.clear),
    );
  }
}
