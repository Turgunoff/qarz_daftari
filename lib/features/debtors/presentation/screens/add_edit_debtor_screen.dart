import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/debtor.dart';
import '../providers/debtor_providers.dart';

class AddEditDebtorScreen extends ConsumerStatefulWidget {
  final Debtor? debtor;

  const AddEditDebtorScreen({super.key, this.debtor});

  @override
  ConsumerState<AddEditDebtorScreen> createState() =>
      _AddEditDebtorScreenState();
}

class _AddEditDebtorScreenState extends ConsumerState<AddEditDebtorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditMode => widget.debtor != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.debtor!.name;
      _phoneController.text = widget.debtor!.phone ?? '';
      _addressController.text = widget.debtor!.address ?? '';
      _notesController.text = widget.debtor!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Qarzdorni tahrirlash' : 'Yangi qarzdor'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ism *',
                hintText: 'Qarzdor ismini kiriting',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ism kiritilishi shart';
                }
                if (value.trim().length < 2) {
                  return 'Ism kamida 2 ta harfdan iborat bo\'lishi kerak';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Telefon raqami',
                hintText: '+998 90 123 45 67',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-\(\)]')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final cleanNumber = value.replaceAll(
                    RegExp(r'[\s\-\(\)]'),
                    '',
                  );
                  if (cleanNumber.startsWith('+998')) {
                    if (cleanNumber.length != 13) {
                      return 'Noto\'g\'ri telefon raqami';
                    }
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Address Field
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Manzil',
                hintText: 'Qarzdor manzilini kiriting',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Notes Field
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Izoh',
                hintText: 'Qo\'shimcha ma\'lumot',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDebtor,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Saqlash' : 'Qarzdor qo\'shish',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDebtor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final debtor = Debtor(
      id: _isEditMode ? widget.debtor!.id : null,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      totalDebt: _isEditMode ? widget.debtor!.totalDebt : 0,
      totalPaid: _isEditMode ? widget.debtor!.totalPaid : 0,
      createdAt: _isEditMode ? widget.debtor!.createdAt : now,
      updatedAt: now,
    );

    final notifier = ref.read(debtorProvider.notifier);
    final success = _isEditMode
        ? await notifier.modifyDebtor(debtor)
        : await notifier.createDebtor(debtor);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O\'chirish'),
        content: Text(
          '${widget.debtor!.name} ni o\'chirishni xohlaysizmi?\n\n'
          'Ogohlantirish: Bu qarzdorning barcha qarzlari ham o\'chiriladi!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              final success = await ref
                  .read(debtorProvider.notifier)
                  .removeDebtor(widget.debtor!.id!);

              setState(() => _isLoading = false);

              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}
