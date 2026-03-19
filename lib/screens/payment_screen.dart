import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class PaymentScreen extends StatelessWidget {
  final double totalBill;

  const PaymentScreen({super.key, required this.totalBill});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.scaffold(context);
    final sectionHeaderColor = isDark ? Colors.white38 : Colors.grey.shade500;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true, // Add this line
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          totalBill > 0 ? 'Bill total: ₹${totalBill.toStringAsFixed(0)}' : 'Payment Methods',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSectionHeader('RECOMMENDED', sectionHeaderColor),
          _buildPaymentGroup(context, [
            _buildPaymentOption(
              context,
              'Google Pay UPI',
              icon: Icons.account_balance_wallet,
              showArrow: true,
            ),
          ]),
          const SizedBox(height: 24),

          _buildSectionHeader('CARDS', sectionHeaderColor),
          _buildPaymentGroup(context, [
            _buildPaymentOption(
              context,
              'Add credit or debit cards',
              icon: Icons.credit_card,
              isAdd: true,
            ),
            _buildPaymentOption(
              context,
              'Add Pluxee',
              icon: Icons.card_membership,
              isAdd: true,
            ),
          ]),
          const SizedBox(height: 24),

          _buildSectionHeader('PAY BY ANY UPI APP', sectionHeaderColor),
          _buildPaymentGroup(context, [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPaymentOption(
                  context,
                  'Kotak 811 UPI',
                  icon: Icons.account_balance,
                  showArrow: false,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Currently disabled due to a technical problem.',
                      style: TextStyle(color: Color(0xFFE23744), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 24),

          _buildSectionHeader('WALLETS', sectionHeaderColor),
          _buildPaymentGroup(context, [
            _buildPaymentOption(
              context,
              'Amazon Pay Balance',
              icon: Icons.account_balance_wallet_outlined,
              isAdd: true,
            ),
            _buildPaymentOption(
              context,
              'Mobikwik',
              icon: Icons.wallet,
              isAdd: true,
            ),
          ]),
          const SizedBox(height: 24),

          _buildSectionHeader('PAY LATER', sectionHeaderColor),
          _buildPaymentGroup(context, [
            _buildPaymentOption(
              context,
              'Amazon Pay Later',
              icon: Icons.calendar_month_outlined,
              isAdd: true,
            ),
            _buildPaymentOption(
              context,
              'LazyPay',
              icon: Icons.timer_outlined,
              isAdd: true,
            ),
          ]),
          const SizedBox(height: 24),

          _buildSectionHeader('NETBANKING', sectionHeaderColor),
          _buildPaymentGroup(context, [
            _buildPaymentOption(
              context,
              'Netbanking',
              icon: Icons.account_balance_outlined,
              isAdd: true,
            ),
          ]),
          const SizedBox(height: 24),

          _buildSectionHeader('PAY ON DELIVERY', sectionHeaderColor),
          _buildPaymentGroup(context, [
            _buildPaymentOption(
              context,
              'Pay on delivery',
              subtitle: 'UPI/Cash',
              icon: Icons.money,
              showArrow: true,
            ),
          ]),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 12),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildPaymentGroup(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.card(context);
    final dividerColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) return Divider(height: 1, color: dividerColor, indent: 64);
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, 
    String title, {
    String? subtitle,
    required IconData icon,
    bool showArrow = false,
    bool isAdd = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.pop(context, title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.transparent, // Background handled by group
        child: Row(
          children: [
            Container(
              width: 44,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.grey.shade400, size: 20),
            if (isAdd)
              Icon(Icons.add, color: Colors.green.shade700, size: 20),
          ],
        ),
      ),
    );
  }
}
