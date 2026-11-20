import 'package:flutter/widgets.dart';

import '../config/app_mode.dart';

/// Wraps the app and draws a visible DEMO corner marker in demo mode so
/// demo data cannot be mistaken for real customer records.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({Key? key, required this.mode, required this.child})
      : super(key: key);

  final AppMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!mode.showsDemoMarker) return child;
    return Banner(
      message: 'DEMO',
      location: BannerLocation.topStart,
      child: child,
    );
  }
}
