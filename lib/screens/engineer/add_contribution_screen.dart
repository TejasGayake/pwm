import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../main.dart';
import '../../models/investor_model.dart';
import '../../models/contribution_model.dart';
import '../../services/tender_service.dart';
import '../../services/storage_service.dart';
import '../../services/location_service.dart';
import '../../utils/helpers.dart';
import '../../theme/app_theme.dart';

class AddContributionScreen extends StatefulWidget {
  final String tenderId;
  final String? sharedImagePath;
  const AddContributionScreen({super.key, required this.tenderId, this.sharedImagePath});

  @override
  State<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends State<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _bankRefCtrl = TextEditingController();
  final TenderService _tenderService = TenderService();
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();

  List<InvestorModel> _investors = [];
  String? _selectedInvestorId;
  DateTime _date = DateTime.now();
  File? _photo;
  String _paymentMode = 'cash';
  double? _gpsLat;
  double? _gpsLng;
  bool _isSaving = false;
  bool _loadingInvestors = true;
  bool _isCapturingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadInvestors();
    // Pre-fill photo from share intent
    if (widget.sharedImagePath != null) {
      _photo = File(widget.sharedImagePath!);
      _paymentMode = 'phonepe';
      pendingSharedImagePath = null;
    } else if (pendingSharedImagePath != null) {
      _photo = File(pendingSharedImagePath!);
      _paymentMode = 'phonepe';
      pendingSharedImagePath = null;
    }
  }

  Future<void> _loadInvestors() async {
    final investors = await _tenderService.getInvestors(widget.tenderId);
    if (mounted) {
      setState(() {
        _investors = investors;
        _loadingInvestors = false;
      });
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _bankRefCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photo = File(picked.path));
      // Auto GPS when taking from camera
      if (source == ImageSource.camera) {
        _captureLocation();
      }
    }
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
              'GPS: ${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}',
            ),
            backgroundColor: AppTheme.successGreen,
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

  bool get _isOnlinePayment => _paymentMode != 'cash';
  bool get _isSharedImage => widget.sharedImagePath != null;

  String get _photoLabel {
    if (_isSharedImage) return 'PhonePe Screenshot Received';
    if (_isOnlinePayment) return 'Attach payment screenshot';
    return 'Attach receipt (optional)';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInvestorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an investor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      String? photoUrl;
      if (_photo != null) {
        photoUrl = await _storageService.uploadContributionPhoto(
          tenderId: widget.tenderId,
          imageFile: _photo!,
        );
      }
      final investor =
          _investors.firstWhere((i) => i.id == _selectedInvestorId, orElse: () => throw Exception('Investor not found'));
      final contribution = ContributionModel(
        investorId: _selectedInvestorId!,
        investorName: investor.name,
        amount: double.parse(_amountCtrl.text),
        date: _date,
        bankReference: _bankRefCtrl.text.trim(),
        receiptPhotoUrl: photoUrl,
        paymentMode: _paymentMode,
      );
      await _tenderService.recordContribution(widget.tenderId, contribution);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contribution recorded successfully'),
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
        title: const Text('Record Contribution'),
      ),
      body: _loadingInvestors
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_investors.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No investors found. Please add investors first.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedInvestorId,
                      decoration: const InputDecoration(
                        labelText: 'Investor',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _investors
                          .map((i) => DropdownMenuItem(
                                value: i.id,
                                child: Text(i.name),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedInvestorId = v),
                      validator: (v) =>
                          v == null ? 'Please select an investor' : null,
                    ),
                  const SizedBox(height: 16),
                  // Payment Mode
                  DropdownButtonFormField<String>(
                    value: _paymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'phonepe', child: Text('PhonePe')),
                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'upi', child: Text('UPI')),
                    ],
                    onChanged: (v) => setState(() => _paymentMode = v ?? 'cash'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.money),
                      prefixText: '₹ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter amount';
                      }
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) return 'Enter a valid amount';
                      return null;
                    },
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
                  // Bank Reference (required for online, hidden for cash)
                  if (_isOnlinePayment)
                    TextFormField(
                      controller: _bankRefCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bank Reference / UTR Number',
                        prefixIcon: Icon(Icons.receipt),
                      ),
                      validator: (v) {
                        if (_isOnlinePayment && (v == null || v.trim().isEmpty)) {
                          return 'Required for online payments';
                        }
                        return null;
                      },
                    ),
                  if (_isOnlinePayment) const SizedBox(height: 16),
                  // Photo preview
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
                  // Photo button
                  OutlinedButton.icon(
                    onPressed: _isSharedImage ? null : _pickPhoto,
                    icon: Icon(_isSharedImage ? Icons.check_circle : Icons.photo_camera),
                    label: Text(_photoLabel),
                  ),
                  // GPS capture (for cash payments at site)
                  if (_paymentMode == 'cash') ...[
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
                            ? 'GPS: ${_gpsLat!.toStringAsFixed(4)}, ${_gpsLng!.toStringAsFixed(4)}'
                            : 'Capture GPS Location (optional)',
                      ),
                    ),
                  ],
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
                        : const Text('Record Contribution'),
                  ),
                ],
              ),
            ),
    );
  }
}
