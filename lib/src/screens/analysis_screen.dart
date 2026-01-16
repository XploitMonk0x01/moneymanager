import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneymanager/src/models/models.dart';
import 'package:moneymanager/src/providers/providers.dart';
import 'package:moneymanager/src/widgets/widgets.dart';
import 'package:moneymanager/src/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:moneymanager/src/data/category_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showMonthlyAnalysis = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  void _changeMonth(bool isNext) {
    setState(() {
      if (isNext) {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      }
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Analysis'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showMonthlyAnalysis = !_showMonthlyAnalysis;
              });
              _animationController.reset();
              _animationController.forward();
            },
            icon:
                Icon(_showMonthlyAnalysis ? Icons.pie_chart : Icons.bar_chart),
            tooltip: _showMonthlyAnalysis
                ? 'Show Category Chart'
                : 'Show Monthly Chart',
          ),
        ],
      ),
      drawer: AppDrawer(
        onDeleteReset: () => _showDeleteResetDialog(context),
        onFeedback: () => _showFeedbackDialog(context),
        onCloudStorage: () => _showCloudStorageDialog(context),
        onAbout: () => _showAboutDialog(context),
      ),
      body: transactionsAsync.when(
        data: (transactions) => _buildAnalysisContent(transactions),
        loading: () => const Column(
          children: [
            SummaryCardRowSkeleton(),
            SizedBox(height: 16),
            ChartSkeleton(height: 250),
          ],
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(List<Transaction> transactions) {
    final filteredTransactions = transactions
        .where((t) =>
            t.date.year == _selectedDate.year &&
            t.date.month == _selectedDate.month &&
            !t.isIncome)
        .toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // Month Navigation Header
          SliverToBoxAdapter(
            child: _buildMonthNavigation(),
          ),

          // Summary Cards
          SliverToBoxAdapter(
            child: _buildSummaryCards(transactions),
          ),

          // Chart Section
          SliverToBoxAdapter(
            child: _showMonthlyAnalysis
                ? _buildMonthlyChart(transactions)
                : _buildCategoryChart(filteredTransactions),
          ),

          // Category Breakdown
          if (!_showMonthlyAnalysis)
            SliverToBoxAdapter(
              child: _buildCategoryBreakdown(filteredTransactions),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(false),
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Column(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                _showMonthlyAnalysis ? 'Monthly Overview' : 'Category Analysis',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _changeMonth(true),
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<Transaction> transactions) {
    final monthTransactions = transactions
        .where((t) =>
            t.date.year == _selectedDate.year &&
            t.date.month == _selectedDate.month)
        .toList();

    final income = monthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expenses = monthTransactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    return SummaryCardRow(
      income: income,
      expenses: expenses,
    );
  }

  Widget _buildCategoryChart(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    final categoryData = <String, double>{};
    for (final transaction in transactions) {
      categoryData[transaction.categoryId] =
          (categoryData[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final totalSpent =
        categoryData.values.fold(0.0, (sum, amount) => sum + amount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent) {
                          HapticFeedback.lightImpact();
                        }
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 80,
                    sections: categoryData.entries.map((entry) {
                      final percentage = (entry.value / totalSpent * 100);
                      final color = CategoryData.getColor(entry.key);

                      return PieChartSectionData(
                        color: color,
                        value: entry.value,
                        title: percentage > 5
                            ? '${percentage.toStringAsFixed(1)}%'
                            : '',
                        radius: 70,
                        titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Center total display
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pie_chart_rounded,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        Text(
                          '₹${totalSpent.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(List<Transaction> transactions) {
    // Get last 6 months data
    final now = DateTime.now();
    final monthlyData = <String, double>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthKey = DateFormat('MMM').format(month);
      final monthExpenses = transactions
          .where((t) =>
              t.date.year == month.year &&
              t.date.month == month.month &&
              !t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);

      monthlyData[monthKey] = monthExpenses;
    }

    final maxY = monthlyData.values.isNotEmpty
        ? monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.3
        : 1000.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Expenses Trend',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Last 6 months overview',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.9),
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.all(12),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final monthKey =
                          monthlyData.keys.toList()[group.x.toInt()];
                      return BarTooltipItem(
                        '$monthKey\n',
                        TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '₹${rod.toY.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    if (event is FlTapUpEvent) {
                      HapticFeedback.lightImpact();
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final months = monthlyData.keys.toList();
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Builder(builder: (context) {
                              final months = monthlyData.keys.toList();
                              final idx = value.toInt();
                              final last = months.length - 1;
                              final isCurrent = idx == last;
                              final isPrev = idx == last - 1;

                              TextStyle base = Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600) ??
                                  const TextStyle(fontWeight: FontWeight.w600);

                              if (isCurrent) {
                                base = base.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold);
                              } else if (isPrev) {
                                base = base.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600);
                              } else {
                                base = base.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600);
                              }

                              return Text(
                                months[idx],
                                style: base,
                              );
                            }),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value == 0) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '₹${(value / 1000).toStringAsFixed(0)}k',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                barGroups:
                    monthlyData.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final amount = entry.value.value;
                  final isCurrentMonth = index == monthlyData.length - 1;
                  final isPrevMonth = index == monthlyData.length - 2;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: amount,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                          bottom: Radius.circular(2),
                        ),
                        gradient: LinearGradient(
                          colors: isCurrentMonth
                              ? [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.7),
                                ]
                              : isPrevMonth
                                  ? [
                                      Theme.of(context).colorScheme.secondary,
                                      Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.9),
                                    ]
                                  : [
                                      Theme.of(context).colorScheme.secondary,
                                      Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.6),
                                    ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                'Previous Months',
                Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 20),
              _buildLegendItem(
                'Current Month',
                Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(List<Transaction> transactions) {
    if (transactions.isEmpty) return const SizedBox();

    // Get categories from provider for custom category support
    final categories = ref.watch(categoryListProvider);

    final categoryData = <String, double>{};
    for (final transaction in transactions) {
      categoryData[transaction.categoryId] =
          (categoryData[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...sortedEntries.map((entry) {
            final percentage = (entry.value /
                categoryData.values.fold(0.0, (sum, val) => sum + val) *
                100);

            // Find the category
            final category = categories.firstWhere(
              (c) => c.id == entry.key,
              orElse: () => Category(
                id: entry.key,
                name: CategoryData.getName(entry.key),
                icon: CategoryData.getIcon(entry.key),
              ),
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: CategoryData.getColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    category.icon,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses this month',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some transactions to see your analysis',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
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
              onPressed: () async {
                if (feedbackController.text.trim().isNotEmpty) {
                  Navigator.pop(context);

                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'support@moneymanager.com',
                    query: _encodeQueryParameters(<String, String>{
                      'subject': 'Money Manager Feedback',
                      'body': feedbackController.text,
                    }),
                  );

                  try {
                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(emailLaunchUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not launch email client')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
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

  Future<void> _performCloudBackup(BuildContext context) async {
    // Firestore syncs automatically
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data is automatically synced to cloud via Firestore.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _performCloudRestore(BuildContext context) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return;

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Restoring data...'),
              ],
            ),
          ),
        );
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      // Parse Transactions
      if (content.contains('=== TRANSACTIONS ===')) {
        final txSection = content
            .split('=== TRANSACTIONS ===')[1]
            .split('=== BORROW/LEND RECORDS ===')[0]
            .trim();

        final txRows = const CsvToListConverter().convert(txSection, eol: '\n');

        if (txRows.isNotEmpty) {
          for (var i = 1; i < txRows.length; i++) {
            final row = txRows[i];
            if (row.length < 7) continue;

            final dateStr = row[0].toString();
            final type = row[1].toString();
            final amountStr =
                row[2].toString().replaceAll('₹', '').replaceAll(',', '');
            final category = row[3].toString();
            final paymentMethod = row[4].toString();
            final upiApp = row[5].toString();
            final notes = row[6].toString();

            final amount = double.tryParse(amountStr) ?? 0.0;
            final date = DateTime.tryParse(dateStr) ?? DateTime.now();
            final isIncome = type == 'Income';

            final tx = Transaction(
              id: const Uuid().v4(),
              amount: amount,
              categoryId: category,
              paymentMethod: paymentMethod,
              upiApp: upiApp.isEmpty ? null : upiApp,
              date: date,
              notes: notes,
              isIncome: isIncome,
            );

            await ref.read(firestoreServiceProvider).addTransaction(tx);
          }
        }
      }

      // Parse Records
      if (content.contains('=== BORROW/LEND RECORDS ===')) {
        final recordSection = content
            .split('=== BORROW/LEND RECORDS ===')[1]
            .split('=== SUMMARY ===')[0]
            .trim();

        final recordRows =
            const CsvToListConverter().convert(recordSection, eol: '\n');

        if (recordRows.isNotEmpty) {
          for (var i = 1; i < recordRows.length; i++) {
            final row = recordRows[i];
            if (row.length < 5) continue;

            final dateStr = row[0].toString();
            final type = row[1].toString();
            final person = row[2].toString();
            final amountStr =
                row[3].toString().replaceAll('₹', '').replaceAll(',', '');
            final notes = row[4].toString();

            final amount = double.tryParse(amountStr) ?? 0.0;
            final date = DateTime.tryParse(dateStr) ?? DateTime.now();
            final isBorrowed = type == 'Borrowed from';

            final record = Record(
              id: const Uuid().v4(),
              person: person,
              amount: amount,
              isBorrowed: isBorrowed,
              date: date,
              notes: notes,
            );

            await ref.read(firestoreServiceProvider).addRecord(record);
          }
        }
      }

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performLocalBackup(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating CSV report...'),
            ],
          ),
        ),
      );

      // Get data from providers
      final transactions = await ref.read(transactionStreamProvider.future);
      final records = await ref.read(recordListProvider.future);

      // Generate CSV content
      final csvContent = _generateCsvContent(transactions, records);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'money_manager_backup_$timestamp.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV content to file
      await file.writeAsString(csvContent);

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Money Manager Data Export',
        subject: 'Your Money Manager backup data',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateCsvContent(
      List<Transaction> transactions, List<Record> records) {
    final buffer = StringBuffer();

    // Add header with timestamp
    buffer.writeln('Money Manager Data Export');
    buffer.writeln(
        'Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('');

    // Transactions section
    buffer.writeln('=== TRANSACTIONS ===');
    buffer.writeln('Date,Type,Amount,Category,Payment Method,UPI App,Notes');

    for (final transaction in transactions) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(transaction.date);
      final type = transaction.isIncome ? 'Income' : 'Expense';
      final amount = transaction.amount.toStringAsFixed(2);
      final category = transaction.categoryId;
      final paymentMethod = transaction.paymentMethod;
      final upiApp = transaction.upiApp ?? '';
      final notes = (transaction.notes ?? '')
          .replaceAll(',', ';'); // Replace commas to avoid CSV issues

      buffer.writeln(
          '$formattedDate,$type,₹$amount,$category,$paymentMethod,$upiApp,"$notes"');
    }

    buffer.writeln('');

    // Records section
    buffer.writeln('=== BORROW/LEND RECORDS ===');
    buffer.writeln('Date,Type,Person,Amount,Notes');

    for (final record in records) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(record.date);
      final type = record.isBorrowed ? 'Borrowed from' : 'Given to';
      final person = record.person;
      final amount = record.amount.toStringAsFixed(2);
      final notes = record.notes
          .replaceAll(',', ';'); // Replace commas to avoid CSV issues

      buffer.writeln('$formattedDate,$type,$person,₹$amount,"$notes"');
    }

    buffer.writeln('');

    // Summary section
    buffer.writeln('=== SUMMARY ===');
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalBorrowed = records
        .where((r) => r.isBorrowed)
        .fold(0.0, (sum, r) => sum + r.amount);
    final totalLent = records
        .where((r) => !r.isBorrowed)
        .fold(0.0, (sum, r) => sum + r.amount);

    buffer.writeln('Total Income,₹${totalIncome.toStringAsFixed(2)}');
    buffer.writeln('Total Expense,₹${totalExpense.toStringAsFixed(2)}');
    buffer.writeln(
        'Net Balance,₹${(totalIncome - totalExpense).toStringAsFixed(2)}');
    buffer.writeln('Total Borrowed,₹${totalBorrowed.toStringAsFixed(2)}');
    buffer.writeln('Total Lent,₹${totalLent.toStringAsFixed(2)}');
    buffer.writeln(
        'Borrow/Lend Balance,₹${(totalLent - totalBorrowed).toStringAsFixed(2)}');

    return buffer.toString();
  }
}
