import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../formatting/formatters.dart';
import 'settings_store.dart';

/// Pure computation of when a document's reminders should fire. Extracted so it
/// is unit-testable without the notification plugin.
abstract final class ReminderSchedule {
  const ReminderSchedule._();

  /// Hour of day (local) at which reminders fire.
  static const int hour = 9;

  /// Reminder instants for a [dueDate]: one [leadDays] before, and (optionally)
  /// one on the due date — both at [hour]:00 local, past times dropped.
  static List<DateTime> times(
    DateTime dueDate, {
    required int leadDays,
    required bool onDueDate,
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final onDay = DateTime(dueDate.year, dueDate.month, dueDate.day, hour);
    final result = <DateTime>[];
    final lead = onDay.subtract(Duration(days: leadDays));
    if (lead.isAfter(reference)) result.add(lead);
    // Add the on-due-date reminder unless it coincides with the lead one.
    if (onDueDate && leadDays != 0 && onDay.isAfter(reference)) {
      result.add(onDay);
    }
    return result;
  }
}

/// Schedules/cancels local due-date reminders. Abstracted so the app is testable
/// and so non-Android platforms get a safe no-op.
abstract interface class ReminderService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> schedule({
    required int documentId,
    required String documentTitle,
    required DateTime dueDate,
    required int leadDays,
    required bool onDueDate,
  });
  Future<void> cancel(int documentId);
}

final reminderServiceProvider = Provider<ReminderService>((ref) {
  if (!kIsWeb && Platform.isAndroid) return LocalReminderService();
  return const NoopReminderService();
});

/// Schedules (or, when disabled/no due date/paid, cancels) reminders for a saved
/// document, honoring the user's reminder settings. Takes the service + settings
/// directly so both `Ref` and `WidgetRef` callers can use it.
Future<void> applyReminder({
  required ReminderService service,
  required AppSettings settings,
  required int documentId,
  required String title,
  required DateTime? dueDate,
  required bool isPaid,
}) async {
  if (dueDate == null || isPaid || !settings.reminderEnabled) {
    await service.cancel(documentId);
    return;
  }
  await service.schedule(
    documentId: documentId,
    documentTitle: title,
    dueDate: dueDate,
    leadDays: settings.reminderLeadDays,
    onDueDate: settings.reminderOnDueDate,
  );
}

/// No-op implementation (non-Android, tests, previews).
class NoopReminderService implements ReminderService {
  const NoopReminderService();
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> schedule({
    required int documentId,
    required String documentTitle,
    required DateTime dueDate,
    required int leadDays,
    required bool onDueDate,
  }) async {}
  @override
  Future<void> cancel(int documentId) async {}
}

/// Android implementation backed by flutter_local_notifications + timezone.
/// All local; no network. German notification text (German-primary app).
class LocalReminderService implements ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'due_reminders';

  @override
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> schedule({
    required int documentId,
    required String documentTitle,
    required DateTime dueDate,
    required int leadDays,
    required bool onDueDate,
  }) async {
    await init();
    await cancel(documentId);
    final times = ReminderSchedule.times(
      dueDate,
      leadDays: leadDays,
      onDueDate: onDueDate,
    );
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Fälligkeiten',
        channelDescription: 'Erinnerungen an fällige Rechnungen',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    for (var i = 0; i < times.length; i++) {
      // tz.local defaults to UTC; converting a local DateTime preserves the
      // absolute instant, so the notification fires at the intended wall time.
      final when = tz.TZDateTime.from(times[i], tz.local);
      await _plugin.zonedSchedule(
        id: documentId * 10 + i,
        title: 'Rechnung fällig',
        body: '„$documentTitle" ist am ${formatDate(dueDate)} fällig.',
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: '$documentId',
      );
    }
  }

  @override
  Future<void> cancel(int documentId) async {
    await init();
    for (var i = 0; i < 2; i++) {
      await _plugin.cancel(id: documentId * 10 + i);
    }
  }
}
