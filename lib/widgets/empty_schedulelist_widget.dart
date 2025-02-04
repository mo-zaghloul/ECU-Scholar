import 'package:ecu_scholar/constants/text_styles.dart';
import 'package:flutter/material.dart';

class EmptySchedulelistWidget extends StatelessWidget {
  const EmptySchedulelistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Image.asset('assets/images/Navigate_Rock_the_boat.png'),
        const SizedBox(height: 16),
        Text(
          'It looks like you have a free day. \n Enjoy the break!',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText1,
        ),
      ],
    );
  }
}