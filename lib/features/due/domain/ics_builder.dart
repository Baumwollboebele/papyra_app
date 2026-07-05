/// Builds a minimal, standards-compliant iCalendar (.ics) with a single all-day
/// event for a document's due date, plus a display alarm one day before. Pure
/// and unit-testable; shared via the OS share sheet (no calendar account, no
/// network).
String buildDueDateIcs({
  required int documentId,
  required String title,
  required DateTime dueDate,
  DateTime? now,
}) {
  final stamp = _utcStamp(now ?? DateTime.now());
  final start = _dateOnly(dueDate);
  final end = _dateOnly(dueDate.add(const Duration(days: 1)));
  final summary = _escape('Fällig: $title');

  return [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Papyra//DE',
    'CALSCALE:GREGORIAN',
    'BEGIN:VEVENT',
    'UID:papyra-$documentId-$start@papyra.app',
    'DTSTAMP:$stamp',
    'DTSTART;VALUE=DATE:$start',
    'DTEND;VALUE=DATE:$end',
    'SUMMARY:$summary',
    'DESCRIPTION:${_escape('Zahlungsfrist – von Papyra')}',
    'BEGIN:VALARM',
    'TRIGGER:-P1D',
    'ACTION:DISPLAY',
    'DESCRIPTION:$summary',
    'END:VALARM',
    'END:VEVENT',
    'END:VCALENDAR',
    '',
  ].join('\r\n');
}

String _dateOnly(DateTime d) =>
    '${_p(d.year, 4)}${_p(d.month, 2)}${_p(d.day, 2)}';

String _utcStamp(DateTime d) {
  final u = d.toUtc();
  return '${_p(u.year, 4)}${_p(u.month, 2)}${_p(u.day, 2)}'
      'T${_p(u.hour, 2)}${_p(u.minute, 2)}${_p(u.second, 2)}Z';
}

String _p(int value, int width) => value.toString().padLeft(width, '0');

/// Escapes characters with special meaning in iCalendar text values.
String _escape(String text) => text
    .replaceAll('\\', '\\\\')
    .replaceAll('\n', '\\n')
    .replaceAll(',', '\\,')
    .replaceAll(';', '\\;');
