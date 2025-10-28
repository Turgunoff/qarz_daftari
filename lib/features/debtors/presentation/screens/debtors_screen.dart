import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/debtor_notifier.dart';
import '../providers/debtor_providers.dart';
import '../widgets/debtor_card.dart';
import '../widgets/debtor_statistics_card.dart';
import 'add_edit_debtor_screen.dart';

class DebtorsScreen extends ConsumerStatefulWidget {
  const DebtorsScreen({super.key});

  @override
  ConsumerState<DebtorsScreen> createState() => _DebtorsScreenState();
}

class _DebtorsScreenState extends ConsumerState<DebtorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load debtors when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(debtorProvider.notifier).loadDebtors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtorState = ref.watch(debtorProvider);
    final debtorNotifier = ref.read(debtorProvider.notifier);

    // Show messages
    ref.listen<DebtorState>(debtorProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        debtorNotifier.clearMessages();
      }

      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        debtorNotifier.clearMessages();
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
                  debtorNotifier.searchDebtorsByQuery(value);
                },
              )
            : const Text('Qarzdorlar'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  debtorNotifier.loadDebtors();
                }
              });
            },
          ),
          PopupMenuButton<DebtorFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              debtorNotifier.filterDebtors(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DebtorFilter.all,
                child: Text('Barchasi'),
              ),
              const PopupMenuItem(
                value: DebtorFilter.withDebt,
                child: Text('Qarzi borlar'),
              ),
              const PopupMenuItem(
                value: DebtorFilter.noDebt,
                child: Text('Qarzi yo\'qlar'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => debtorNotifier.loadDebtors(),
        child: debtorState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Statistics Card
                  DebtorStatisticsCard(state: debtorState),

                  // Filter Chips
                  _buildFilterChips(debtorNotifier),

                  // Debtors List
                  Expanded(child: _buildDebtorsList(debtorNotifier)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddDebtor(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Qarzdor qo\'shish'),
      ),
    );
  }

  Widget _buildFilterChips(DebtorNotifier notifier) {
    final currentFilter = ref.watch(debtorProvider).currentFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Barchasi'),
            selected: currentFilter == DebtorFilter.all,
            onSelected: (_) => notifier.filterDebtors(DebtorFilter.all),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Qarzi borlar'),
            selected: currentFilter == DebtorFilter.withDebt,
            onSelected: (_) => notifier.filterDebtors(DebtorFilter.withDebt),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Qarzi yo\'qlar'),
            selected: currentFilter == DebtorFilter.noDebt,
            onSelected: (_) => notifier.filterDebtors(DebtorFilter.noDebt),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtorsList(DebtorNotifier notifier) {
    final filteredDebtors = notifier.filteredDebtors;

    if (filteredDebtors.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredDebtors.length,
      itemBuilder: (context, index) {
        final debtor = filteredDebtors[index];
        return DebtorCard(
          debtor: debtor,
          onTap: () => _navigateToDebtorDetail(context, debtor.id!),
          onEdit: () => _navigateToEditDebtor(context, debtor),
          onDelete: () => _showDeleteConfirmation(context, debtor),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Hozircha qarzdorlar yo\'q',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yangi qarzdor qo\'shish uchun tugmani bosing',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _navigateToAddDebtor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditDebtorScreen()),
    );
  }

  void _navigateToEditDebtor(BuildContext context, debtor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDebtorScreen(debtor: debtor),
      ),
    );
  }

  void _navigateToDebtorDetail(BuildContext context, int debtorId) {
    // TODO: Navigate to debtor detail screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Qarzdor detail: $debtorId')));
  }

  void _showDeleteConfirmation(BuildContext context, debtor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O\'chirish'),
        content: Text('${debtor.name} ni o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(debtorProvider.notifier).removeDebtor(debtor.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}
