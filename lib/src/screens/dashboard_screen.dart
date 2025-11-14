import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/models.dart';
import '../providers/providers.dart';
import '../data/category_data.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late ScrollController _scrollController;
  bool _isExtended = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _isExtended = _scrollController.offset < 100;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsyncValue = ref.watch(transactionStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('MoneyManager'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'categories':
                  _showCategoryManagement(context);
                  break;
                case 'upi_apps':
                  _showUpiAppManagement(context);
                  break;
                case 'autopay':
                  _showAutoPayManagement(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Manage Categories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'upi_apps',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet),
                    SizedBox(width: 8),
                    Text('Manage UPI Apps'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'autopay',
                child: Row(
                  children: [
                    Icon(Icons.autorenew),
                    SizedBox(width: 8),
                    Text('AutoPay'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MoneyManager',
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
              leading: const Icon(Icons.category),
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                _showCategoryManagement(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Manage UPI Apps'),
              onTap: () {
                Navigator.pop(context);
                _showUpiAppManagement(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
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
      ),
      body: transactionsAsyncValue.when(
        data: (transactions) => transactions.isEmpty
            ? const Center(
                child: Text(
                  'No transactions yet.\nTap + to add your first transaction!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final groupedTransactions =
                              _groupTransactionsByDate(transactions);
                          final dates = groupedTransactions.keys.toList()
                            ..sort((a, b) => b.compareTo(a));

                          if (index >= dates.length) return null;

                          final date = dates[index];
                          final dayTransactions = groupedTransactions[date]!;

                          // Calculate net amount (income - expenses)
                          final totalIncome = dayTransactions
                              .where((t) => t.isIncome)
                              .fold<double>(0, (sum, t) => sum + t.amount);
                          final totalExpenses = dayTransactions
                              .where((t) => !t.isIncome)
                              .fold<double>(0, (sum, t) => sum + t.amount);
                          final netAmount = totalIncome - totalExpenses;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDate(date),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      '${netAmount >= 0 ? '+' : ''}₹${NumberFormat('#,##0.00').format(netAmount.abs())}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: _getTransactionColor(
                                                netAmount >= 0),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              ...dayTransactions.map((transaction) =>
                                  _buildTransactionCard(transaction, context)),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                        childCount:
                            _groupTransactionsByDate(transactions).keys.length,
                      ),
                    ),
                  ),
                ],
              ),
        loading: () => _buildExpressiveLoading(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load transactions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.refresh(transactionStreamProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _isExtended ? 'Add Transaction' : '',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Helper method to get color for income/expense
  Color _getTransactionColor(bool isIncome) {
    return isIncome
        ? Colors.green.shade600
        : Theme.of(context).colorScheme.error;
  }

  Widget _buildTransactionCard(Transaction transaction, BuildContext context) {
    // Get categories from provider to support custom categories
    final categories = ref.watch(categoryListProvider);
    final category = categories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => Category(
        id: transaction.categoryId,
        name: CategoryData.getName(transaction.categoryId), // Fallback
        icon: CategoryData.getIcon(transaction.categoryId),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: CategoryData.getColor(category.id).withOpacity(0.2),
          child: Icon(
            category.icon,
            color: CategoryData.getColor(category.id),
          ),
        ),
        title: Text(category.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.notes?.isNotEmpty == true) Text(transaction.notes!),
            Row(
              children: [
                _buildPaymentMethodIcon(
                    transaction.paymentMethod, transaction.upiApp, context),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.isIncome ? '+' : '-'}₹${NumberFormat('#,##0.00').format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getTransactionColor(transaction.isIncome),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                if (value == 'view') {
                  _viewTransaction(transaction);
                } else if (value == 'edit') {
                  _editTransaction(transaction);
                } else if (value == 'delete') {
                  _deleteTransaction(transaction);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
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
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(
      String paymentMethod, String? upiApp, BuildContext context) {
    switch (paymentMethod.toLowerCase()) {
      case 'upi':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, size: 20),
            const SizedBox(width: 4),
            if (upiApp != null)
              Text(
                upiApp,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        );
      case 'cash':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.money, size: 20, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              'Cash',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 'card':
      case 'credit card':
      case 'debit card':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.credit_card, size: 20, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              'Card',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 'bank transfer':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance, size: 20, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'Bank',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payment, size: 20),
            const SizedBox(width: 4),
            Text(
              paymentMethod,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
    }
  }

  void _viewTransaction(Transaction transaction) {
    final categories = ref.read(categoryListProvider);

    final category = categories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => Category(
        id: transaction.categoryId,
        name: CategoryData.getName(transaction.categoryId), // Fallback
        icon: CategoryData.getIcon(transaction.categoryId),
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  CategoryData.getColor(category.id).withOpacity(0.2),
              child: Icon(
                category.icon,
                color: CategoryData.getColor(category.id),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a')
                        .format(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Type',
                transaction.isIncome ? 'Income' : 'Expense',
                _getTransactionColor(transaction.isIncome),
                transaction.isIncome
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
              ),
              const Divider(),
              _buildDetailRow(
                'Amount',
                '₹${NumberFormat('#,##,##0.00').format(transaction.amount)}',
                _getTransactionColor(transaction.isIncome),
                Icons.currency_rupee,
              ),
              const Divider(),
              _buildDetailRow(
                'Category',
                category.name,
                CategoryData.getColor(category.id),
                category.icon,
              ),
              const Divider(),
              _buildDetailRow(
                'Payment Method',
                transaction.paymentMethod,
                Theme.of(context).colorScheme.primary,
                _getPaymentIcon(transaction.paymentMethod),
              ),
              if (transaction.upiApp != null) ...[
                const Divider(),
                _buildDetailRow(
                  'UPI App',
                  transaction.upiApp!,
                  Theme.of(context).colorScheme.primary,
                  Icons.account_balance_wallet,
                ),
              ],
              if (transaction.notes?.isNotEmpty == true) ...[
                const Divider(),
                _buildDetailRow(
                  'Notes',
                  transaction.notes!,
                  Theme.of(context).colorScheme.onSurface,
                  Icons.note,
                ),
              ],
              const Divider(),
              _buildDetailRow(
                'Date',
                DateFormat('EEEE, MMM dd, yyyy').format(transaction.date),
                Theme.of(context).colorScheme.onSurface,
                Icons.calendar_today,
              ),
              _buildDetailRow(
                'Time',
                DateFormat('hh:mm a').format(transaction.date),
                Theme.of(context).colorScheme.onSurface,
                Icons.access_time,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _editTransaction(transaction);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
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
      default:
        return Icons.payment;
    }
  }

  void _editTransaction(Transaction transaction) {
    final categories = ref.read(categoryListProvider);
    final upiApps = ref.read(upiAppListProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _EditTransactionSheet(
          transaction: transaction,
          categories: categories,
          upiApps: upiApps,
        ),
      ),
    );
  }

  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(transactionListProvider.notifier)
                  .removeTransaction(transaction.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Transaction deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCategoryManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const _CategoryManagementSheet(),
      ),
    );
  }

  void _showUpiAppManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const _UpiAppManagementSheet(),
      ),
    );
  }

  void _showAutoPayManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const _AutoPayManagementSheet(),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    final categories = ref.read(categoryListProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _AddTransactionSheet(
          categories: categories,
        ),
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
    final Map<String, bool> selectedOptions = {
      'transactions': false,
      'records': false,
      'categories': false,
      'payment_methods': false,
      'upi_apps': false,
    };

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: const Text('Delete Data'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select what you want to delete:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Transactions'),
                      subtitle: const Text('All income and expense records'),
                      value: selectedOptions['transactions'],
                      onChanged: (bool? value) {
                        setState(() =>
                            selectedOptions['transactions'] = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Borrow/Lend Records'),
                      subtitle: const Text('All lending and borrowing records'),
                      value: selectedOptions['records'],
                      onChanged: (bool? value) {
                        setState(
                            () => selectedOptions['records'] = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Custom Categories'),
                      subtitle: const Text('Only custom-created categories'),
                      value: selectedOptions['categories'],
                      onChanged: (bool? value) {
                        setState(() =>
                            selectedOptions['categories'] = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Custom Payment Methods'),
                      subtitle: const Text('Custom payment options'),
                      value: selectedOptions['payment_methods'],
                      onChanged: (bool? value) {
                        setState(() => selectedOptions['payment_methods'] =
                            value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Custom UPI Apps'),
                      subtitle: const Text('Reset to default UPI apps'),
                      value: selectedOptions['upi_apps'],
                      onChanged: (bool? value) {
                        setState(
                            () => selectedOptions['upi_apps'] = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final hasSelection =
                        selectedOptions.values.any((v) => v == true);
                    if (!hasSelection) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select at least one option')),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (loadingContext) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    try {
                      final firestoreService =
                          ref.read(firestoreServiceProvider);
                      await firestoreService.deleteSelectedUserData(
                        transactions: selectedOptions['transactions']!,
                        records: selectedOptions['records']!,
                        customCategories: selectedOptions['categories']!,
                        customPaymentMethods:
                            selectedOptions['payment_methods']!,
                        customUpiApps: selectedOptions['upi_apps']!,
                      );

                      // Clear local cache for selected items
                      final localDbService =
                          ref.read(localDatabaseServiceProvider);
                      if (selectedOptions['transactions']!) {
                        await localDbService.clearCachedTransactions();
                      }
                      if (selectedOptions['records']!) {
                        await localDbService.clearCachedRecords();
                      }
                      if (selectedOptions['categories']!) {
                        await localDbService.clearCachedCategories();
                      }
                      if (selectedOptions['payment_methods']!) {
                        await localDbService.clearCachedPaymentMethods();
                      }

                      if (context.mounted) Navigator.pop(context);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Selected data deleted successfully'),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) Navigator.pop(context);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete data: $e'),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error),
                  child: const Text('Delete Selected'),
                ),
              ],
            );
          },
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
                      SnackBar(
                        content: const Text('Settings reset to default'),
                        backgroundColor: Colors.green.shade600,
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
                        backgroundColor: Theme.of(context).colorScheme.error,
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
              onPressed: () async {
                if (feedbackController.text.trim().isNotEmpty) {
                  Navigator.pop(context);

                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    // Submit feedback to Firestore
                    await firestore.FirebaseFirestore.instance
                        .collection('feedback')
                        .add({
                      'message': feedbackController.text.trim(),
                      'timestamp': firestore.FieldValue.serverTimestamp(),
                      'userId': 'user_${DateTime.now().millisecondsSinceEpoch}',
                    });

                    if (context.mounted) Navigator.pop(context);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Thank you for your feedback!'),
                          backgroundColor: Colors.green.shade600,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to submit feedback: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }

                  feedbackController.dispose();
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Backing up to cloud...')),
          ],
        ),
      ),
    );

    try {
      // Get all data
      final transactionsSnapshot = await firestore.FirebaseFirestore.instance
          .collection('transactions')
          .get();
      final recordsSnapshot = await firestore.FirebaseFirestore.instance
          .collection('records')
          .get();
      final categoriesSnapshot = await firestore.FirebaseFirestore.instance
          .collection('categories')
          .get();
      final upiAppsSnapshot = await firestore.FirebaseFirestore.instance
          .collection('upi_apps')
          .get();

      // Create backup document
      final backupData = {
        'timestamp': firestore.FieldValue.serverTimestamp(),
        'transactionsCount': transactionsSnapshot.docs.length,
        'recordsCount': recordsSnapshot.docs.length,
        'categoriesCount': categoriesSnapshot.docs.length,
        'upiAppsCount': upiAppsSnapshot.docs.length,
        'deviceInfo': 'MoneyManager Backup',
      };

      await firestore.FirebaseFirestore.instance
          .collection('backups')
          .add(backupData);

      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data backed up to cloud successfully!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _performCloudRestore(BuildContext context) async {
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore from Cloud'),
        content: const Text(
            'Your data is automatically synced with Firebase Cloud Firestore. '
            'All your transactions, records, and settings are already available. '
            '\n\nDo you want to refresh the data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Refreshing data from cloud...')),
          ],
        ),
      ),
    );

    try {
      // Refresh all providers
      ref.invalidate(transactionStreamProvider);
      ref.invalidate(recordListProvider);
      ref.invalidate(categoryListProvider);
      ref.invalidate(upiAppListProvider);

      // Wait a moment for streams to refresh
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data refreshed from cloud successfully!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _performLocalBackup(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Creating local backup...')),
          ],
        ),
      ),
    );

    try {
      // Get all data
      final transactionsSnapshot = await firestore.FirebaseFirestore.instance
          .collection('transactions')
          .get();
      final recordsSnapshot = await firestore.FirebaseFirestore.instance
          .collection('records')
          .get();

      // Create backup data structure
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'transactions':
            transactionsSnapshot.docs.map((doc) => doc.data()).toList(),
        'records': recordsSnapshot.docs.map((doc) => doc.data()).toList(),
      };

      // Save to local database
      final localDb = ref.read(localDatabaseServiceProvider);

      // Cache transactions locally
      await localDb.cacheTransactions(
        transactionsSnapshot.docs.map((doc) {
          final data = doc.data();
          return Transaction(
            id: doc.id,
            amount: (data['amount'] as num).toDouble(),
            categoryId: data['categoryId'] as String,
            paymentMethod: data['paymentMethod'] as String,
            upiApp: data['upiApp'] as String?,
            notes: data['notes'] as String?,
            date: (data['date'] as firestore.Timestamp).toDate(),
            isIncome: data['isIncome'] as bool,
          );
        }).toList(),
      );

      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Local backup created successfully!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Local backup failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Local backup failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildExpressiveLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Material 3 Expressive Loading Animation
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your transactions...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your financial data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Animated loading dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 400 + (index * 200)),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Transaction>> _groupTransactionsByDate(
      List<Transaction> transactions) {
    final Map<DateTime, List<Transaction>> groupedTransactions = {};

    for (final transaction in transactions) {
      final date = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      if (groupedTransactions[date] == null) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    return groupedTransactions;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}

class _CategoryManagementSheet extends ConsumerStatefulWidget {
  const _CategoryManagementSheet();

  @override
  ConsumerState<_CategoryManagementSheet> createState() =>
      _CategoryManagementSheetState();
}

class _CategoryManagementSheetState
    extends ConsumerState<_CategoryManagementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.shopping_bag,
    Icons.movie,
    Icons.local_hospital,
    Icons.school,
    Icons.home,
    Icons.directions_car,
    Icons.flight,
    Icons.sports_soccer,
    Icons.book,
    Icons.music_note,
    Icons.pets,
    Icons.fitness_center,
    Icons.phone,
    Icons.computer,
    Icons.local_grocery_store,
    Icons.local_cafe,
    Icons.business,
    Icons.category,
  ];

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Manage Categories',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Add new category form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Select Icon:',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _availableIcons[index];
                          final isSelected = icon == _selectedIcon;
                          return InkWell(
                            onTap: () => setState(() => _selectedIcon = icon),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 28,
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _addCategory,
                        child: const Text('Add Category'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Existing categories
          Text(
            'Existing Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      category.icon,
                      color: CategoryData.getColor(category.id),
                    ),
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editCategory(category),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Theme.of(context).colorScheme.error),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        icon: _selectedIcon,
        isCustom: true,
      );

      try {
        // Add to provider
        await ref.read(categoryListProvider.notifier).addCategory(newCategory);

        // Reset form
        _nameController.clear();
        setState(() => _selectedIcon = Icons.category);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add category: $e')),
          );
        }
      }
    }
  }

  void _editCategory(Category category) {
    // Placeholder for edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${category.name} coming soon!')),
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(categoryListProvider.notifier)
                    .removeCategory(category.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${category.name} deleted successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete category: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// UPI App Management Sheet
class _UpiAppManagementSheet extends ConsumerStatefulWidget {
  const _UpiAppManagementSheet();

  @override
  ConsumerState<_UpiAppManagementSheet> createState() =>
      _UpiAppManagementSheetState();
}

class _UpiAppManagementSheetState
    extends ConsumerState<_UpiAppManagementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final upiApps = ref.watch(upiAppListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Manage UPI Apps',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Add new UPI app form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New UPI App',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'UPI App Name',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., Google Pay, PhonePe',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter UPI app name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _addUpiApp,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Existing UPI apps
          Text(
            'Existing UPI Apps',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              itemCount: upiApps.length,
              itemBuilder: (context, index) {
                final upiApp = upiApps[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      size: 32,
                    ),
                    title: Text(upiApp.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteUpiApp(upiApp),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addUpiApp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newUpiApp = UpiApp(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        iconAsset: '',
      );

      try {
        await ref.read(upiAppListProvider.notifier).addUpiApp(newUpiApp);
        _nameController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('UPI app added successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add UPI app: $e')),
          );
        }
      }
    }
  }

  void _deleteUpiApp(UpiApp upiApp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete UPI App'),
        content: Text('Are you sure you want to delete "${upiApp.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(upiAppListProvider.notifier)
                    .removeUpiApp(upiApp.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${upiApp.name} deleted successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete UPI app: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class _AddTransactionSheet extends ConsumerStatefulWidget {
  final List<Category> categories;

  const _AddTransactionSheet({
    required this.categories,
  });

  @override
  ConsumerState<_AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0;
  String _category = '';
  String _paymentMethod = 'Cash';
  String? _upiApp;
  String _notes = '';
  bool _isIncome = false;
  final DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Watch UPI apps so the list updates when new apps are added
    final upiApps = ref.watch(upiAppListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Add Transaction',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction type toggle
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Type',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('Expense'),
                                    value: false,
                                    groupValue: _isIncome,
                                    onChanged: (value) {
                                      setState(() {
                                        _isIncome = value!;
                                      });
                                    },
                                    activeColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('Income'),
                                    value: true,
                                    groupValue: _isIncome,
                                    onChanged: (value) {
                                      setState(() {
                                        _isIncome = value!;
                                      });
                                    },
                                    activeColor: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) => _amount = double.parse(value!),
                    ),
                    const SizedBox(height: 16),

                    // Category dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _category.isEmpty ? null : _category,
                      items: widget.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(
                                category.icon,
                                size: 20,
                                color: CategoryData.getColor(category.id),
                              ),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _category = value!),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Payment method dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                      ),
                      value: _paymentMethod,
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Card', child: Text('Card')),
                        DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                        DropdownMenuItem(
                            value: 'Bank Transfer',
                            child: Text('Bank Transfer')),
                      ],
                      onChanged: (value) => setState(() {
                        _paymentMethod = value!;
                        if (_paymentMethod != 'UPI') _upiApp = null;
                      }),
                    ),

                    // UPI App selection (only if UPI is selected)
                    if (_paymentMethod == 'UPI') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'UPI App',
                          border: OutlineInputBorder(),
                        ),
                        value: _upiApp,
                        items: upiApps.map((app) {
                          return DropdownMenuItem(
                            value: app.name,
                            child: Text(app.name),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _upiApp = value),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Notes field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onSaved: (value) => _notes = value ?? '',
                    ),

                    const SizedBox(height: 20),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitTransaction,
                        child: Text(_isIncome ? 'Add Income' : 'Add Expense'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: _amount,
        categoryId: _category,
        paymentMethod: _paymentMethod,
        upiApp: _upiApp,
        notes: _notes.isEmpty ? null : _notes,
        date: _date,
        isIncome: _isIncome,
      );

      // Add to provider
      ref.read(transactionListProvider.notifier).addTransaction(newTransaction);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${_isIncome ? 'Income' : 'Expense'} added successfully!'),
        ),
      );
    }
  }
}

class _EditTransactionSheet extends ConsumerStatefulWidget {
  final Transaction transaction;
  final List<Category> categories;
  final List<UpiApp> upiApps;

  const _EditTransactionSheet({
    required this.transaction,
    required this.categories,
    required this.upiApps,
  });

  @override
  ConsumerState<_EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<_EditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  late String _category;
  late String _paymentMethod;
  late String? _upiApp;
  late String _notes;
  late DateTime _date;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _amount = widget.transaction.amount;
    _category = widget.transaction.categoryId;
    _paymentMethod = widget.transaction.paymentMethod;
    _upiApp = widget.transaction.upiApp;
    _notes = widget.transaction.notes ?? '';
    _date = widget.transaction.date;
    _isIncome = widget.transaction.isIncome;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Edit Transaction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Income/Expense Toggle
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncome = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: !_isIncome
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          child: Text(
                            'Expense',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isIncome
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncome = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _isIncome
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          child: Text(
                            'Income',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isIncome
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amount field
              TextFormField(
                initialValue: _amount.toString(),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _category.isEmpty ? null : _category,
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(category.icon,
                            size: 20,
                            color: CategoryData.getColor(category.id)),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _category = value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: () => _selectDate(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(_date)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment method
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _paymentMethod.isEmpty ? null : _paymentMethod,
                items: ['Cash', 'Card', 'UPI', 'Bank Transfer']
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                    if (_paymentMethod != 'UPI') {
                      _upiApp = null;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select payment method';
                  }
                  return null;
                },
              ),
              if (_paymentMethod == 'UPI') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'UPI App',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _upiApp,
                  items: widget.upiApps.map((app) {
                    return DropdownMenuItem(
                      value: app.name,
                      child: Text(app.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _upiApp = value),
                ),
              ],
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                initialValue: _notes,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value ?? '',
              ),
              const SizedBox(height: 24),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Update Transaction'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _updateTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        amount: _amount,
        categoryId: _category,
        paymentMethod: _paymentMethod,
        upiApp: _upiApp,
        notes: _notes.isEmpty ? null : _notes,
        date: _date,
        isIncome: _isIncome,
      );

      ref
          .read(transactionListProvider.notifier)
          .updateTransaction(updatedTransaction);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated successfully!')),
      );
    }
  }
}

// AutoPay Management Sheet
class _AutoPayManagementSheet extends ConsumerStatefulWidget {
  const _AutoPayManagementSheet();

  @override
  ConsumerState<_AutoPayManagementSheet> createState() =>
      _AutoPayManagementSheetState();
}

class _AutoPayManagementSheetState
    extends ConsumerState<_AutoPayManagementSheet> {
  @override
  Widget build(BuildContext context) {
    final autoPays = ref.watch(autoPayListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.autorenew,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AutoPay',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'Manage recurring payments',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showAddAutoPaySheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // AutoPay list
          Expanded(
            child: autoPays.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.autorenew_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No AutoPay set up yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add recurring payments for easy tracking',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: autoPays.length,
                    itemBuilder: (context, index) {
                      final autoPay = autoPays[index];
                      final isExpired = autoPay.isExpired;
                      final daysRemaining = autoPay.daysRemaining;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isExpired
                                ? Colors.red.withValues(alpha: 0.3)
                                : Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _showEditAutoPaySheet(context, autoPay),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isExpired
                                            ? Colors.red.shade50
                                            : Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.autorenew,
                                        color: isExpired
                                            ? Colors.red.shade700
                                            : Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            autoPay.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.account_balance_wallet,
                                                size: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                autoPay.upiApp,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\u20b9${autoPay.amount.toStringAsFixed(0)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isExpired
                                                ? Colors.red.shade100
                                                : daysRemaining <= 7
                                                    ? Colors.orange.shade100
                                                    : Colors.green.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isExpired
                                                ? 'Expired'
                                                : '$daysRemaining days left',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: isExpired
                                                      ? Colors.red.shade700
                                                      : daysRemaining <= 7
                                                          ? Colors
                                                              .orange.shade700
                                                          : Colors
                                                              .green.shade700,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Valid: ${DateFormat('dd MMM yyyy').format(autoPay.startDate)} - ${DateFormat('dd MMM yyyy').format(autoPay.validUntil)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                if (autoPay.notes?.isNotEmpty == true) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.note,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          autoPay.notes!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontStyle: FontStyle.italic,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddAutoPaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const _AddAutoPaySheet(),
      ),
    );
  }

  void _showEditAutoPaySheet(BuildContext context, AutoPay autoPay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _EditAutoPaySheet(autoPay: autoPay),
      ),
    );
  }
}

// Add AutoPay Sheet
class _AddAutoPaySheet extends ConsumerStatefulWidget {
  const _AddAutoPaySheet();

  @override
  ConsumerState<_AddAutoPaySheet> createState() => _AddAutoPaySheetState();
}

class _AddAutoPaySheetState extends ConsumerState<_AddAutoPaySheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0;
  String _categoryId = '';
  String _upiApp = '';
  DateTime _startDate = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  String _notes = '';

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider);
    final upiApps = ref.watch(upiAppListProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add AutoPay',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),

              // Title field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Netflix Subscription',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value ?? '',
              ),
              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\u20b9',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                value: _categoryId.isEmpty ? null : _categoryId,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _categoryId = value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // UPI App dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'UPI App',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                value: _upiApp.isEmpty ? null : _upiApp,
                items: upiApps.map((app) {
                  return DropdownMenuItem(
                    value: app.name,
                    child: Text(app.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _upiApp = value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a UPI app';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(_startDate),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Valid until date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _validUntil,
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) {
                    setState(() => _validUntil = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valid Until',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(_validUntil),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
                onSaved: (value) => _notes = value ?? '',
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitAutoPay,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add AutoPay'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAutoPay() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final newAutoPay = AutoPay(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title,
        amount: _amount,
        categoryId: _categoryId,
        upiApp: _upiApp,
        startDate: _startDate,
        validUntil: _validUntil,
        notes: _notes.isEmpty ? null : _notes,
      );

      ref.read(autoPayListProvider.notifier).addAutoPay(newAutoPay);

      Navigator.of(context).pop();
      Navigator.of(context).pop(); // Close the management sheet too
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AutoPay added successfully!')),
      );
    }
  }
}

// Edit AutoPay Sheet
class _EditAutoPaySheet extends ConsumerStatefulWidget {
  final AutoPay autoPay;

  const _EditAutoPaySheet({required this.autoPay});

  @override
  ConsumerState<_EditAutoPaySheet> createState() => _EditAutoPaySheetState();
}

class _EditAutoPaySheetState extends ConsumerState<_EditAutoPaySheet> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late String _categoryId;
  late String _upiApp;
  late DateTime _startDate;
  late DateTime _validUntil;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _title = widget.autoPay.title;
    _amount = widget.autoPay.amount;
    _categoryId = widget.autoPay.categoryId;
    _upiApp = widget.autoPay.upiApp;
    _startDate = widget.autoPay.startDate;
    _validUntil = widget.autoPay.validUntil;
    _notes = widget.autoPay.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider);
    final upiApps = ref.watch(upiAppListProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit AutoPay',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: _deleteAutoPay,
                    icon: const Icon(Icons.delete),
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title field
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value ?? '',
              ),
              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                initialValue: _amount.toString(),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\u20b9',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                value: _categoryId,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _categoryId = value!),
              ),
              const SizedBox(height: 16),

              // UPI App dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'UPI App',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                value: _upiApp,
                items: upiApps.map((app) {
                  return DropdownMenuItem(
                    value: app.name,
                    child: Text(app.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _upiApp = value!),
              ),
              const SizedBox(height: 16),

              // Start date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(_startDate),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Valid until date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _validUntil,
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) {
                    setState(() => _validUntil = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valid Until',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(_validUntil),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                initialValue: _notes,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
                onSaved: (value) => _notes = value ?? '',
              ),
              const SizedBox(height: 24),

              // Update button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _updateAutoPay,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Update AutoPay'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _updateAutoPay() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final updatedAutoPay = widget.autoPay.copyWith(
        title: _title,
        amount: _amount,
        categoryId: _categoryId,
        upiApp: _upiApp,
        startDate: _startDate,
        validUntil: _validUntil,
        notes: _notes.isEmpty ? null : _notes,
      );

      ref.read(autoPayListProvider.notifier).updateAutoPay(updatedAutoPay);

      Navigator.of(context).pop();
      Navigator.of(context).pop(); // Close the management sheet too
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AutoPay updated successfully!')),
      );
    }
  }

  void _deleteAutoPay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete AutoPay'),
        content:
            Text('Are you sure you want to delete "${widget.autoPay.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(autoPayListProvider.notifier)
                  .removeAutoPay(widget.autoPay.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close edit sheet
              Navigator.of(context).pop(); // Close management sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AutoPay deleted successfully!')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
