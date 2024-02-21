import 'dart:ui';

import 'package:flutter/cupertino.dart';

Future<DateTime?> showCupertinoDatePicker(
  BuildContext context, {
  RouteSettings? settings,
  DateTime? initialDateTime,
  DateTime? minimumDate,
  DateTime? maximumDate,
  String barrierLabel = 'Dismiss',
  Color? barrierColor = kCupertinoModalBarrierColor,
  bool barrierDismissible = true,
  bool semanticsDismissible = false,
  ImageFilter? filter,
  bool useRootNavigator = false,
}) async {
  DateTime? selectedDate = initialDateTime ?? DateTime.now();

  await Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  ).push<DateTime?>(
    CupertinoModalPopupRoute(
      settings: settings,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      semanticsDismissible: semanticsDismissible,
      filter: filter,
      builder: (_) => _Picker(
        onChanged: (value) => selectedDate = value,
        initialDateTime: initialDateTime,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
      ),
    ),
  );

  return selectedDate;
}

class _Picker extends StatefulWidget {
  const _Picker({
    this.initialDateTime,
    this.minimumDate,
    this.maximumDate,
    required this.onChanged,
  });

  final DateTime? initialDateTime;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final ValueChanged<DateTime> onChanged;

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216,
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: CupertinoDatePicker(
        initialDateTime: widget.initialDateTime,
        mode: CupertinoDatePickerMode.date,
        minimumDate: widget.minimumDate,
        maximumDate: widget.maximumDate,
        onDateTimeChanged: widget.onChanged,
      ),
    );
  }
}
