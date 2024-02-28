import 'package:date_time_form_field/date_time_form_field.dart';
import 'package:flutter/material.dart';

class TextFieldBehaviorPage extends StatelessWidget {
  const TextFieldBehaviorPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => const TextFieldBehaviorPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextField Behavior'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 16),
        children: [
          const _Headline2('expands: true'),
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(
              height: kMinInteractiveDimension * 2,
            ),
            child: const DateTimeTextField(expands: true),
          ),
        ],
      ),
    );
  }
}

class _Headline2 extends StatelessWidget {
  const _Headline2(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style: textTheme.headlineSmall,
    );
  }
}
