import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/remote_data_service/remote_data_service.dart';

class ScheduleListViewModel extends ChangeNotifier {
  List<Schedule> _schedules = [];
  final BackendApiService _apiService = BackendApiService();

  Future<void> fetchSchedules() async {
    try {
      _schedules = await _apiService.fetchSchedules();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
      _schedules = [];
      notifyListeners();
    }
  }

  List<Schedule> get schedules => _schedules;
}
