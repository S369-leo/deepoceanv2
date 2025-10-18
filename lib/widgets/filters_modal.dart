import 'package:flutter/material.dart';
import '../models/filter_settings.dart';

class FiltersModal extends StatefulWidget {
  final FilterSettings initial;
  final ValueChanged<FilterSettings> onApply;

  const FiltersModal({
    super.key,
    required this.initial,
    required this.onApply,
  });

  @override
  State<FiltersModal> createState() => _FiltersModalState();
}

class _FiltersModalState extends State<FiltersModal> {
  late RangeValues _range;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _range = widget.initial.ageRange;
    _gender = widget.initial.selectedGender ?? 'Any';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),

            // Age
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Age: ${_range.start.round()} - ${_range.end.round()}'),
            ),
            RangeSlider(
              min: 18,
              max: 60,
              divisions: 42,
              values: _range,
              onChanged: (v) => setState(() => _range = v),
            ),
            const SizedBox(height: 8),

            // Gender
            DropdownButtonFormField<String>(
              value: _gender,
              items: const [
                DropdownMenuItem(value: 'Any', child: Text('Any')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v ?? 'Any'),
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(FilterSettings(
                    ageRange: _range,
                    selectedGender: _gender,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
