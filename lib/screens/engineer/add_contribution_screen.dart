import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/investor_model.dart';
import '../../models/contribution_model.dart';
import '../../services/tender_service.dart';
import '../../services/storage_service.dart';
import '../../utils/helpers.dart';
import '../../theme/app_theme.dart';

class AddContributionScreen extends StatefulWidget {
  final String tenderId;
  const AddContributionScreen({super.key, required this.tenderId});

  @override
  State<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends State<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _bankRefCtrl = TextEditingController();
  final TenderService _tenderService = TenderService();
  final StorageService _storageService = StorageService();

  List<InvestorModel> _investors = [];
  String? _selectedInvestorId;
  DateTime _date = DateTime.now();
  File? _photo;
  bool _isSaving = false;
  bool _loadingInvestors = true;

  @override
  void initState() {
    super.initState();
    _loadInvestors();
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
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
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
                  TextFormField(
                    controller: _bankRefCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Bank Reference / UTR Number',
                      prefixIcon: Icon(Icons.receipt),
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
                    label: Text(_photo == null
                        ? 'Attach Receipt Photo'
                        : 'Change Photo'),
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
                        : const Text('Record Contribution'),
                  ),
                ],
              ),
            ),
    );
  }
}
