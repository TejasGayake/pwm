import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tender_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tender_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/formatters.dart';

class AddEditTenderScreen extends StatefulWidget {
  final TenderModel? tender;
  const AddEditTenderScreen({super.key, this.tender});

  @override
  State<AddEditTenderScreen> createState() => _AddEditTenderScreenState();
}

class _AddEditTenderScreenState extends State<AddEditTenderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _amountCtrl;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  String _status = 'active';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tender?.name ?? '');
    _locationCtrl = TextEditingController(text: widget.tender?.location ?? '');
    _amountCtrl = TextEditingController(text: widget.tender?.targetAmount.toString() ?? '');
    if (widget.tender != null) {
      _startDate = widget.tender!.startDate;
      _endDate = widget.tender!.endDate;
      _status = widget.tender!.status;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final tenderProvider = Provider.of<TenderProvider>(context, listen: false);
      final tender = TenderModel(
        id: widget.tender?.id,
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        targetAmount: double.parse(_amountCtrl.text),
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        createdBy: auth.user!.uid,
      );
      if (widget.tender == null) {
        await tenderProvider.createTender(tender);
      } else {
        await tenderProvider.updateTender(widget.tender!.id!, tender.toMap());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showAppSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tender == null ? 'Create Tender' : 'Edit Tender'),
        actions: [
          TextButton(onPressed: _isSaving ? null : _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Tender Name'),
              validator: (v) => validateRequired(v, 'Tender name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (v) => validateRequired(v, 'Location'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Target Amount (₹)', prefixText: '₹ '),
              keyboardType: TextInputType.number,
              validator: validateAmount,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(formatDate(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(true),
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(formatDate(_endDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.tender == null ? 'Create Tender' : 'Update Tender'),
            ),
          ],
        ),
      ),
    );
  }
}
