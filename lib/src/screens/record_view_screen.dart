import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class RecordViewScreen extends ConsumerStatefulWidget {
  final Record record;

  const RecordViewScreen({super.key, required this.record});

  @override
  ConsumerState<RecordViewScreen> createState() => _RecordViewScreenState();
}

class _RecordViewScreenState extends ConsumerState<RecordViewScreen> {
  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(isOfflineModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Details'),
        centerTitle: true,
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _shareRecord(),
          ),
          // Edit button (disabled in offline mode)
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: isOffline ? null : () => _editRecord(),
          ),
          // Delete button (disabled in offline mode)
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: isOffline ? null : () => _deleteRecord(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline mode indicator
            if (isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline Mode - Read Only',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Record Type Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.record.isBorrowed
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.record.isBorrowed
                            ? Icons.south_west
                            : Icons.north_east,
                        color: widget.record.isBorrowed
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.record.isBorrowed ? 'Borrowed' : 'Lent',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.record.isBorrowed
                                ? 'You borrowed from'
                                : 'You lent to',
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Amount Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${widget.record.amount.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Person Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Person',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.record.person,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Date',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy')
                          .format(widget.record.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notes',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.record.notes.isEmpty
                          ? 'No notes added'
                          : widget.record.notes,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: widget.record.notes.isEmpty
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons (visible only when online)
            if (!isOffline) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _editRecord,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Record'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _shareRecord,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Record'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleteRecord,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Record'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _shareRecord() {
    final String recordType =
        widget.record.isBorrowed ? 'Borrowed from' : 'Lent to';
    final String message = '''
💰 MoneyManager Record

$recordType: ${widget.record.person}
Amount: ₹${widget.record.amount.toStringAsFixed(2)}
Date: ${DateFormat('MMMM dd, yyyy').format(widget.record.date)}
Notes: ${widget.record.notes.isEmpty ? 'No notes' : widget.record.notes}

Shared from MoneyManager App
''';

    Share.share(
      message,
      subject: 'MoneyManager - Record Details',
    );
  }

  Future<void> _editRecord() async {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        builder: (context) => _EditRecordSheet(
          record: widget.record,
          onUpdated: () {
            if (mounted) {
              Navigator.pop(context); // Close edit sheet
              Navigator.pop(context); // Return to list
            }
          },
        ),
      );
    }
  }

  Future<void> _deleteRecord() async {
    // Show confirmation dialog directly without authentication
    if (mounted) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Record'),
          content: Text(
            'Are you sure you want to delete this record with ${widget.record.person}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        try {
          await ref
              .read(recordListNotifierProvider.notifier)
              .deleteRecord(widget.record.id);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Record deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(); // Return to previous screen
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete record: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
}

// Edit Record Sheet Widget
class _EditRecordSheet extends ConsumerStatefulWidget {
  final Record record;
  final VoidCallback onUpdated;

  const _EditRecordSheet({
    required this.record,
    required this.onUpdated,
  });

  @override
  ConsumerState<_EditRecordSheet> createState() => _EditRecordSheetState();
}

class _EditRecordSheetState extends ConsumerState<_EditRecordSheet> {
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
        top: 24,
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Update'),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _saveRecord,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveRecord() async {
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

      try {
        await ref
            .read(recordListNotifierProvider.notifier)
            .updateRecord(updatedRecord);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onUpdated();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
