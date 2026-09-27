import 'dart:math';

class SampleReading {
  const SampleReading({
    required this.startedAt,
    required this.endedAt,
    required this.engagedSeconds,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final int engagedSeconds;
}

DateTime sampleReadingFirstDay(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return DateTime(today.year, today.month - 1, today.day - 15);
}

List<SampleReading> sampleReadings({required DateTime now, Random? random}) {
  final source = random ?? Random();
  final today = DateTime(now.year, now.month, now.day);
  final first = sampleReadingFirstDay(now);
  final readings = <SampleReading>[];
  for (
    var day = first;
    !day.isAfter(today);
    day = DateTime(day.year, day.month, day.day + 1)
  ) {
    final seconds = source.nextInt(16) * 60;
    final started = DateTime(day.year, day.month, day.day, 20);
    readings.add(
      SampleReading(
        startedAt: started.toUtc(),
        endedAt: started.add(Duration(seconds: seconds)).toUtc(),
        engagedSeconds: seconds,
      ),
    );
  }
  return readings;
}
