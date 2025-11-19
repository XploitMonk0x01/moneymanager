import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../providers/providers.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(
                      themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.auto_mode,
                    ),
                    title: const Text('Theme'),
                    subtitle: Text(
                      themeMode == ThemeMode.light
                          ? 'Light'
                          : themeMode == ThemeMode.dark
                              ? 'Dark'
                              : 'System',
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeMode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                      onChanged: (newTheme) {
                        if (newTheme != null) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setTheme(newTheme);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    subtitle: const Text('Learn more about Money Manager'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const ListTile(
                    leading: Icon(Icons.update),
                    title: Text('Version'),
                    subtitle: Text(AppConstants.appVersion),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Data Management Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Export Data'),
                    subtitle: const Text('Generate CSV report of your data'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _exportDataToCsv(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore Data'),
                    subtitle: const Text('Restore your data from cloud'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _restoreData(context, ref),
                  ),
                ],
              ),
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

  Future<void> _exportDataToCsv(BuildContext context, WidgetRef ref) async {
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

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
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

        // Normalize newlines and parse
        final txRows = const CsvToListConverter().convert(txSection, eol: '\n');

        if (txRows.isNotEmpty) {
          // Skip header row (index 0)
          for (var i = 1; i < txRows.length; i++) {
            final row = txRows[i];
            // Ensure row has enough columns
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
          // Skip header row (index 0)
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
}
