import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/tender_service.dart';
import '../../services/storage_service.dart';
import '../../services/location_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../theme/app_theme.dart';

class AddExpenseScreen extends StatefulWidget {
  final String tenderId;
  const AddExpenseScreen({super.key, required this.tenderId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final TenderService _tenderService = TenderService();
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();

  String _category = 'Materials';
  DateTime _date = DateTime.now();
  File? _photo;
  double? _gpsLat;
  double? _gpsLng;
  bool _isSaving = false;
  bool _isCapturingLocation = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _captureLocation() async {
    setState(() => _isCapturingLocation = true);
    final result = await _locationService.getCurrentLocation();
    if (result != null) {
      setState(() {
        _gpsLat = result.latitude;
        _gpsLng = result.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location captured: ${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get location. Check permissions.'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
    setState(() => _isCapturingLocation = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthProvider>();
      String? photoUrl;
      if (_photo != null) {
        photoUrl = await _storageService.uploadReceiptPhoto(
          tenderId: widget.tenderId,
          imageFile: _photo!,
        );
      }
      final expense = ExpenseModel(
        amount: double.parse(_amountCtrl.text),
        category: _category,
        description: _descCtrl.text.trim(),
        date: _date,
        receiptPhotoUrl: photoUrl,
        gpsLat: _gpsLat,
        gpsLng: _gpsLng,
        recordedBy: auth.user?.uid ?? '',
      );
      await _tenderService.logExpense(widget.tenderId, expense);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense logged successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.money),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter amount';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.expenseCategories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          '${AppConstants.expenseCategoryIcons[c] ?? ''} $c',
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Materials'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(Helpers.formatDate(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 16),
            if (_photo != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _photo!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                        onPressed: () => setState(() => _photo = null),
                      ),
                    ),
                  ),
                ],
              ),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_camera),
              label: Text(
                  _photo == null ? 'Attach Receipt Photo' : 'Change Photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isCapturingLocation ? null : _captureLocation,
              icon: _isCapturingLocation
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.location_on),
              label: Text(
                _gpsLat != null
                    ? 'Location: ${_gpsLat!.toStringAsFixed(4)}, ${_gpsLng!.toStringAsFixed(4)}'
                    : 'Capture GPS Location',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Log Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
