import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/debt.dart';
import '../providers/debt_notifier.dart';
import '../providers/debt_providers.dart';
import '../widgets/debt_card.dart';
import 'add_edit_debt_screen.dart';
import 'debt_detail_screen.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  DebtStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Load debts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(debtProvider.notifier).loadDebts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtState = ref.watch(debtProvider);
    final debtNotifier = ref.read(debtProvider.notifier);

    // Show messages
    ref.listen<DebtState>(debtProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        debtNotifier.clearMessages();
      }

      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        debtNotifier.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Qidirish...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild to filter
                },
              )
            : const Text('Qarzlar'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => debtNotifier.loadDebts(),
        child: debtState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Statistics Card
                  _buildStatisticsCard(debtState),

                  // Filter Chips
                  _buildFilterChips(),

                  // Debts List
                  Expanded(child: _buildDebtsList(debtNotifier)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddDebt(context),
        icon: const Icon(Icons.add),
        label: const Text('Qarz qo\'shish'),
      ),
    );
  }

  Widget _buildStatisticsCard(DebtState state) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatItem(
                  'Jami',
                  state.totalDebts.toString(),
                  Colors.blue,
                  Icons.list,
                ),
                _buildStatItem(
                  'Faol',
                  state.activeDebts.toString(),
                  Colors.orange,
                  Icons.pending,
                ),
                _buildStatItem(
                  'To\'langan',
                  state.paidDebts.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatItem(
                  'Muddati o\'tgan',
                  state.overdueDebts.toString(),
                  Colors.red,
                  Icons.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Barchasi'),
            selected: _selectedFilter == null,
            onSelected: (_) => setState(() => _selectedFilter = null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Faol'),
            selected: _selectedFilter == DebtStatus.active,
            onSelected: (_) => setState(() => _selectedFilter = DebtStatus.active),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Qisman to\'langan'),
            selected: _selectedFilter == DebtStatus.partial,
            onSelected: (_) =>
                setState(() => _selectedFilter = DebtStatus.partial),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('To\'langan'),
            selected: _selectedFilter == DebtStatus.paid,
            onSelected: (_) => setState(() => _selectedFilter = DebtStatus.paid),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Muddati o\'tgan'),
            selected: _selectedFilter == DebtStatus.overdue,
            onSelected: (_) =>
                setState(() => _selectedFilter = DebtStatus.overdue),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsList(DebtNotifier notifier) {
    var filteredDebts = ref.watch(debtProvider).debts;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredDebts = filteredDebts
          .where((debt) => debt.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply status filter
    if (_selectedFilter != null) {
      if (_selectedFilter == DebtStatus.overdue) {
        filteredDebts = filteredDebts.where((debt) => debt.isOverdue).toList();
      } else {
        filteredDebts =
            filteredDebts.where((debt) => debt.status == _selectedFilter).toList();
      }
    }

    if (filteredDebts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredDebts.length,
      itemBuilder: (context, index) {
        final debt = filteredDebts[index];
        return DebtCard(
          debt: debt,
          onTap: () => _navigateToDebtDetail(context, debt.id!),
          onEdit: () => _navigateToEditDebt(context, debt),
          onDelete: () => _showDeleteConfirmation(context, debt),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Hozircha qarzlar yo\'q',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yangi qarz qo\'shish uchun tugmani bosing',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _navigateToAddDebt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditDebtScreen()),
    );
  }

  void _navigateToEditDebt(BuildContext context, Debt debt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDebtScreen(debt: debt),
      ),
    );
  }

  void _navigateToDebtDetail(BuildContext context, int debtId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebtDetailScreen(debtId: debtId),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Debt debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O\'chirish'),
        content: Text(
          '${debt.description} ni o\'chirishni xohlaysizmi?\n\n'
          'Ogohlantirish: Bu qarzning barcha to\'lovlari ham o\'chiriladi!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(debtProvider.notifier).removeDebt(debt.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}
