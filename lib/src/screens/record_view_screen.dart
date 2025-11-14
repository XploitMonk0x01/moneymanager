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
    // Navigate to edit screen directly without authentication
    if (mounted) {
      Navigator.pop(context);
      // TODO: Show edit sheet with widget.record
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
