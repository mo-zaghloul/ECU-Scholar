import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/remote_data_service/remote_data_service.dart';

enum LoadingState { initial, loading, loaded, error }

class ScheduleListViewModel extends ChangeNotifier {
  List<Schedule> _schedules = [];
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;
  final BackendApiService _apiService = BackendApiService();

  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == LoadingState.loading;

  Future<void> fetchSchedules() async {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedules = await _apiService.fetchSchedules();
      _loadingState = LoadingState.loaded;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
      _errorMessage = e.toString();
      _loadingState = LoadingState.error;
      _schedules = [];
      notifyListeners();
    }
  }

  List<Schedule> get schedules => _schedules;
}
