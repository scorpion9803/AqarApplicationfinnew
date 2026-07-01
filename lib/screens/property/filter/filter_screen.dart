import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/filter_model.dart';
import '../widgets/filter_chip_selector.dart';
import '../widgets/filter_city_field.dart';
import '../widgets/filter_input_fields.dart';
import '../widgets/filter_section_title.dart';

class FilterScreen extends StatefulWidget {
  final PropertyFilter? initialFilter;
  const FilterScreen({super.key, this.initialFilter});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Controllers
  final _priceMin = TextEditingController(), _priceMax = TextEditingController();
  final _areaMin = TextEditingController(), _areaMax = TextEditingController();
  final _rooms = TextEditingController(), _country = TextEditingController();
  final _region = TextEditingController(), _city = TextEditingController();

  // State Values
  String _cat = 'all', _trans = 'all', _own = 'all', _legal = 'all';
  final List<String> _saudiCities = ['الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة'];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  void _loadInitial() {
    final f = widget.initialFilter ?? PropertyFilter();
    _priceMin.text = f.priceMin?.toString() ?? '';
    _priceMax.text = f.priceMax?.toString() ?? '';
    _areaMin.text = f.areaMin?.toString() ?? '';
    _areaMax.text = f.areaMax?.toString() ?? '';
    _rooms.text = f.rooms?.toString() ?? '';
    _country.text = f.country ?? '';
    _region.text = f.region ?? '';
    _city.text = f.city ?? '';
    _cat = f.category ?? 'all'; _trans = f.transactionType ?? 'all';
    _own = f.ownershipType ?? 'all'; _legal = f.legalStatus ?? 'all';
  }

  void _apply() {
    final filter = PropertyFilter(
      priceMin: double.tryParse(_priceMin.text), priceMax: double.tryParse(_priceMax.text),
      areaMin: double.tryParse(_areaMin.text), areaMax: double.tryParse(_areaMax.text),
      category: _cat == 'all' ? null : _cat,
      transactionType: _trans == 'all' ? null : _trans,
      ownershipType: _own == 'all' ? null : _own,
      legalStatus: _legal == 'all' ? null : _legal,
      rooms: int.tryParse(_rooms.text),
      country: _country.text.isEmpty ? null : _country.text,
      region: _region.text.isEmpty ? null : _region.text,
      city: _city.text.isEmpty ? null : _city.text,
    );
    Navigator.pop(context, filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('فلترة متقدمة'),
        backgroundColor: AppTheme.primaryDark,
        actions: [TextButton(onPressed: () => setState(() => _loadInitial()), child: const Text('إعادة تعيين', style: TextStyle(color: AppTheme.goldAccent)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FilterSectionTitle(title: 'السعر (ريال)', icon: Icons.attach_money),
            Row(children: [
              Expanded(child: FilterField(controller: _priceMin, label: 'الأدنى', prefix: '₪')),
              const SizedBox(width: 12),
              Expanded(child: FilterField(controller: _priceMax, label: 'الأقصى', prefix: '₪')),
            ]),
            const SizedBox(height: 24),

            const FilterSectionTitle(title: 'المساحة (م²)', icon: Icons.crop_square),
            Row(children: [
              Expanded(child: FilterField(controller: _areaMin, label: 'الأدنى', suffix: 'م²')),
              const SizedBox(width: 12),
              Expanded(child: FilterField(controller: _areaMax, label: 'الأقصى', suffix: 'م²')),
            ]),
            const SizedBox(height: 24),

            const FilterSectionTitle(title: 'نوع العقار', icon: Icons.category),
            FilterChipSelector(items: const [{'value': 'all', 'label': 'الكل'}, {'value': 'residential', 'label': 'سكني'}], selectedValue: _cat, onSelected: (v) => setState(() => _cat = v)),

            const SizedBox(height: 24),
            const FilterSectionTitle(title: 'الموقع', icon: Icons.location_on),
            FilterField(controller: _country, label: 'الدولة', icon: Icons.flag, isNumber: false),
            const SizedBox(height: 12),
            FilterCityField(controller: _city, cities: _saudiCities),

            const SizedBox(height: 40),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _apply, child: const Text('تطبيق الفلترة'))),
          ],
        ),
      ),
    );
  }
}