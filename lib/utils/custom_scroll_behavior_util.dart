import 'dart:ui';

import 'package:flutter/material.dart';

class CustomScrollBehaviorUtil extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}