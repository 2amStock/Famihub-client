import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 800, // Maximum width for tablet/landscape before centering
    this.backgroundColor = Colors.black, // Background color for the letterboxing area
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth) {
          return Container(
            color: backgroundColor,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ClipRect(
                  child: child,
                ),
              ),
            ),
          );
        }
        return child; // Normal mobile view
      },
    );
  }
}
