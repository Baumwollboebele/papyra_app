import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/services/reminder_service.dart';
import 'package:paperless/features/due/domain/ics_builder.dart';

void main() {
  group('ReminderSchedule.times', () {
    final now = DateTime(2026, 3, 1, 8);
    final due = DateTime(2026, 3, 20);

    test('schedules a reminder leadDays before, at 09:00', () {
      final times = ReminderSchedule.times(
        due,
        leadDays: 3,
        onDueDate: false,
        now: now,
      );
      expect(times, [DateTime(2026, 3, 17, 9)]);
    });

    test('optionally also schedules on the due date', () {
      final times = ReminderSchedule.times(
        due,
        leadDays: 3,
        onDueDate: true,
        now: now,
      );
      expect(times, [DateTime(2026, 3, 17, 9), DateTime(2026, 3, 20, 9)]);
    });

    test('leadDays 0 with onDueDate does not duplicate', () {
      final times = ReminderSchedule.times(
        due,
        leadDays: 0,
        onDueDate: true,
        now: now,
      );
      expect(times, [DateTime(2026, 3, 20, 9)]);
    });

    test('drops reminders that are already in the past', () {
      final times = ReminderSchedule.times(
        DateTime(2026, 3, 2),
        leadDays: 7, // lead would be in February -> past
        onDueDate: true,
        now: now,
      );
      expect(times, [DateTime(2026, 3, 2, 9)]);
    });

    test('a fully past due date yields no reminders', () {
      final times = ReminderSchedule.times(
        DateTime(2026, 2, 1),
        leadDays: 3,
        onDueDate: true,
        now: now,
      );
      expect(times, isEmpty);
    });
  });

  group('ICS export', () {
    test('builds a valid all-day VEVENT for the due date', () {
      final ics = buildDueDateIcs(
        documentId: 7,
        title: 'Stromrechnung',
        dueDate: DateTime(2026, 3, 20),
        now: DateTime.utc(2026, 3, 1, 10),
      );
      expect(ics, contains('BEGIN:VCALENDAR'));
      expect(ics, contains('BEGIN:VEVENT'));
      expect(ics, contains('DTSTART;VALUE=DATE:20260320'));
      expect(ics, contains('DTEND;VALUE=DATE:20260321'));
      expect(ics, contains('SUMMARY:Fällig: Stromrechnung'));
      expect(ics, contains('BEGIN:VALARM'));
      expect(ics, contains('END:VCALENDAR'));
      expect(ics.endsWith('\r\n'), isTrue);
    });

    test('escapes special characters in the title', () {
      final ics = buildDueDateIcs(
        documentId: 1,
        title: 'A, B; C',
        dueDate: DateTime(2026, 1, 1),
      );
      expect(ics, contains(r'SUMMARY:Fällig: A\, B\; C'));
    });
  });
}
