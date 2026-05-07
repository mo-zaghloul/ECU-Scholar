import 'package:ecu_scholar/constants/text_styles.dart';
import 'package:ecu_scholar/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Simple error widget for displaying API/network errors
/// Follows the same UI pattern as EmptySchedulelistWidget
class ErrorWidget extends StatelessWidget {
  final String? message;

  const ErrorWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final svgAsset = isDark
        ? 'assets/svgs/phone-hotspot-light.svg'
        : 'assets/svgs/phone-hotspot-dark.svg';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 40),
        // Error SVG
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 250,
              height: 250,
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Error Message
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message ?? 'An unexpected error occurred.\nPull to refresh.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyText1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
