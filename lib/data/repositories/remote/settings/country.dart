import '../../../../core/resources/data_state.dart';
import '../../../../core/resources/error_handler.dart';
import '../../../managers/remote/api_manager.dart';

import 'package:flutter/foundation.dart';

class CountryRepo {
  final ApiManager _apiManager;
  CountryRepo(this._apiManager);

  Future<DataState<String>> getCountry({Function(dynamic)? onCached}) async {
    final DateTime apiStartTime = DateTime.now();
    int? cacheDuration;

    final dataState = await ErrorHandler.onNetworkRequest<String>(
      fetch: () async {
        final DateTime cacheStartTime = DateTime.now();

        final response = await _apiManager.get(
          '/json',
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          onCached: (data) {
            final DateTime cacheEndTime = DateTime.now();
            cacheDuration =
                cacheEndTime.difference(cacheStartTime).inMilliseconds;
            debugPrint('🗃️ Cached data received in $cacheDuration ms');

            onCached?.call(data['country']);
          },
        );

        final DateTime apiEndTime = DateTime.now();
        final apiDuration = apiEndTime.difference(apiStartTime).inMilliseconds;
        debugPrint('🌐 API data received in $apiDuration ms');

        if (cacheDuration != null && cacheDuration! > 0) {
          final speedFactor = (apiDuration / cacheDuration!).toStringAsFixed(2);
          debugPrint(
              '⚡ Cached data was ~${speedFactor}x faster than API response');
        }

        final country = response['country'];
        return country;
      },
    );

    return dataState;
  }
}
