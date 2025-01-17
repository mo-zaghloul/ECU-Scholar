import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';  // Import the BottomNavBar widget
import '../utils/schedule_tile.dart';
import '../models/schedule.dart';
import '../constants/text_styles.dart';
import '../utils/todays_date.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Schedule> schedules = [
    Schedule(
      courseName: 'Object Oriented Programming',
      lecturerName: 'Dr. Ahmed Ali',
      location: 'A101',
      classType: 'TUT',
      startTime: '9:00 AM',
      endTime: '11:00 AM',
      tileColor: Colors.red,
    ),
    Schedule(
      courseName: 'Computer Science',
      lecturerName: 'Dr. John',
      location: 'C102',
      classType: 'LEC',
      startTime: '11:00 AM',
      endTime: '1:00 PM',
      tileColor: Colors.blue,
    ),
    Schedule(
      courseName: 'Programming',
      lecturerName: 'Dr. Smith',
      location: 'A103',
      classType: 'LAB',
      startTime: '2:00 PM',
      endTime: '4:00 PM',
      tileColor: Colors.yellow,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Schedule', style: AppTextStyles.headline3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getDay(),
                      style: AppTextStyles.headline2,
                    ),
                    Text(
                      getFormattedDatePart(),
                        style: AppTextStyles.bodyText1.copyWith(color: Colors.blue),
                    ),
                  ],
                ),
              ),
          Expanded(
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                return ScheduleTile(schedule: schedules[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
