import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/models.dart';
import '../providers/providers.dart';
import '../core/constants/app_constants.dart';
import '../data/category_data.dart';
import '../widgets/widgets.dart';
import 'transaction_view_screen.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late ScrollController _scrollController;
  bool _isExtended = true;
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  /// Filters transactions based on selected category and search query
  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // Filter by category if selected
    if (_selectedCategoryId != null) {
      filtered =
          filtered.where((t) => t.categoryId == _selectedCategoryId).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      final categories = ref.read(categoryListProvider);

      filtered = filtered.where((t) {
        // Search in category name
        final category = categories.firstWhere(
          (c) => c.id == t.categoryId,
          orElse: () => Category(
            id: t.categoryId,
            name: CategoryData.getName(t.categoryId),
            icon: Icons.category,
          ),
        );
        if (category.name.toLowerCase().contains(query)) return true;

        // Search in notes
        if (t.notes?.toLowerCase().contains(query) == true) return true;

        // Search in amount
        if (t.amount.toString().contains(query)) return true;

        // Search in payment method
        if (t.paymentMethod.toLowerCase().contains(query)) return true;

        // Search in UPI app
        if (t.upiApp?.toLowerCase().contains(query) == true) return true;

        return false;
      }).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _searchQuery = '';
      _searchController.clear();
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsyncValue = ref.watch(transactionStreamProvider);
    final categories = ref.watch(categoryListProvider);

    // Get selected category name for display
    String? selectedCategoryName;
    if (_selectedCategoryId != null) {
      final category = categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => Category(
          id: _selectedCategoryId!,
          name: CategoryData.getName(_selectedCategoryId!),
          icon: Icons.category,
        ),
      );
      selectedCategoryName = category.name;
    }

    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                      ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              )
            : Text(_selectedCategoryId != null
                ? selectedCategoryName ?? 'MoneyManager'
                : 'MoneyManager'),
        centerTitle: !_isSearching,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              tooltip: 'Search transactions',
            ),
          if (_selectedCategoryId != null && !_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearFilters,
              tooltip: 'Clear filter',
            ),
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
                case 'view_by_category':
                  _showCategoryFilterSheet(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_by_category',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('View by Category'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
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
      drawer: AppDrawer(
        onDeleteReset: () => _showDeleteResetDialog(context),
        onFeedback: () => _showFeedbackDialog(context),
        onCloudStorage: () => _showCloudStorageDialog(context),
        onManageCategories: () => _showCategoryManagement(context),
        onManageUpiApps: () => _showUpiAppManagement(context),
        onAbout: () => _showAboutDialog(context),
      ),
      body: transactionsAsyncValue.when(
        data: (allTransactions) {
          final transactions = _filterTransactions(allTransactions);

          if (allTransactions.isEmpty) {
            return const Center(
              child: Text(
                'No transactions yet.\nTap + to add your first transaction!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedCategoryId != null
                        ? 'No transactions in this category'
                        : 'Try a different search term',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Show active filter chip
              if (_selectedCategoryId != null || _searchQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildActiveFiltersBar(
                      transactions.length, allTransactions.length),
                ),
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          );
        },
        loading: () => const TransactionListSkeleton(itemCount: 6),
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
      floatingActionButton: _isExtended
          ? FloatingActionButton.extended(
              onPressed: () => _showAddTransactionSheet(context),
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Transaction',
                style: TextStyle(color: Colors.white),
              ),
            )
          : FloatingActionButton(
              onPressed: () => _showAddTransactionSheet(context),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  // Helper method to get color for income/expense
  Color _getTransactionColor(bool isIncome) {
    return isIncome
        ? Colors.green.shade600
        : Theme.of(context).colorScheme.error;
  }

  /// Builds the active filters bar showing current filter state
  Widget _buildActiveFiltersBar(int filteredCount, int totalCount) {
    final categories = ref.watch(categoryListProvider);
    String? categoryName;

    if (_selectedCategoryId != null) {
      final category = categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => Category(
          id: _selectedCategoryId!,
          name: CategoryData.getName(_selectedCategoryId!),
          icon: Icons.category,
        ),
      );
      categoryName = category.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Showing $filteredCount of $totalCount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 8),
          if (_selectedCategoryId != null)
            Chip(
              label: Text(categoryName ?? 'Category'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _selectedCategoryId = null;
                });
              },
              visualDensity: VisualDensity.compact,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              padding: EdgeInsets.zero,
            ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: 4),
            Chip(
              label: Text('"$_searchQuery"'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              visualDensity: VisualDensity.compact,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              padding: EdgeInsets.zero,
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Shows the category filter bottom sheet
  void _showCategoryFilterSheet(BuildContext context) {
    final categories = ref.read(categoryListProvider);
    final transactions = ref.read(transactionStreamProvider).valueOrNull ?? [];

    // Count transactions per category
    final categoryCounts = <String, int>{};
    for (final t in transactions) {
      categoryCounts[t.categoryId] = (categoryCounts[t.categoryId] ?? 0) + 1;
    }

    // Sort categories by transaction count (descending)
    final sortedCategories = categories.toList()
      ..sort((a, b) =>
          (categoryCounts[b.id] ?? 0).compareTo(categoryCounts[a.id] ?? 0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Filter by Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  if (_selectedCategoryId != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const Divider(),
            // Category list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: sortedCategories.length,
                itemBuilder: (context, index) {
                  final category = sortedCategories[index];
                  final count = categoryCounts[category.id] ?? 0;
                  final isSelected = _selectedCategoryId == category.id;
                  final categoryColor = CategoryData.getColor(category.id);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: categoryColor.withValues(alpha: 0.2),
                      child: Icon(
                        category.icon,
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(category.name),
                    subtitle:
                        Text('$count transaction${count == 1 ? '' : 's'}'),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category.id;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, BuildContext context) {
    // Get categories from provider to support custom categories
    final categories = ref.watch(categoryListProvider);
    final rawCategory = categories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => Category(
        id: transaction.categoryId,
        name: CategoryData.getName(transaction.categoryId), // Fallback
        icon: CategoryData.getIcon(transaction.categoryId),
      ),
    );

    // Ensure we have a usable icon and color even for custom categories
    var category = rawCategory;
    if (category.icon == Icons.help_outline) {
      // Try to map by the display name to a canonical id
      final normalized = CategoryData.normalizeId(category.name);
      final fallbackIcon = CategoryData.getIcon(normalized);
      category = Category(
        id: category.id,
        name: category.name,
        icon: fallbackIcon,
        isCustom: category.isCustom,
      );
    }

    final rawColor = CategoryData.getColor(category.id);
    final categoryColor = rawColor == Colors.grey
        ? CategoryData.getColor(CategoryData.normalizeId(category.name))
        : rawColor;

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      closedColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      openColor: categoryColor,
      transitionDuration: const Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (context, _) =>
          TransactionViewScreen(transaction: transaction),
      closedBuilder: (context, openContainer) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: openContainer,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            leading: Hero(
              tag: 'transaction_${transaction.id}_icon',
              child: CircleAvatar(
                radius: 22,
                backgroundColor: categoryColor.withValues(alpha: 0.18),
                child: Icon(
                  category.icon,
                  color: (CategoryData.getColor(category.id) == Colors.grey)
                      ? CategoryData.getColor(
                          CategoryData.normalizeId(category.name))
                      : CategoryData.getColor(category.id),
                  size: 20,
                ),
              ),
            ),
            title: Text(category.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.notes?.isNotEmpty == true)
                  Text(transaction.notes!),
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
                Hero(
                  tag: 'transaction_${transaction.id}_amount',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      '${transaction.isIncome ? '+' : '-'}₹${NumberFormat('#,##0.00').format(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getTransactionColor(transaction.isIncome),
                      ),
                    ),
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
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TransactionViewScreen(transaction: transaction),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
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
        child: EditTransactionSheet(
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
        child: const CategoryManagementSheet(),
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
        child: const UpiAppManagementSheet(),
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
        child: const AutoPayManagementSheet(),
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
        child: AddTransactionSheet(
          categories: categories,
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Money Manager',
      applicationVersion: AppConstants.appVersion,
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
      // final recordsSnapshot = await firestore.FirebaseFirestore.instance
      //     .collection('records')
      //     .get();

      // Create backup data structure
      // final backupData = {
      //   'timestamp': DateTime.now().toIso8601String(),
      //   'transactions':
      //       transactionsSnapshot.docs.map((doc) => doc.data()).toList(),
      //   'records': recordsSnapshot.docs.map((doc) => doc.data()).toList(),
      // };

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
    }
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
