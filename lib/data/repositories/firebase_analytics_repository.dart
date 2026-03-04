import 'package:firebase_analytics/firebase_analytics.dart';

import '../../domain/repositories/analytics_repository.dart';

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  FirebaseAnalyticsRepository(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }
}

