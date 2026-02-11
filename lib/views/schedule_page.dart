import 'package:ecu_scholar/views/grades_page.dart';
import 'package:ecu_scholar/views/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/schedule_list_viewmodel.dart';
import '../widgets/shimmer_loading.dart';
import '../utils/schedule_tile.dart';
import '../constants/text_styles.dart';
import '../utils/todays_date.dart';
import '../widgets/empty_schedulelist_widget.dart';

//TODO: -------------------------------------------
// - on refresh, call fetch schedules
//   that also updates the private schedules list variable
//-------------------------------------------------

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    await Provider.of<ScheduleListViewModel>(context, listen: false)
        .fetchSchedules();
  }
  /*
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
  */

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchSchedules,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text('Schedule', style: AppTextStyles.headline3),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Grades',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GradesPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 14, bottom: 12, right: 12.0, left: 12.0),
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
              child: Consumer<ScheduleListViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const ScheduleShimmer();
                  }

                  if (viewModel.schedules.isEmpty) {
                    return EmptySchedulelistWidget();
                  }

                  return ListView.builder(
                    itemCount: viewModel.schedules.length,
                    itemBuilder: (context, index) {
                      return ScheduleTile(schedule: viewModel.schedules[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
