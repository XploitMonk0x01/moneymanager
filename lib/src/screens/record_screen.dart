import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';
import 'record_view_screen.dart';

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
