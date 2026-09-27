---
title: Prefer ValueNotifier for Simple State
impact: MEDIUM
impactDescription: Lightweight alternative to streams
tags: state, valuenotifier, simple, performance
---

## Prefer ValueNotifier for Simple State

**Impact: MEDIUM (lightweight state management)**

Use `ValueNotifier` and `ValueListenableBuilder` for simple, local state instead of heavier solutions.

**Incorrect (overkill for simple counter):**

```dart
// Using BLoC for a simple counter is overkill
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }
}
```

**Correct (ValueNotifier for simple state):**

```dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  final _counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _counter,
          builder: (context, count, child) {
            return Text('Count: $count');
          },
        ),
        ElevatedButton(
          onPressed: () => _counter.value++,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

**Multiple ValueNotifiers:**

```dart
class FormWidget extends StatefulWidget {
  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _name = ValueNotifier<String>('');
  final _email = ValueNotifier<String>('');
  final _isValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // Listen to both and compute validity
    _name.addListener(_validateForm);
    _email.addListener(_validateForm);
  }

  void _validateForm() {
    _isValid.value = _name.value.isNotEmpty && _email.value.contains('@');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _isValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(onChanged: (v) => _name.value = v),
        TextField(onChanged: (v) => _email.value = v),
        ValueListenableBuilder<bool>(
          valueListenable: _isValid,
          builder: (context, isValid, _) {
            return ElevatedButton(
              onPressed: isValid ? _submit : null,
              child: const Text('Submit'),
            );
          },
        ),
      ],
    );
  }
}
```

Reference: [ValueNotifier Class](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html)
