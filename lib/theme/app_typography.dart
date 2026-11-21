import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle hero;
  final TextStyle display;
  final TextStyle title;
  final TextStyle section;
  final TextStyle cardTitle;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle overline;
  final TextStyle metric;
  final TextStyle metricSmall;
  final TextStyle button;
  final TextStyle navLabel;

  const AppTypography({
    required this.hero,
    required this.display,
    required this.title,
    required this.section,
    required this.cardTitle,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.caption,
    required this.overline,
    required this.metric,
    required this.metricSmall,
    required this.button,
    required this.navLabel,
  });

  static AppTypography build(Color primary, Color secondary, Color muted) {
    return AppTypography(
      hero: GoogleFonts.montserrat(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.8,
        color: primary,
      ),
      display: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.4,
        color: primary,
      ),
      title: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
        color: primary,
      ),
      section: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: primary,
      ),
      cardTitle: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: primary,
      ),
      body: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: secondary,
      ),
      label: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: secondary,
      ),
      caption: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: muted,
      ),
      overline: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 1.1,
        color: muted,
      ),
      metric: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.4,
        color: primary,
      ),
      metricSmall: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: primary,
      ),
      button: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: primary,
      ),
      navLabel: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: primary,
      ),
    );
  }

  @override
  AppTypography copyWith({
    TextStyle? hero,
    TextStyle? display,
    TextStyle? title,
    TextStyle? section,
    TextStyle? cardTitle,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? overline,
    TextStyle? metric,
    TextStyle? metricSmall,
    TextStyle? button,
    TextStyle? navLabel,
  }) {
    return AppTypography(
      hero: hero ?? this.hero,
      display: display ?? this.display,
      title: title ?? this.title,
      section: section ?? this.section,
      cardTitle: cardTitle ?? this.cardTitle,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      overline: overline ?? this.overline,
      metric: metric ?? this.metric,
      metricSmall: metricSmall ?? this.metricSmall,
      button: button ?? this.button,
      navLabel: navLabel ?? this.navLabel,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      hero: TextStyle.lerp(hero, other.hero, t)!,
      display: TextStyle.lerp(display, other.display, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      section: TextStyle.lerp(section, other.section, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
      metric: TextStyle.lerp(metric, other.metric, t)!,
      metricSmall: TextStyle.lerp(metricSmall, other.metricSmall, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      navLabel: TextStyle.lerp(navLabel, other.navLabel, t)!,
    );
  }
}

extension TypographyContext on BuildContext {
  AppTypography get type => Theme.of(this).extension<AppTypography>()!;
}
