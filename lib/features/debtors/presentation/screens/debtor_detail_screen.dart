import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../debts/domain/entities/debt.dart';
import '../../domain/entities/debtor.dart';
import '../providers/debtor_providers.dart';
import 'add_edit_debtor_screen.dart';

// Provider for a single debtor
final debtorByIdProvider = FutureProvider.family<Debtor?, int>((ref, id) async {
  final repository = ref.watch(debtorRepositoryProvider);
  final result = await repository.getDebtorById(id);
  return result.fold(
    (failure) => null,
    (debtor) => debtor,
  );
});

// Placeholder provider for debtor's debts (will be replaced when debt providers are created)
final debtorDebtsProvider = FutureProvider.family<List<Debt>, int>((ref, debtorId) async {
  // TODO: Replace with actual debt repository call when debt providers are implemented
  // final repository = ref.watch(debtRepositoryProvider);
  // final result = await repository.getDebtsByDebtorId(debtorId);
  // return result.fold((failure) => [], (debts) => debts);

  // For now, return empty list
  return [];
});

class DebtorDetailScreen extends ConsumerWidget {
  final int debtorId;

  const DebtorDetailScreen({
    super.key,
    required this.debtorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtorAsync = ref.watch(debtorByIdProvider(debtorId));
    final debtsAsync = ref.watch(debtorDebtsProvider(debtorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qarzdor ma\'lumotlari'),
        actions: [
          debtorAsync.when(
            data: (debtor) => debtor != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToEdit(context, debtor),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: debtorAsync.when(
        data: (debtor) {
          if (debtor == null) {
            return const Center(
              child: Text('Qarzdor topilmadi'),
            );
          }
          return _buildContent(context, ref, debtor, debtsAsync);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Xatolik: $error'),
        ),
      ),
      floatingActionButton: debtorAsync.when(
        data: (debtor) => debtor != null
            ? FloatingActionButton.extended(
                onPressed: () => _navigateToAddDebt(context, debtor),
                icon: const Icon(Icons.add),
                label: const Text('Qarz qo\'shish'),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Debtor debtor,
    AsyncValue<List<Debt>> debtsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(debtorByIdProvider(debtorId));
        ref.invalidate(debtorDebtsProvider(debtorId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderSection(context, debtor),
          const SizedBox(height: 24),
          _buildStatisticsSection(debtor),
          const SizedBox(height: 24),
          _buildContactSection(context, debtor),
          if (debtor.notes != null) ...[
            const SizedBox(height: 24),
            _buildNotesSection(debtor),
          ],
          const SizedBox(height: 24),
          _buildDebtsSection(context, debtsAsync),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Debtor debtor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: _getAvatarColor(debtor.name),
              child: Text(
                _getInitials(debtor.name),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              debtor.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: debtor.hasDebt
                    ? AppTheme.activeDebtColor.withOpacity(0.1)
                    : AppTheme.paidDebtColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                debtor.hasDebt ? 'Qarzdor' : 'Qarz yo\'q',
                style: TextStyle(
                  color: debtor.hasDebt
                      ? AppTheme.activeDebtColor
                      : AppTheme.paidDebtColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(Debtor debtor) {
    final currencyFormat = NumberFormat.currency(
      locale: 'uz_UZ',
      symbol: '',
      decimalDigits: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, size: 20, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Statistika',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildStatRow(
              icon: Icons.attach_money,
              label: 'Jami qarz',
              value: '${currencyFormat.format(debtor.totalDebt)} so\'m',
              color: AppTheme.activeDebtColor,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              icon: Icons.check_circle,
              label: 'To\'langan',
              value: '${currencyFormat.format(debtor.totalPaid)} so\'m',
              color: AppTheme.paidDebtColor,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              icon: Icons.pending,
              label: 'Qolgan qarz',
              value: '${currencyFormat.format(debtor.remainingDebt)} so\'m',
              color: AppTheme.partialDebtColor,
            ),
            if (debtor.totalDebt > 0) ...[
              const SizedBox(height: 16),
              const Text(
                'To\'lov jarayoni',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: debtor.paymentPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    debtor.paymentPercentage >= 100
                        ? AppTheme.paidDebtColor
                        : AppTheme.partialDebtColor,
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${debtor.paymentPercentage.toStringAsFixed(1)}% to\'langan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, Debtor debtor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contact_phone, size: 20, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Aloqa ma\'lumotlari',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (debtor.phone != null) ...[
              _buildContactRow(
                icon: Icons.phone,
                label: 'Telefon',
                value: debtor.phone!,
                onTap: () => _makePhoneCall(debtor.phone!),
                onLongPress: () => _copyToClipboard(context, debtor.phone!),
              ),
              const SizedBox(height: 12),
            ],
            if (debtor.address != null) ...[
              _buildContactRow(
                icon: Icons.location_on,
                label: 'Manzil',
                value: debtor.address!,
                onTap: null,
                onLongPress: () => _copyToClipboard(context, debtor.address!),
              ),
              const SizedBox(height: 12),
            ],
            _buildContactRow(
              icon: Icons.calendar_today,
              label: 'Qo\'shilgan sana',
              value: DateFormat('dd.MM.yyyy').format(debtor.createdAt),
              onTap: null,
              onLongPress: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(Debtor debtor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, size: 20, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Izoh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              debtor.notes!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtsSection(BuildContext context, AsyncValue<List<Debt>> debtsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list_alt, size: 20, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Qarzlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            debtsAsync.when(
              data: (debts) {
                if (debts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hozircha qarzlar yo\'q',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yangi qarz qo\'shish uchun pastdagi tugmani bosing',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: debts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final debt = debts[index];
                    return _buildDebtCard(context, debt);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Qarzlarni yuklashda xatolik',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, Debt debt) {
    final currencyFormat = NumberFormat.currency(
      locale: 'uz_UZ',
      symbol: '',
      decimalDigits: 0,
    );

    Color statusColor;
    switch (debt.status) {
      case DebtStatus.paid:
        statusColor = AppTheme.paidDebtColor;
        break;
      case DebtStatus.partial:
        statusColor = AppTheme.partialDebtColor;
        break;
      case DebtStatus.overdue:
        statusColor = AppTheme.overdueDebtColor;
        break;
      case DebtStatus.active:
        statusColor = AppTheme.activeDebtColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  debt.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(debt.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${currencyFormat.format(debt.amount)} ${debt.currency}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd.MM.yyyy').format(debt.debtDate),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              if (debt.dueDate != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.event, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Muddat: ${DateFormat('dd.MM.yyyy').format(debt.dueDate!)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: debt.isOverdue ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(DebtStatus status) {
    switch (status) {
      case DebtStatus.active:
        return 'Faol';
      case DebtStatus.partial:
        return 'Qisman';
      case DebtStatus.paid:
        return 'To\'langan';
      case DebtStatus.overdue:
        return 'Muddati o\'tgan';
    }
  }

  String _getInitials(String name) {
    final names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0].substring(0, names[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'Q';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];

    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  void _navigateToEdit(BuildContext context, Debtor debtor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDebtorScreen(debtor: debtor),
      ),
    );
  }

  void _navigateToAddDebt(BuildContext context, Debtor debtor) {
    // TODO: Navigate to Add Debt screen when it's created
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Qarz qo\'shish ekrani hali yaratilmagan'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // Show dialog with phone number and options
    // Note: URL launcher would be needed for actual phone dialing
    // For now, just show the phone number
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Nusxa olindi'),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
