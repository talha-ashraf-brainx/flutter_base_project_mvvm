import 'dart:async';

import 'package:api_repo/data/managers/cache_policy.dart';
import 'package:api_repo/data/repos/api_repo.dart';

import '../../../../core/resources/data_state.dart';
import '../../../managers/remote/api_manager.dart';

class CountryRepo with ApiRepo {
  final ApiManager _apiManager;
  CountryRepo(this._apiManager);

  Future<DataState<String>> getCountry() async {
    final completer = Completer<DataState<String>>();

    onRequest<String>(
      cachePolicy: CachePolicy.cacheThenNetwork,
      showLogs: true,
      request: () async =>
          (await _apiManager.get('/json'))['country'] as String,
      onData: (String data, ResponseOrigin source) {
        if (!completer.isCompleted) {
          completer.complete(DataSuccess<String>(data));
        }
      },
    );

    return completer.future;
  }
}
