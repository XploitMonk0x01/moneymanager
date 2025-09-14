import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

// Theme provider
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setTheme(ThemeMode themeMode) {
    state = themeMode;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final transactionStreamProvider =
    StreamProvider.autoDispose<List<Transaction>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTransactions();
});

// Transaction providers
final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, List<Transaction>>(
  (ref) => TransactionListNotifier(ref.read(firestoreServiceProvider)),
);

class TransactionListNotifier extends StateNotifier<List<Transaction>> {
  final FirestoreService _firestoreService;

  TransactionListNotifier(this._firestoreService) : super([]) {
    _loadTransactions();
  }

  void _loadTransactions() {
    _firestoreService.getTransactions().listen(
      (transactions) {
        state = transactions;
      },
      onError: (error) {
        // Error loading transactions: $error
      },
    );
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _firestoreService.addTransaction(transaction);
      // State will be updated automatically via the stream
    } catch (e) {
      // Handle error - could show a snackbar
      // Error adding transaction: $e
    }
  }

  Future<void> removeTransaction(String id) async {
    try {
      await _firestoreService.deleteTransaction(id);
      // State will be updated automatically via the stream
    } catch (e) {
      // Error removing transaction: $e
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _firestoreService.updateTransaction(transaction);
      // State will be updated automatically via the stream
    } catch (e) {
      // Error updating transaction: $e
    }
  }
}

final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, List<Category>>(
  (ref) => CategoryListNotifier(ref.read(firestoreServiceProvider)),
);

class CategoryListNotifier extends StateNotifier<List<Category>> {
  CategoryListNotifier(this._firestoreService)
      : super(_getDefaultCategories()) {
    _loadCategories();
  }

  final FirestoreService _firestoreService;
  StreamSubscription<List<Category>>? _subscription;

  static List<Category> _getDefaultCategories() {
    return [
      Category(id: 'food', name: 'Food', icon: Icons.fastfood),
      Category(id: 'health', name: 'Health', icon: Icons.health_and_safety),
      Category(
          id: 'electronics', name: 'Electronics', icon: Icons.devices_other),
      Category(id: 'travel', name: 'Travel', icon: Icons.flight),
      Category(id: 'bills', name: 'Bills', icon: Icons.receipt_long),
      Category(id: 'recharge', name: 'Recharge', icon: Icons.phone_android),
      Category(id: 'social', name: 'Social', icon: Icons.people),
      Category(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag),
      Category(id: 'salary', name: 'Salary', icon: Icons.work),
      Category(id: 'investment', name: 'Investment', icon: Icons.trending_up),
    ];
  }

  void _loadCategories() {
    _subscription = _firestoreService.getCategories().listen(
      (categories) {
        if (categories.isNotEmpty) {
          state = categories;
        }
        // If empty, keep the default categories
      },
      onError: (error) {
        // Error loading categories: $error
        // Keep default categories on error
      },
    );
  }

  Future<void> addCategory(Category category) async {
    try {
      await _firestoreService.addCategory(category);
    } catch (e) {
      // Error adding category: $e
      rethrow;
    }
  }

  Future<void> removeCategory(String id) async {
    try {
      await _firestoreService.deleteCategory(id);
    } catch (e) {
      // Error removing category: $e
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Payment Method providers
final paymentMethodListProvider =
    StateNotifierProvider<PaymentMethodListNotifier, List<PaymentMethod>>(
  (ref) => PaymentMethodListNotifier(ref.read(firestoreServiceProvider)),
);

class PaymentMethodListNotifier extends StateNotifier<List<PaymentMethod>> {
  PaymentMethodListNotifier(this._firestoreService)
      : super(_getDefaultPaymentMethods()) {
    _loadPaymentMethods();
  }

  final FirestoreService _firestoreService;
  StreamSubscription<List<PaymentMethod>>? _subscription;

  static List<PaymentMethod> _getDefaultPaymentMethods() {
    return [
      PaymentMethod(id: 'cash', name: 'Cash', icon: Icons.money),
      PaymentMethod(id: 'upi', name: 'UPI', icon: Icons.account_balance_wallet),
      PaymentMethod(
          id: 'debit_card', name: 'Debit Card', icon: Icons.credit_card),
      PaymentMethod(
          id: 'credit_card',
          name: 'Credit Card',
          icon: Icons.credit_card_outlined),
      PaymentMethod(
          id: 'bank_transfer',
          name: 'Bank Transfer',
          icon: Icons.account_balance),
      PaymentMethod(id: 'cheque', name: 'Cheque', icon: Icons.receipt_long),
    ];
  }

  void _loadPaymentMethods() {
    _subscription = _firestoreService.getPaymentMethods().listen(
      (paymentMethods) {
        if (paymentMethods.isNotEmpty) {
          state = paymentMethods;
        }
        // If empty, keep the default payment methods
      },
      onError: (error) {
        // Error loading payment methods: $error
        // Keep default payment methods on error
      },
    );
  }

  Future<void> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      await _firestoreService.addPaymentMethod(paymentMethod);
    } catch (e) {
      // Error adding payment method: $e
      rethrow;
    }
  }

  Future<void> updatePaymentMethod(PaymentMethod paymentMethod) async {
    try {
      await _firestoreService.updatePaymentMethod(paymentMethod);
    } catch (e) {
      // Error updating payment method: $e
      rethrow;
    }
  }

  Future<void> removePaymentMethod(String id) async {
    try {
      await _firestoreService.deletePaymentMethod(id);
    } catch (e) {
      // Error removing payment method: $e
      rethrow;
    }
  }

  Future<void> deleteAllTransactionsForPaymentMethod(
      String paymentMethodName) async {
    try {
      await _firestoreService
          .deleteAllTransactionsForPaymentMethod(paymentMethodName);
    } catch (e) {
      // Error deleting transactions for payment method: $e
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final upiAppListProvider = StateProvider<List<UpiApp>>((ref) => [
      UpiApp(id: 'gpay', name: 'Google Pay', iconAsset: ''),
      UpiApp(id: 'phonepe', name: 'PhonePe', iconAsset: ''),
      UpiApp(id: 'amazonpay', name: 'Amazon Pay', iconAsset: ''),
      UpiApp(id: 'paytm', name: 'Paytm', iconAsset: ''),
    ]);
final recordListProvider = StreamProvider<List<Record>>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return firestoreService.getRecords();
});

class RecordListNotifier extends StateNotifier<List<Record>> {
  final FirestoreService _firestoreService;

  RecordListNotifier(this._firestoreService) : super([]);

  Future<void> addRecord(Record record) async {
    try {
      await _firestoreService.addRecord(record);
    } catch (e) {
      throw Exception('Failed to add record: $e');
    }
  }

  Future<void> removeRecord(String id) async {
    try {
      await _firestoreService.deleteRecord(id);
    } catch (e) {
      throw Exception('Failed to remove record: $e');
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _firestoreService.deleteRecord(id);
    } catch (e) {
      throw Exception('Failed to delete record: $e');
    }
  }

  Future<void> updateRecord(Record updatedRecord) async {
    try {
      await _firestoreService.updateRecord(updatedRecord);
    } catch (e) {
      throw Exception('Failed to update record: $e');
    }
  }
}

final recordListNotifierProvider =
    StateNotifierProvider<RecordListNotifier, List<Record>>(
  (ref) => RecordListNotifier(ref.read(firestoreServiceProvider)),
);
