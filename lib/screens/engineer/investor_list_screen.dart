import 'package:flutter/material.dart';
import '../../models/investor_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/helpers.dart';

class InvestorListScreen extends StatefulWidget {
  final String tenderId;
  const InvestorListScreen({super.key, required this.tenderId});

  @override
  State<InvestorListScreen> createState() => _InvestorListScreenState();
}

class _InvestorListScreenState extends State<InvestorListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _firestore = FirestoreService();
  bool _isAdding = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _addInvestor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isAdding = true);
    try {
      final investor = InvestorModel(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      await _firestore.addInvestorToTender(widget.tenderId, investor);
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _emailCtrl.clear();
      if (mounted) {
        Navigator.pop(context);
        showAppSnackBar(context, 'Investor added');
      }
    } catch (e) {
      if (mounted) showAppSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Investor'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => validateRequired(v, 'Name')),
              const SizedBox(height: 12),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone, validator: validatePhone),
              const SizedBox(height: 12),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: validateEmail),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addInvestor, child: _isAdding ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Investor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text('Add an investor to this tender', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Investor'),
            ),
          ],
        ),
      ),
    );
  }
}
