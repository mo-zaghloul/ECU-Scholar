import 'package:flutter/material.dart';

/// Apple iOS-style grouped settings card container
class SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  const SettingsGroupCard({
    super.key,
    required this.children,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.secondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _buildChildrenWithDividers(),
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          const Padding(
            padding: EdgeInsets.only(left: 54),
            child: Divider(height: 1, thickness: 0.5),
          ),
        );
      }
    }
    return result;
  }
}
