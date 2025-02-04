import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/remote_data_service/remote_data_service.dart';

class ScheduleListViewModel extends ChangeNotifier {
  List<Schedule> _schedules = [];

  Future<void> fetchSchedules() async {
    _schedules = await LMSUniversityApi().fetchSchedules();
    notifyListeners();
  }
  List<Schedule> get schedules => _schedules;
}
