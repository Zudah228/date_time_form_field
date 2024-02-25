import 'package:date_time_text_form_field/date_time_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

void main() {
  Intl.defaultLocale = 'ja_JP';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateTimeTextFormField Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ja', 'JP'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final now = DateTime.now();
  late final firstDate = now.add(const Duration(days: -365));
  late final lastDate = now.add(const Duration(days: 365));

  final _controller = DateTimeEditingController();
  final _fieldKey = GlobalKey<DateTimeTextFormFieldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('DateTimeTextFormField'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            child: Builder(
              builder: (context) {
                final form = Form.of(context);
                return ListView(
                  children: [
                    const Gap(16),
                    FilledButton.tonal(
                      onPressed: () {
                        form.reset();
                      },
                      child: const Text('Reset'),
                    ),
                    const Gap(16),
                    Text(
                      'Basic',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const Gap(8),
                    _ListItem(
                      title: 'Primitive use',
                      child: DateTimeTextFormField(),
                    ),
                    _ListItem(
                      title: 'Cupertino picker',
                      child: DateTimeTextFormField.cupertinoPicker(),
                    ),
                    _ListItem(
                      title: 'Material picker',
                      child: DateTimeTextFormField.materialPicker(
                        firstDate: firstDate,
                        lastDate: lastDate,
                      ),
                    ),
                    _ListItem(
                      title: 'Customize calenderIcon',
                      child: DateTimeTextFormField.materialPicker(
                        firstDate: firstDate,
                        lastDate: lastDate,
                        calenderIcon: const Icon(Icons.thumb_up),
                      ),
                    ),
                    _ListItem(
                      title: 'Set initialValue',
                      child: DateTimeTextFormField(initialValue: now),
                    ),
                    _ListItem(
                      title: 'Set onChanged',
                      child: DateTimeTextFormField(
                        onChanged: (value) {
                          final String text;

                          if (value == null) {
                            text = 'キャンセル';
                          } else {
                            text = MaterialLocalizations.of(context)
                                .formatCompactDate(value);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(text),
                          ));
                        },
                      ),
                    ),
                    _ListItem(
                      title: 'Controller',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            runAlignment: WrapAlignment.end,
                            alignment: WrapAlignment.start,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              FilledButton(
                                onPressed: () {
                                  _controller.add(const Duration(days: 1));
                                },
                                child: const Text('Add 1 day'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  _controller.value = now;
                                },
                                child: const Text('Set now'),
                              ),
                              FilledButton.tonal(
                                onPressed: () {
                                  _controller.clear();
                                },
                                child: const Text('Clear'),
                              ),
                              FilledButton.tonal(
                                onPressed: () {
                                  _fieldKey.currentState!.reset();
                                },
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                          const Gap(8),
                          ValueListenableBuilder(
                            valueListenable: _controller,
                            builder: (context, value, _) {
                              return Text(
                                  'ListenValue: ${value != null ? DateFormat.yMMMd().format(value) : 'Null'}');
                            },
                          ),
                          DateTimeTextFormField(
                            key: _fieldKey,
                            controller: _controller,
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Validation',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const Gap(8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton(
                        onPressed: () {
                          form.validate();
                        },
                        child: const Text('Validate'),
                      ),
                    ),
                    const Gap(8),
                    _ListItem(
                      title: 'Format Validation',
                      child: DateTimeTextFormField(),
                    ),
                    _ListItem(
                      title: '"required" Validation',
                      child: DateTimeTextFormField(
                        validator: (value) => value == null ? 'required' : null,
                      ),
                    ),
                    _ListItem(
                      title: '"required" Validation onUserInteraction',
                      child: DateTimeTextFormField(
                        validator: (value) => value == null ? 'required' : null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    _ListItem(
                      title: '"within this year" Validation',
                      child: DateTimeTextFormField(
                        validator: (value) => value == null
                            ? 'required'
                            : value.year != now.year
                                ? 'required within this year'
                                : null,
                      ),
                    ),
                    Text(
                      'Decoration',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const Gap(8),
                    _ListItem(
                      title: 'Filled',
                      child: DateTimeTextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.onInverseSurface,
                          hintText:
                              MaterialLocalizations.of(context).dateHelpText,
                        ),
                      ),
                    ),
                    _ListItem(
                      title: 'Outlined',
                      child: DateTimeTextFormField(
                        decoration: InputDecoration(
                          label: const Text('Date'),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                          hintText:
                              MaterialLocalizations.of(context).dateHelpText,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 48),
      ],
    );
  }
}
