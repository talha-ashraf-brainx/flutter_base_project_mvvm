import 'dart:async';

import '../../../../core/resources/data_state.dart';
import '../../../../core/resources/error_handler.dart';
import '../../../managers/remote/api_manager.dart';

class CountryRepo {
  final ApiManager _apiManager;
  CountryRepo(this._apiManager);

  Future<DataState<String>> getCountry() async {
    return ErrorHandler.onNetworkRequest(
      fetch: () async => (await _apiManager.get('/json'))['country'] as String,
    );
  }
}
