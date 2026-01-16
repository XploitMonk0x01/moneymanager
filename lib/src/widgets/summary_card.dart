import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable summary card widget for displaying financial metrics
/// like income, expenses, and balance with consistent styling.
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final bool showSign;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.showSign = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat('#,##0').format(amount.abs());
    final sign = showSign ? (amount >= 0 ? '+' : '-') : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$sign₹$formattedAmount',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of three summary cards for income, expenses, and balance
class SummaryCardRow extends StatelessWidget {
  final double income;
  final double expenses;
  final double? balance;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpensesTap;
  final VoidCallback? onBalanceTap;

  const SummaryCardRow({
    super.key,
    required this.income,
    required this.expenses,
    this.balance,
    this.onIncomeTap,
    this.onExpensesTap,
    this.onBalanceTap,
  });

  @override
  Widget build(BuildContext context) {
    final calculatedBalance = balance ?? (income - expenses);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SummaryCard(
              title: 'Income',
              amount: income,
              color: Colors.green.shade600,
              icon: Icons.trending_up,
              onTap: onIncomeTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Expenses',
              amount: expenses,
              color: Colors.red.shade600,
              icon: Icons.trending_down,
              onTap: onExpensesTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Balance',
              amount: calculatedBalance,
              color: calculatedBalance >= 0
                  ? Colors.blue.shade600
                  : Colors.orange.shade600,
              icon: Icons.account_balance_wallet,
              showSign: true,
              onTap: onBalanceTap,
            ),
          ),
        ],
      ),
    );
  }
}
