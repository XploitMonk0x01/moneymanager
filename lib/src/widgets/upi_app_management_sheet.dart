import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';

// ignore_for_file: library_private_types_in_public_api

class UpiAppManagementSheet extends ConsumerStatefulWidget {
  const UpiAppManagementSheet({super.key});

  @override
  ConsumerState<UpiAppManagementSheet> createState() =>
      _UpiAppManagementSheetState();
}

class _UpiAppManagementSheetState extends ConsumerState<UpiAppManagementSheet> {
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
