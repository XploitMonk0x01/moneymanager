import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../providers/providers.dart';
import '../models/models.dart';
import '../core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'record_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  late ScrollController _scrollController;
  bool _isExtended = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && _isExtended) {
      setState(() {
        _isExtended = false;
      });
    } else if (_scrollController.offset <= 100 && !_isExtended) {
      setState(() {
        _isExtended = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsyncValue = ref.watch(recordListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Record'),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: recordsAsyncValue.when(
        data: (records) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Borrow/Give Records',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Text('No records yet.',
                            style: Theme.of(context).textTheme.bodyLarge))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            child: ListTile(
                              leading: Icon(
                                  record.isBorrowed
                                      ? Icons.call_received
                                      : Icons.call_made,
                                  color: record.isBorrowed
                                      ? Colors.red
                                      : Colors.green,
                                  size: 32),
                              title: Text(
                                '${record.isBorrowed ? 'Borrowed from' : 'Given to'} ${record.person}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(DateFormat('dd MMM yyyy')
                                  .format(record.date)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₹${record.amount.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    onSelected: (value) {
                                      if (value == 'view') {
                                        _viewRecord(record);
                                      } else if (value == 'share') {
                                        _shareRecord(record);
                                      } else if (value == 'edit') {
                                        _editRecord(record);
                                      } else if (value == 'delete') {
                                        _deleteRecord(record);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility),
                                            SizedBox(width: 8),
                                            Text('View'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'share',
                                        child: Row(
                                          children: [
                                            Icon(Icons.share),
                                            SizedBox(width: 8),
                                            Text('Share'),
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
                        },
                      ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: _isExtended
            ? FloatingActionButton.extended(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    builder: (context) => _AddRecordSheet(ref: ref),
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Add Record'),
              )
            : FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    builder: (context) => _AddRecordSheet(ref: ref),
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  void _viewRecord(Record record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordViewScreen(record: record),
      ),
    );
  }

  void _shareRecord(Record record) {
    final recordType = record.isBorrowed ? 'borrowed from' : 'given to';
    final formattedDate = DateFormat('dd MMM yyyy').format(record.date);
    final amount = '₹${record.amount.toStringAsFixed(2)}';

    String shareText = '''💰 Money Record

${record.isBorrowed ? '📥' : '📤'} $recordType ${record.person}
💵 Amount: $amount
📅 Date: $formattedDate''';

    if (record.notes.isNotEmpty) {
      shareText += '\n📝 Notes: ${record.notes}';
    }

    shareText += '\n\n📱 Shared via MoneyManager App';

    Share.share(
      shareText,
      subject: 'Money Record - $recordType ${record.person}',
    );
  }

  Future<void> _editRecord(Record record) async {
    // Show edit sheet directly without authentication
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        builder: (context) => _EditRecordSheet(ref: ref, record: record),
      );
    }
  }

  Future<void> _deleteRecord(Record record) async {
    // Show confirmation dialog directly without authentication
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Record'),
          content: Text(
              'Are you sure you want to delete this record with ${record.person}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(recordListNotifierProvider.notifier)
                    .deleteRecord(record.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Record deleted successfully')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
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

  void _performCloudBackup(BuildContext context) async {
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

  void _performCloudRestore(BuildContext context) async {
    // Reuse restore logic from SettingsScreen (Local Restore from CSV)
    // Or if "Restore from Cloud" means something else, clarify.
    // Assuming it means "Import from CSV" as per SettingsScreen "Restore Data"

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

class _EditRecordSheet extends StatefulWidget {
  final WidgetRef ref;
  final Record record;
  const _EditRecordSheet({required this.ref, required this.record});

  @override
  State<_EditRecordSheet> createState() => _EditRecordSheetState();
}

class _EditRecordSheetState extends State<_EditRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _person;
  late double _amount;
  late bool _isBorrowed;
  late DateTime _date;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _person = widget.record.person;
    _amount = widget.record.amount;
    _isBorrowed = widget.record.isBorrowed;
    _date = widget.record.date;
    _notes = widget.record.notes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Record',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _person,
                decoration: const InputDecoration(labelText: 'Person'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter name' : null,
                onSaved: (val) => _person = val ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _amount.toString(),
                decoration: const InputDecoration(
                    labelText: 'Amount (INR)', prefixText: '₹'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null
                    ? 'Enter valid amount'
                    : null,
                onSaved: (val) => _amount = double.tryParse(val ?? '') ?? 0,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(_isBorrowed ? 'Borrowed' : 'Given'),
                value: _isBorrowed,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  setState(() => _isBorrowed = val);
                },
                secondary:
                    Icon(_isBorrowed ? Icons.call_received : Icons.call_made),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Date: ${DateFormat('dd MMM yyyy').format(_date)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (val) => _notes = val ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Update'),
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final updatedRecord = Record(
                      id: widget.record.id,
                      person: _person,
                      amount: _amount,
                      isBorrowed: _isBorrowed,
                      date: _date,
                      notes: _notes,
                    );
                    widget.ref
                        .read(recordListNotifierProvider.notifier)
                        .updateRecord(updatedRecord);
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddRecordSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddRecordSheet({required this.ref});

  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  String _person = '';
  double _amount = 0;
  bool _isBorrowed = false;
  DateTime _date = DateTime.now();
  String _notes = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Record', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Person'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter name' : null,
                onSaved: (val) => _person = val ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Amount (INR)', prefixText: '₹'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null
                    ? 'Enter valid amount'
                    : null,
                onSaved: (val) => _amount = double.tryParse(val ?? '') ?? 0,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(_isBorrowed ? 'Borrowed' : 'Given'),
                value: _isBorrowed,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  setState(() => _isBorrowed = val);
                },
                secondary:
                    Icon(_isBorrowed ? Icons.call_received : Icons.call_made),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Date: ${DateFormat('dd MMM yyyy').format(_date)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (val) => _notes = val ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final record = Record(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      person: _person,
                      amount: _amount,
                      isBorrowed: _isBorrowed,
                      date: _date,
                      notes: _notes,
                    );
                    try {
                      await widget.ref
                          .read(recordListNotifierProvider.notifier)
                          .addRecord(record);
                      if (mounted) Navigator.of(context).pop();
                    } catch (error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
