import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/debt.dart';
import '../../../debtors/presentation/providers/debtor_providers.dart';
import '../providers/debt_providers.dart';

class AddEditDebtScreen extends ConsumerStatefulWidget {
  final Debt? debt;

  const AddEditDebtScreen({super.key, this.debt});

  @override
  ConsumerState<AddEditDebtScreen> createState() => _AddEditDebtScreenState();
}

class _AddEditDebtScreenState extends ConsumerState<AddEditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditMode => widget.debt != null;

  int? _selectedDebtorId;
  DateTime _debtDate = DateTime.now();
  DateTime? _dueDate;
  String _currency = 'UZS';

  @override
  void initState() {
    super.initState();
    // Load debtors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(debtorProvider.notifier).loadDebtors();
    });

    if (_isEditMode) {
      _selectedDebtorId = widget.debt!.debtorId;
      _amountController.text = widget.debt!.amount.toString();
      _descriptionController.text = widget.debt!.description;
      _debtDate = widget.debt!.debtDate;
      _dueDate = widget.debt!.dueDate;
      _currency = widget.debt!.currency;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtorState = ref.watch(debtorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Qarzni tahrirlash' : 'Yangi qarz'),
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
            // Debtor Selection
            if (debtorState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (debtorState.debtors.isEmpty)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Avval qarzdor qo\'shing',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              DropdownButtonFormField<int>(
                value: _selectedDebtorId,
                decoration: InputDecoration(
                  labelText: 'Qarzdor *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: debtorState.debtors.map((debtor) {
                  return DropdownMenuItem(
                    value: debtor.id,
                    child: Text(debtor.name),
                  );
                }).toList(),
                onChanged: _isEditMode
                    ? null
                    : (value) {
                        setState(() => _selectedDebtorId = value);
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Qarzdorni tanlang';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Qarz miqdori *',
                hintText: '0',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: _currency,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Qarz miqdorini kiriting';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Qarz miqdori 0 dan katta bo\'lishi kerak';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Tavsif *',
                hintText: 'Qarz tavsifi',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Tavsif kiritilishi shart';
                }
                if (value.trim().length < 3) {
                  return 'Tavsif kamida 3 ta harfdan iborat bo\'lishi kerak';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Debt Date Field
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Qarz sanasi'),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_debtDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _debtDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _debtDate = date);
                }
              },
            ),

            const SizedBox(height: 16),

            // Due Date Field
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              leading: const Icon(Icons.event),
              title: const Text('Tugash sanasi (ixtiyoriy)'),
              subtitle: Text(
                _dueDate != null
                    ? DateFormat('dd.MM.yyyy').format(_dueDate!)
                    : 'Tanlanmagan',
              ),
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: _debtDate,
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _dueDate = date);
                }
              },
            ),

            const SizedBox(height: 16),

            // Currency Selection
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: InputDecoration(
                labelText: 'Valyuta',
                prefixIcon: const Icon(Icons.currency_exchange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'UZS', child: Text('UZS - So\'m')),
                DropdownMenuItem(value: 'USD', child: Text('USD - Dollar')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR - Yevro')),
                DropdownMenuItem(value: 'RUB', child: Text('RUB - Rubl')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _currency = value);
                }
              },
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDebt,
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
                        _isEditMode ? 'Saqlash' : 'Qarz qo\'shish',
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

  Future<void> _saveDebt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final debt = Debt(
      id: _isEditMode ? widget.debt!.id : null,
      debtorId: _selectedDebtorId!,
      amount: double.parse(_amountController.text.trim()),
      description: _descriptionController.text.trim(),
      debtDate: _debtDate,
      dueDate: _dueDate,
      status: _isEditMode ? widget.debt!.status : DebtStatus.active,
      currency: _currency,
      createdAt: _isEditMode ? widget.debt!.createdAt : now,
      updatedAt: now,
    );

    final notifier = ref.read(debtProvider.notifier);
    final success = _isEditMode
        ? await notifier.modifyDebt(debt)
        : await notifier.createDebt(debt);

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
          '${widget.debt!.description} ni o\'chirishni xohlaysizmi?\n\n'
          'Ogohlantirish: Bu qarzning barcha to\'lovlari ham o\'chiriladi!',
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
                  .read(debtProvider.notifier)
                  .removeDebt(widget.debt!.id!);

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
