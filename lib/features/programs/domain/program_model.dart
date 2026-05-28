import 'package:flutter/material.dart';
import '../../onboarding/domain/onboarding_models.dart';

enum ProgramSplit { fullBody, upperLower, ppl, bro, arnold, custom }

enum ProgramGoal { hypertrophy, strength, fatLoss, recomp, general }

class Program {
  const Program({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.level,
    required this.goal,
    required this.split,
    required this.daysPerWeek,
    required this.durationWeeks,
    required this.totalUsers,
    required this.rating,
    this.isTasosFeatured = false,
    this.isPremium = false,
    this.bannerGradient,
    this.accentColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String emoji;
  final ExperienceLevel level;
  final ProgramGoal goal;
  final ProgramSplit split;
  final int daysPerWeek;
  final int durationWeeks;
  final int totalUsers;
  final double rating;
  final bool isTasosFeatured;
  final bool isPremium;
  final List<Color>? bannerGradient;
  final Color? accentColor;

  String get levelLabel => switch (level) {
    ExperienceLevel.beginner     => 'Beginner',
    ExperienceLevel.intermediate => 'Intermediate',
    ExperienceLevel.advanced     => 'Advanced',
  };

  String get formattedUsers {
    if (totalUsers >= 1000) {
      return '${(totalUsers / 1000).toStringAsFixed(1)}k';
    }
    return '$totalUsers';
  }
}
