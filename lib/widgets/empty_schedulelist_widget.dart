import 'package:ecu_scholar/constants/text_styles.dart';
import 'package:ecu_scholar/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class EmptySchedulelistWidget extends StatelessWidget {
  const EmptySchedulelistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final svgAsset =
        isDark ? 'assets/svgs/hot-air-balloon-light.svg' : 'assets/svgs/hot-air-balloon-dark.svg';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(svgAsset, width: 200, height: 200),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'It looks like you have a free day.\nEnjoy the break!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyText1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}