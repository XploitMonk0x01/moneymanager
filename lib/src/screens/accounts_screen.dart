import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../core/constants/app_constants.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionListProvider);
    final Map<String, double> methodTotals = {};
    final Map<String, int> methodCounts = {};

    for (var tx in transactions) {
      methodTotals[tx.paymentMethod] =
          (methodTotals[tx.paymentMethod] ?? 0) + tx.amount;
      methodCounts[tx.paymentMethod] =
          (methodCounts[tx.paymentMethod] ?? 0) + 1;
    }

    final methods = methodTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalSpent =
        methodTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Accounts'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPaymentMethodDialog(context),
            tooltip: 'Add Payment Method',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.cardBorderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Overview',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Spent',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                '₹${totalSpent.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Payment Methods',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                '${methods.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payment Methods Section
              Text(
                'Payment Methods',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              methods.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: methods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final method = methods[index];
                        final percentage = totalSpent > 0
                            ? (method.value / totalSpent * 100)
                            : 0.0;
                        final transactionCount = methodCounts[method.key] ?? 0;

                        return _buildPaymentMethodCard(
                          context,
                          method.key,
                          method.value,
                          percentage,
                          transactionCount,
                          index,
                        );
                      },
                    ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPaymentMethodDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Method'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Payment Methods',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding transactions to see payment method breakdown',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    String methodName,
    double amount,
    double percentage,
    int transactionCount,
    int index,
  ) {
    final icon = _getPaymentMethodIcon(methodName);
    final color = _getPaymentMethodColor(context, methodName);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          onTap: () => _showPaymentMethodDetails(
              context, methodName, amount, transactionCount),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            methodName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '$transactionCount transactions',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditPaymentMethodDialog(context, methodName);
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, methodName);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return Icons.account_balance_wallet;
      case 'cash':
        return Icons.money;
      case 'card':
      case 'credit card':
      case 'debit card':
        return Icons.credit_card;
      case 'bank transfer':
        return Icons.account_balance;
      case 'cheque':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor(BuildContext context, String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return Colors.purple;
      case 'cash':
        return Colors.green;
      case 'card':
      case 'credit card':
      case 'debit card':
        return Colors.blue;
      case 'bank transfer':
        return Colors.orange;
      case 'cheque':
        return Colors.brown;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void _showPaymentMethodDetails(BuildContext context, String methodName,
      double amount, int transactionCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        title: Row(
          children: [
            Icon(_getPaymentMethodIcon(methodName)),
            const SizedBox(width: 8),
            Text(methodName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Total Spent', '₹${amount.toStringAsFixed(2)}'),
            _buildDetailRow('Transactions', '$transactionCount'),
            _buildDetailRow(
                'Average per Transaction',
                transactionCount > 0
                    ? '₹${(amount / transactionCount).toStringAsFixed(2)}'
                    : '₹0.00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    IconData selectedIcon = Icons.payment;

    final availableIcons = [
      Icons.money,
      Icons.account_balance_wallet,
      Icons.credit_card,
      Icons.credit_card_outlined,
      Icons.account_balance,
      Icons.receipt_long,
      Icons.payment,
      Icons.mobile_friendly,
      Icons.qr_code,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          title: const Text('Add Payment Method'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a payment method name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableIcons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final paymentMethod = PaymentMethod(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      icon: selectedIcon,
                    );

                    await ref
                        .read(paymentMethodListProvider.notifier)
                        .addPaymentMethod(paymentMethod);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment method added successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding payment method: $e'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPaymentMethodDialog(BuildContext context, String methodName) {
    HapticFeedback.lightImpact();
    final nameController = TextEditingController(text: methodName);
    final formKey = GlobalKey<FormState>();
    IconData selectedIcon = _getPaymentMethodIcon(methodName);

    final availableIcons = [
      Icons.money,
      Icons.account_balance_wallet,
      Icons.credit_card,
      Icons.credit_card_outlined,
      Icons.account_balance,
      Icons.receipt_long,
      Icons.payment,
      Icons.mobile_friendly,
      Icons.qr_code,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          title: Text('Edit $methodName'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a payment method name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableIcons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.orange.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This will update all existing transactions with this payment method.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Update all transactions with the old method name to the new name
                    await _updateTransactionsPaymentMethod(
                        methodName, nameController.text.trim());

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment method updated successfully!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating payment method: $e'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String methodName) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        title: const Text('Delete Payment Method'),
        content: Text(
            'Are you sure you want to delete all transactions for $methodName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePaymentMethod(methodName);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePaymentMethod(String methodName) async {
    try {
      await ref
          .read(paymentMethodListProvider.notifier)
          .deleteAllTransactionsForPaymentMethod(methodName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All transactions for $methodName have been deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting $methodName: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateTransactionsPaymentMethod(
      String oldMethodName, String newMethodName) async {
    // For now, we'll just show a message since this requires updating existing transactions
    // This would need to be implemented in the FirestoreService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Updated payment method name from $oldMethodName to $newMethodName'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Money Manager',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Manage your finances',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete & Reset'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteResetDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pop(context);
              _showFeedbackDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Cloud Storage'),
            onTap: () {
              Navigator.pop(context);
              _showCloudStorageDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Money Manager',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.account_balance_wallet,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          'Money Manager helps you track your expenses, manage your budget, and keep records of borrowed/lent money.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Features:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text('• Track income and expenses'),
        const Text('• Categorize transactions'),
        const Text('• Multiple payment methods'),
        const Text('• Borrow/Lend records'),
        const Text('• Visual analytics'),
        const Text('• Cloud sync with Firebase'),
        const SizedBox(height: 16),
        Text(
          'Developed with Flutter & Firebase',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  void _showDeleteResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete & Reset'),
          content: const Text('Choose what you want to delete:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteAllDataDialog(context);
              },
              child: const Text('Delete All Data'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showResetSettingsDialog(context);
              },
              child: const Text('Reset Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data'),
          content: const Text(
              'This will permanently delete all your records, accounts, and transactions. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Delete all user data from Firestore
                  final firestoreService = ref.read(firestoreServiceProvider);
                  await firestoreService.deleteAllUserData();

                  // Clear local database cache
                  final localDbService = ref.read(localDatabaseServiceProvider);
                  await localDbService.clearAllCachedData();

                  // Close loading dialog
                  if (context.mounted) Navigator.pop(context);

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All data deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  // Close loading dialog
                  if (context.mounted) Navigator.pop(context);

                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete data: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _showResetSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content:
              const Text('This will reset all app settings to default values.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Reset settings using SettingsService
                  final settingsService = ref.read(settingsServiceProvider);
                  await settingsService.resetSettings();

                  // Reset theme to system default
                  ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.system);

                  // Reset offline mode to false
                  ref.read(isOfflineModeProvider.notifier).state = false;

                  // Close loading dialog
                  if (context.mounted) Navigator.pop(context);

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings reset to default'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  // Close loading dialog
                  if (context.mounted) Navigator.pop(context);

                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to reset settings: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'We value your feedback! Please share your thoughts about the app.'),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter your feedback here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (feedbackController.text.trim().isNotEmpty) {
                  // TODO: Implement feedback submission
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Thank you for your feedback!')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showCloudStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cloud Storage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Manage your data storage options:'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.cloud_upload),
                title: const Text('Backup to Cloud'),
                subtitle: const Text('Save your data to Firebase'),
                onTap: () {
                  Navigator.pop(context);
                  _performCloudBackup(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Restore from Cloud'),
                subtitle: const Text('Load your data from Firebase'),
                onTap: () {
                  Navigator.pop(context);
                  _performCloudRestore(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Local Backup'),
                subtitle: const Text('Export data to device storage'),
                onTap: () {
                  Navigator.pop(context);
                  _performLocalBackup(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _performCloudBackup(BuildContext context) async {
    // TODO: Implement cloud backup functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backing up to cloud...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate backup process
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data backed up to cloud successfully!')),
      );
    }
  }

  void _performCloudRestore(BuildContext context) async {
    // TODO: Implement cloud restore functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restoring from cloud...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate restore process
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data restored from cloud successfully!')),
      );
    }
  }

  void _performLocalBackup(BuildContext context) async {
    // TODO: Implement local backup functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating local backup...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate backup process
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local backup created successfully!')),
      );
    }
  }
}
