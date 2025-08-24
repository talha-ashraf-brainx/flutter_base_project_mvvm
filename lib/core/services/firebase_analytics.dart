import 'dart:collection';

import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/helpers.dart';
import 'package:flutter_base_project_mvvm/core/extensions/string.dart';

enum AnalyticsTaskType { screenView, event, userProperty }

class _AnalyticsTask {
  final AnalyticsTaskType type;
  final dynamic data;

  _AnalyticsTask(this.type, this.data);
}

class AppAnalytics {
  static final _taskQueue = Queue<_AnalyticsTask>();
  static bool _isProcessing = false;
  static bool _isScheduled = false;

  static void logScreenEvent(Screens screen) {
    _taskQueue.add(_AnalyticsTask(
      AnalyticsTaskType.screenView,
      {
        'screenName': screen.name.capitalizeFirst(),
        'screenClass': screenClass[screen.name],
      },
    ));
    _scheduleProcessing();
  }

  static void logEvent(String eventName, {Map<String, Object>? parameters}) {
    _taskQueue.add(_AnalyticsTask(
      AnalyticsTaskType.event,
      {
        'name': eventName,
        'parameters': parameters,
      },
    ));
    _scheduleProcessing();
  }

  static void setUserProperty(String name, String? value) {
    _taskQueue.add(_AnalyticsTask(
      AnalyticsTaskType.userProperty,
      {
        'name': name,
        'value': value,
      },
    ));
    _scheduleProcessing();
  }

  static void _scheduleProcessing() {
    if (_isScheduled || _isProcessing) return;

    _isScheduled = true;
    Future.microtask(() async {
      _isScheduled = false;
      await _processQueue();
    });
  }

  static Future<void> _processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;
    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      try {
        switch (task.type) {
          case AnalyticsTaskType.screenView:
            final data = task.data as Map<String, dynamic>;
            await FirebaseAnalytics.instance.logScreenView(
              screenName: data['screenName'],
              screenClass: data['screenClass'],
            );
            break;

          case AnalyticsTaskType.event:
            final data = task.data as Map<String, dynamic>;
            await FirebaseAnalytics.instance.logEvent(
              name: data['name'],
              parameters: data['parameters'],
            );
            break;

          case AnalyticsTaskType.userProperty:
            final data = task.data as Map<String, dynamic>;
            await FirebaseAnalytics.instance.setUserProperty(
              name: data['name'],
              value: data['value'],
            );
            break;
        }
      } catch (e) {
        printLog('Analytics error: $e');
      }
    }
    _isProcessing = false;
  }
}

enum Screens {
  splashScreen,
}

final Map screenClass = {
  Screens.splashScreen.name: 'Splash',
};
