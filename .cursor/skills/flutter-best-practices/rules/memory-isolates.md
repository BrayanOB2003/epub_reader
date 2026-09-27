---
title: Use Isolates for Heavy Computation
impact: HIGH
impactDescription: Keeps UI responsive during heavy work
tags: memory, isolates, compute, performance
---

## Use Isolates for Heavy Computation

**Impact: HIGH (keeps UI responsive)**

Use `compute()` or `Isolate.spawn()` for CPU-intensive operations to avoid blocking the main UI thread.

**Incorrect (blocks UI):**

```dart
class DataProcessor extends StatefulWidget {
  @override
  State<DataProcessor> createState() => _DataProcessorState();
}

class _DataProcessorState extends State<DataProcessor> {
  String result = '';

  void processData() {
    // This blocks the UI thread!
    final data = heavyComputation(largeDataset);
    setState(() => result = data);
  }

  String heavyComputation(List<int> data) {
    // CPU-intensive work...
    return data.map((e) => e * 2).join(',');
  }
}
```

**Correct (using compute):**

```dart
import 'package:flutter/foundation.dart';

class DataProcessor extends StatefulWidget {
  const DataProcessor({super.key});

  @override
  State<DataProcessor> createState() => _DataProcessorState();
}

class _DataProcessorState extends State<DataProcessor> {
  String result = '';
  bool isProcessing = false;

  Future<void> processData() async {
    setState(() => isProcessing = true);

    // Runs in separate isolate, UI stays responsive
    final data = await compute(heavyComputation, largeDataset);

    setState(() {
      result = data;
      isProcessing = false;
    });
  }

  // Must be a top-level or static function
  static String heavyComputation(List<int> data) {
    return data.map((e) => e * 2).join(',');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isProcessing) const CircularProgressIndicator(),
        Text(result),
        ElevatedButton(
          onPressed: isProcessing ? null : processData,
          child: const Text('Process'),
        ),
      ],
    );
  }
}
```

**For complex isolate communication:**

```dart
import 'dart:isolate';

Future<void> runInIsolate() async {
  final receivePort = ReceivePort();

  await Isolate.spawn(
    isolateEntryPoint,
    receivePort.sendPort,
  );

  final result = await receivePort.first;
  print('Result: $result');
}

void isolateEntryPoint(SendPort sendPort) {
  // Heavy computation here
  final result = performHeavyWork();
  sendPort.send(result);
}
```

**When to use isolates:**
- JSON parsing of large responses
- Image processing
- Data encryption/decryption
- Complex calculations
- File operations on large files

Reference: [Isolates Documentation](https://dart.dev/language/concurrency)
