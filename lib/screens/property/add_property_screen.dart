import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// استيراد الخدمات والموديلات والسمات
import '../../../services/property_service.dart';
import '../../../theme/app_theme.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();

  // المتحكمات في الحقول
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  // داخل _AddPropertyScreenState
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // للتفاصيل السكنية (مثال)
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();

// ... في الـ build أضف حقول الموقع
  _buildTextField(_countryController, 'الدولة', Icons.public, isNumber: false),
  _buildTextField(_cityController, 'المدينة', Icons.location_city, isNumber: false),
  _buildTextField(_regionController, 'المنطقة (اختياري)', Icons.map, isNumber: false),

// حقول التفاصيل حسب الفئة
if (_selectedCategory == 'residential') ...[
  _buildTextField(_bedroomsController, 'عدد غرف النوم', Icons.bed, isNumber: true),
  _buildTextField(_bathroomsController, 'عدد الحمامات', Icons.bathtub, isNumber: true),
],
  String _selectedCategory = 'residential';
  String _selectedTransaction = 'sale';
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- منطق اختيار الصور ---
  Future<void> _pickImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((e) => File(e.path)).toList());
      });
    }
  }

  // --- منطق حفظ البيانات وارسالها للـ API ---
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      _showSnack('الرجاء اختيار صورة واحدة على الأقل', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> data = {
        'price': double.parse(_priceController.text),
        'area': double.parse(_areaController.text),
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'transaction_type': _selectedTransaction,
      };

      // ملاحظة: تأكد أن هذه الدالة موجودة في PropertyService
      final success = await _propertyService.postPropertyWithImages(data, _selectedImages);

      if (mounted) {
        if (success) {
          _showSnack('تمت إضافة العقار بنجاح!', Colors.green);
          Navigator.pop(context);
        } else {
          _showSnack('فشل حفظ العقار، حاول مجدداً', Colors.redAccent);
        }
      }
    } catch (e) {
      _showSnack('حدث خطأ: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('إضافة عقار جديد', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppTheme.primaryDark,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('صور العقار'),
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('المعلومات الأساسية'),
              _buildTextField(_priceController, 'السعر (ريال)', Icons.attach_money, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_areaController, 'المساحة (م²)', Icons.crop_square, isNumber: true),
              const SizedBox(height: 16),
              _buildDropdowns(),
              const SizedBox(height: 24),
              _buildSectionTitle('وصف العقار'),
              _buildTextField(_descriptionController, 'اكتب تفاصيل العقار...', Icons.description, maxLines: 4),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- وحدات بناء الواجهة ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: AppTheme.goldAccent, size: 40),
                SizedBox(height: 8),
                Text('اضغط لإضافة صور', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImages[i], width: 100, height: 100, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textLight),
      validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.goldAccent),
        filled: true,
        fillColor: AppTheme.fieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: const [
            DropdownMenuItem(value: 'residential', child: Text('سكني')),
            DropdownMenuItem(value: 'commercial', child: Text('تجاري')),
            DropdownMenuItem(value: 'land', child: Text('أرض')),
          ],
          onChanged: (v) => setState(() => _selectedCategory = v!),
          decoration: const InputDecoration(labelText: 'فئة العقار', filled: true, fillColor: AppTheme.fieldBg, border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedTransaction,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: const [
            DropdownMenuItem(value: 'sale', child: Text('للبيع')),
            DropdownMenuItem(value: 'rent', child: Text('للإيجار')),
          ],
          onChanged: (v) => setState(() => _selectedTransaction = v!),
          decoration: const InputDecoration(labelText: 'نوع المعاملة', filled: true, fillColor: AppTheme.fieldBg, border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldAccent,
          foregroundColor: AppTheme.secondaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('حفظ ونشر العقار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}