import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../data/category_data.dart';
import '../providers/providers.dart';
import '../screens/transaction_view_screen.dart';

/// A reusable transaction list tile widget with Hero animations
/// and OpenContainer transitions.
class TransactionListTile extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider);
    final category = _resolveCategory(categories);
    final categoryColor = _resolveCategoryColor(category);

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
      closedBuilder: (context, openContainer) => _buildClosedTile(
        context,
        openContainer,
        category,
        categoryColor,
      ),
    );
  }

  Category _resolveCategory(List<Category> categories) {
    final rawCategory = categories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => Category(
        id: transaction.categoryId,
        name: CategoryData.getName(transaction.categoryId),
        icon: CategoryData.getIcon(transaction.categoryId),
      ),
    );

    // Ensure we have a usable icon even for custom categories
    if (rawCategory.icon == Icons.help_outline) {
      final normalized = CategoryData.normalizeId(rawCategory.name);
      final fallbackIcon = CategoryData.getIcon(normalized);
      return Category(
        id: rawCategory.id,
        name: rawCategory.name,
        icon: fallbackIcon,
        isCustom: rawCategory.isCustom,
      );
    }

    return rawCategory;
  }

  Color _resolveCategoryColor(Category category) {
    final rawColor = CategoryData.getColor(category.id);
    if (rawColor == Colors.grey) {
      return CategoryData.getColor(CategoryData.normalizeId(category.name));
    }
    return rawColor;
  }

  Widget _buildClosedTile(
    BuildContext context,
    VoidCallback openContainer,
    Category category,
    Color categoryColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = transaction.isIncome;
    final transactionColor =
        isIncome ? Colors.green.shade600 : colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: openContainer,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: _buildCategoryAvatar(category, categoryColor),
          title: Text(
            category.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: _buildSubtitle(context),
          trailing: _buildTrailing(context, transactionColor),
        ),
      ),
    );
  }

  Widget _buildCategoryAvatar(Category category, Color categoryColor) {
    return Hero(
      tag: 'transaction_${transaction.id}_icon',
      child: CircleAvatar(
        radius: 22,
        backgroundColor: categoryColor.withValues(alpha: 0.18),
        child: Icon(
          category.icon,
          color: categoryColor,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (transaction.notes?.isNotEmpty == true)
          Text(
            transaction.notes!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        Row(
          children: [
            _buildPaymentMethodChip(context),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData icon;
    String label;

    switch (transaction.paymentMethod.toLowerCase()) {
      case 'upi':
        icon = Icons.account_balance_wallet;
        label = transaction.upiApp ?? 'UPI';
        break;
      case 'cash':
        icon = Icons.payments;
        label = 'Cash';
        break;
      case 'card':
        icon = Icons.credit_card;
        label = 'Card';
        break;
      case 'bank_transfer':
        icon = Icons.account_balance;
        label = 'Bank';
        break;
      default:
        icon = Icons.payment;
        label = transaction.paymentMethod;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, Color transactionColor) {
    return Row(
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
                color: transactionColor,
              ),
            ),
          ),
        ),
        if (onView != null || onEdit != null || onDelete != null)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              switch (value) {
                case 'view':
                  onView?.call();
                  break;
                case 'edit':
                  onEdit?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (onView != null)
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
              if (onEdit != null)
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
              if (onDelete != null)
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
    );
  }
}
