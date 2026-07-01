import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class FilterCityField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> cities;

  const FilterCityField({super.key, required this.controller, required this.cities});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (val) => val.text.isEmpty ? const Iterable.empty() : cities.where((c) => c.contains(val.text)),
      onSelected: (val) => controller.text = val,
      fieldViewBuilder: (ctx, ctrl, node, __) => TextFormField(
        controller: controller, focusNode: node,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: InputDecoration(
          labelText: 'المدينة', prefixIcon: const Icon(Icons.location_city, color: AppTheme.goldAccent),
          filled: true, fillColor: AppTheme.fieldBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}