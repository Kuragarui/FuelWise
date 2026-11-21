import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double screenW = 390;
  static const double screenH = 844;
  static const double padSide = 20;
  static const double padCard = 16;
  static const double gapSection = 24;
  static const double gapBlock = 16;
  static const double gapItem = 12;
  static const double gapTight = 8;

  static const double radiusCard = 14;
  static const double radiusField = 10;
  static const double radiusPill = 999;
  static const double radiusSmall = 8;

  static const double inputH = 48;
  static const double buttonH = 52;
  static const double buttonSmallH = 40;
  static const double navH = 64;
  static const double iconTile = 40;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> navShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
