import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../debtors/presentation/screens/debtors_screen.dart';
import '../../../debtors/presentation/screens/add_edit_debtor_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          _buildDrawerHeader(context),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  title: 'Bosh sahifa',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.people,
                  title: 'Qarzdorlar',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DebtorsScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.receipt_long,
                  title: 'Qarzlar',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Debts screen
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.payment,
                  title: 'To\'lovlar',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Payments screen
                  },
                ),

                const Divider(height: 1),

                _buildMenuItem(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Statistika',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Statistics screen
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: 'Tarix',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to History screen
                  },
                ),

                const Divider(height: 1),

                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Sozlamalar',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to Settings screen
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Yordam',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
              ],
            ),
          ),

          // Footer
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 35,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 16),

              // User Name
              const Text(
                'Foydalanuvchi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // User Info
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  const SizedBox(width: 8),
                  const Text(
                    'Faol',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 26),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Versiya 1.0.0',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yordam'),
        content: const Text(
          'Qarz Daftari ilovasi qarzlaringizni oson boshqarish uchun yaratilgan.\n\n'
          'Agar savolingiz bo\'lsa, biz bilan bog\'laning:\n'
          'Email: support@richesgroup.dev',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
