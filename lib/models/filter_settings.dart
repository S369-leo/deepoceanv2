import 'package:flutter/material.dart';

class FilterSettings {
  final RangeValues ageRange;     // e.g., 18..60
  final String? selectedGender;   // "Any" | "Male" | "Female" | "Other"

  const FilterSettings({
    required this.ageRange,
    this.selectedGender,
  });

  factory FilterSettings.defaults() =>
      const FilterSettings(ageRange: RangeValues(18, 60), selectedGender: 'Any');

  FilterSettings copyWith({
    RangeValues? ageRange,
    String? selectedGender,
  }) {
    return FilterSettings(
      ageRange: ageRange ?? this.ageRange,
      selectedGender: selectedGender ?? this.selectedGender,
    );
  }
}
