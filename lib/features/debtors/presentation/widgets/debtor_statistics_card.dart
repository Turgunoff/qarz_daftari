import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/debtor_notifier.dart';

class DebtorStatisticsCard extends StatelessWidget {
  final DebtorState state;

  const DebtorStatisticsCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'uz_UZ',
      symbol: '',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Umumiy statistika',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.totalDebtors} qarzdor',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Main Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.arrow_upward,
                      label: 'Jami qarz',
                      value: currencyFormat.format(state.totalDebtAmount),
                      iconColor: Colors.red[300]!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.arrow_downward,
                      label: 'To\'langan',
                      value: currencyFormat.format(state.totalPaidAmount),
                      iconColor: Colors.green[300]!,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Secondary Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.account_balance_wallet,
                      label: 'Qolgan',
                      value: currencyFormat.format(state.totalRemainingAmount),
                      iconColor: Colors.orange[300]!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      label: 'Qarzi borlar',
                      value: '${state.debtorsWithDebt}',
                      iconColor: Colors.blue[300]!,
                      isCount: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isCount ? value : '$value so\'m',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
