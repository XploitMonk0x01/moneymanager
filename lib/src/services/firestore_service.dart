import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart' as app;

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Helper method to create IconData instances safely for release builds
  static IconData _createIconData(int codePoint, String? fontFamily) {
    // Use const constructor when possible for better tree shaking
    if (fontFamily == null || fontFamily == 'MaterialIcons') {
      // For Material Icons, we can use const constructors
      switch (codePoint) {
        case 0xe22b:
          return Icons.account_balance_wallet;
        case 0xe263:
          return Icons.credit_card;
        case 0xe8e6:
          return Icons.payment;
        case 0xe3d3:
          return Icons.category;
        case 0xe5ca:
          return Icons.money;
        case 0xe57c:
          return Icons.fastfood;
        case 0xe3f5:
          return Icons.health_and_safety;
        case 0xe1ca:
          return Icons.devices_other;
        case 0xe539:
          return Icons.flight;
        case 0xe0b7:
          return Icons.receipt_long;
        case 0xe61d:
          return Icons.phone_android;
        case 0xe1b8:
          return Icons.shopping_cart;
        case 0xe1d1:
          return Icons.local_gas_station;
        case 0xe54f:
          return Icons.movie;
        case 0xe55c:
          return Icons.school;
        case 0xe87d:
          return Icons.pets;
        case 0xe1bb:
          return Icons.home;
        case 0xe1a3:
          return Icons.directions_car;
        case 0xe0ca:
          return Icons.work;
        default:
          return Icons.help_outline;
      }
    }
    // For custom fonts, return a default icon to avoid non-const constructor
    return Icons.help_outline;
  }

  // Transaction CRUD operations
  Future<void> addTransaction(app.Transaction tx) async {
    try {
      await _db.collection('transactions').doc(tx.id).set({
        'amount': tx.amount,
        'categoryId': tx.categoryId,
        'paymentMethod': tx.paymentMethod,
        'upiApp': tx.upiApp,
        'date': tx.date.toIso8601String(),
        'notes': tx.notes,
        'isIncome': tx.isIncome,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Stream<List<app.Transaction>> getTransactions() {
    // Querying transactions from Firestore...
    return _db
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      // Raw snapshot: ${snapshot.docs.length} documents
      final transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        // Document ${doc.id}: $data
        return app.Transaction(
          id: doc.id,
          amount: (data['amount'] as num).toDouble(),
          categoryId: data['categoryId'] ?? '',
          paymentMethod: data['paymentMethod'] ?? '',
          upiApp: data['upiApp'],
          date: DateTime.parse(data['date']),
          notes: data['notes'],
          isIncome: data['isIncome'] ?? false,
        );
      }).toList();
      // Parsed ${transactions.length} transactions
      return transactions;
    });
  }

  Future<void> updateTransaction(app.Transaction tx) async {
    try {
      await _db.collection('transactions').doc(tx.id).update({
        'amount': tx.amount,
        'categoryId': tx.categoryId,
        'paymentMethod': tx.paymentMethod,
        'upiApp': tx.upiApp,
        'date': tx.date.toIso8601String(),
        'notes': tx.notes,
        'isIncome': tx.isIncome,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _db.collection('transactions').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Category CRUD operations
  Future<void> addCategory(app.Category category) async {
    try {
      await _db.collection('categories').doc(category.id).set({
        'name': category.name,
        'iconCodePoint': category.icon.codePoint,
        'iconFontFamily': category.icon.fontFamily,
        'isCustom': category.isCustom,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Stream<List<app.Category>> getCategories() {
    return _db
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return app.Category(
          id: doc.id,
          name: data['name'] ?? '',
          icon: _createIconData(
            data['iconCodePoint'] ?? Icons.category.codePoint,
            data['iconFontFamily'],
          ),
          isCustom: data['isCustom'] ?? false,
        );
      }).toList();
    });
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _db.collection('categories').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Payment Method CRUD operations
  Future<void> addPaymentMethod(app.PaymentMethod paymentMethod) async {
    try {
      await _db.collection('payment_methods').doc(paymentMethod.id).set({
        'name': paymentMethod.name,
        'iconCodePoint': paymentMethod.icon.codePoint,
        'iconFontFamily': paymentMethod.icon.fontFamily,
        'isActive': paymentMethod.isActive,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add payment method: $e');
    }
  }

  Stream<List<app.PaymentMethod>> getPaymentMethods() {
    return _db
        .collection('payment_methods')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return app.PaymentMethod(
          id: doc.id,
          name: data['name'] ?? '',
          icon: _createIconData(
            data['iconCodePoint'] ?? Icons.payment.codePoint,
            data['iconFontFamily'],
          ),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    });
  }

  Future<void> updatePaymentMethod(app.PaymentMethod paymentMethod) async {
    try {
      await _db.collection('payment_methods').doc(paymentMethod.id).update({
        'name': paymentMethod.name,
        'iconCodePoint': paymentMethod.icon.codePoint,
        'iconFontFamily': paymentMethod.icon.fontFamily,
        'isActive': paymentMethod.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    try {
      // Soft delete - mark as inactive instead of deleting
      await _db.collection('payment_methods').doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete payment method: $e');
    }
  }

  Future<void> deleteAllTransactionsForPaymentMethod(
      String paymentMethodName) async {
    try {
      final transactionsSnapshot = await _db
          .collection('transactions')
          .where('paymentMethod', isEqualTo: paymentMethodName)
          .get();

      for (var doc in transactionsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete transactions for payment method: $e');
    }
  }

  // Record CRUD operations
  Future<void> addRecord(app.Record record) async {
    try {
      await _db.collection('records').doc(record.id).set({
        'person': record.person,
        'amount': record.amount,
        'isBorrowed': record.isBorrowed,
        'date': record.date.toIso8601String(),
        'notes': record.notes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add record: $e');
    }
  }

  Future<void> updateRecord(app.Record record) async {
    try {
      await _db.collection('records').doc(record.id).update({
        'person': record.person,
        'amount': record.amount,
        'isBorrowed': record.isBorrowed,
        'date': record.date.toIso8601String(),
        'notes': record.notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update record: $e');
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await _db.collection('records').doc(recordId).delete();
    } catch (e) {
      throw Exception('Failed to delete record: $e');
    }
  }

  Stream<List<app.Record>> getRecords() {
    return _db
        .collection('records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return app.Record(
          id: doc.id,
          person: data['person'] ?? '',
          amount: (data['amount'] ?? 0).toDouble(),
          isBorrowed: data['isBorrowed'] ?? false,
          date: data['date'] != null
              ? DateTime.parse(data['date'])
              : DateTime.now(),
          notes: data['notes'] ?? '',
        );
      }).toList();
    });
  }

  // UPI App CRUD operations
  Future<void> addUpiApp(app.UpiApp upiApp) async {
    try {
      await _db.collection('upi_apps').doc(upiApp.id).set({
        'name': upiApp.name,
        'iconAsset': upiApp.iconAsset,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add UPI app: $e');
    }
  }

  Stream<List<app.UpiApp>> getUpiApps() {
    return _db
        .collection('upi_apps')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return app.UpiApp(
          id: doc.id,
          name: data['name'] ?? '',
          iconAsset: data['iconAsset'] ?? '',
        );
      }).toList();
    });
  }

  Future<void> updateUpiApp(app.UpiApp upiApp) async {
    try {
      await _db.collection('upi_apps').doc(upiApp.id).update({
        'name': upiApp.name,
        'iconAsset': upiApp.iconAsset,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update UPI app: $e');
    }
  }

  Future<void> deleteUpiApp(String id) async {
    try {
      await _db.collection('upi_apps').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete UPI app: $e');
    }
  }

  // AutoPay CRUD operations
  Future<void> addAutoPay(app.AutoPay autoPay) async {
    try {
      await _db.collection('autopays').doc(autoPay.id).set({
        'title': autoPay.title,
        'amount': autoPay.amount,
        'categoryId': autoPay.categoryId,
        'upiApp': autoPay.upiApp,
        'startDate': autoPay.startDate.toIso8601String(),
        'validUntil': autoPay.validUntil.toIso8601String(),
        'notes': autoPay.notes,
        'isActive': autoPay.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add autopay: $e');
    }
  }

  Stream<List<app.AutoPay>> getAutoPays() {
    return _db
        .collection('autopays')
        .orderBy('validUntil', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return app.AutoPay(
          id: doc.id,
          title: data['title'] ?? '',
          amount: (data['amount'] as num).toDouble(),
          categoryId: data['categoryId'] ?? '',
          upiApp: data['upiApp'] ?? '',
          startDate: DateTime.parse(data['startDate']),
          validUntil: DateTime.parse(data['validUntil']),
          notes: data['notes'],
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    });
  }

  Future<void> updateAutoPay(app.AutoPay autoPay) async {
    try {
      await _db.collection('autopays').doc(autoPay.id).update({
        'title': autoPay.title,
        'amount': autoPay.amount,
        'categoryId': autoPay.categoryId,
        'upiApp': autoPay.upiApp,
        'startDate': autoPay.startDate.toIso8601String(),
        'validUntil': autoPay.validUntil.toIso8601String(),
        'notes': autoPay.notes,
        'isActive': autoPay.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update autopay: $e');
    }
  }

  Future<void> deleteAutoPay(String id) async {
    try {
      await _db.collection('autopays').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete autopay: $e');
    }
  }

  Future<void> initializeDefaultData() async {
    try {
      // Check if categories already exist
      final categoriesSnapshot =
          await _db.collection('categories').limit(1).get();

      if (categoriesSnapshot.docs.isEmpty) {
        // Add default categories
        final defaultCategories = [
          app.Category(id: 'food', name: 'Food', icon: Icons.fastfood),
          app.Category(
              id: 'health', name: 'Health', icon: Icons.health_and_safety),
          app.Category(
              id: 'electronics',
              name: 'Electronics',
              icon: Icons.devices_other),
          app.Category(id: 'travel', name: 'Travel', icon: Icons.flight),
          app.Category(id: 'bills', name: 'Bills', icon: Icons.receipt_long),
          app.Category(
              id: 'recharge', name: 'Recharge', icon: Icons.phone_android),
          app.Category(id: 'social', name: 'Social', icon: Icons.people),
          app.Category(
              id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag),
          app.Category(id: 'salary', name: 'Salary', icon: Icons.work),
          app.Category(
              id: 'investment', name: 'Investment', icon: Icons.trending_up),
          app.Category(
              id: 'maintenance',
              name: 'Maintenance',
              icon: Icons.home_repair_service),
          app.Category(id: 'home', name: 'Home', icon: Icons.home),
          app.Category(
              id: 'other_expense', name: 'Other', icon: Icons.more_horiz),
        ];

        for (final category in defaultCategories) {
          await addCategory(category);
        }
      }

      // Check if payment methods already exist
      final paymentMethodsSnapshot =
          await _db.collection('payment_methods').limit(1).get();

      if (paymentMethodsSnapshot.docs.isEmpty) {
        // Add default payment methods
        final defaultPaymentMethods = [
          app.PaymentMethod(id: 'cash', name: 'Cash', icon: Icons.money),
          app.PaymentMethod(
              id: 'upi', name: 'UPI', icon: Icons.account_balance_wallet),
          app.PaymentMethod(
              id: 'debit_card', name: 'Debit Card', icon: Icons.credit_card),
          app.PaymentMethod(
              id: 'credit_card',
              name: 'Credit Card',
              icon: Icons.credit_card_outlined),
          app.PaymentMethod(
              id: 'bank_transfer',
              name: 'Bank Transfer',
              icon: Icons.account_balance),
          app.PaymentMethod(
              id: 'cheque', name: 'Cheque', icon: Icons.receipt_long),
        ];

        for (final paymentMethod in defaultPaymentMethods) {
          await addPaymentMethod(paymentMethod);
        }
      }

      // Check if UPI apps already exist
      final upiAppsSnapshot = await _db.collection('upi_apps').limit(1).get();

      if (upiAppsSnapshot.docs.isEmpty) {
        // Add default UPI apps
        final defaultUpiApps = [
          app.UpiApp(id: 'gpay', name: 'Google Pay', iconAsset: ''),
          app.UpiApp(id: 'phonepe', name: 'PhonePe', iconAsset: ''),
          app.UpiApp(id: 'paytm', name: 'Paytm', iconAsset: ''),
          app.UpiApp(id: 'amazonpay', name: 'Amazon Pay', iconAsset: ''),
          app.UpiApp(id: 'bhim', name: 'BHIM UPI', iconAsset: ''),
        ];

        for (final upiApp in defaultUpiApps) {
          await addUpiApp(upiApp);
        }
      }
    } catch (e) {
      // Error initializing default data: $e
    }
  }

  /// Deletes all user data from Firestore
  /// This includes all transactions, records, categories, and payment methods
  // Granular delete methods for enhanced delete functionality

  /// Delete all transactions only
  Future<void> deleteTransactions() async {
    try {
      final batch = _db.batch();
      final snapshot = await _db.collection('transactions').get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete transactions: $e');
    }
  }

  /// Delete all borrow/lend records only
  Future<void> deleteRecords() async {
    try {
      final batch = _db.batch();
      final snapshot = await _db.collection('records').get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete records: $e');
    }
  }

  /// Delete custom categories only (keeps default categories)
  Future<void> deleteCustomCategories() async {
    try {
      final batch = _db.batch();
      final snapshot = await _db
          .collection('categories')
          .where('isCustom', isEqualTo: true)
          .get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete custom categories: $e');
    }
  }

  /// Delete all custom payment methods
  Future<void> deleteCustomPaymentMethods() async {
    try {
      final batch = _db.batch();
      final snapshot = await _db.collection('payment_methods').get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete custom payment methods: $e');
    }
  }

  /// Delete all custom UPI apps and reinitialize defaults
  Future<void> deleteCustomUpiApps() async {
    try {
      final batch = _db.batch();
      final snapshot = await _db.collection('upi_apps').get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Reinitialize default UPI apps
      await initializeDefaultData();
    } catch (e) {
      throw Exception('Failed to delete custom UPI apps: $e');
    }
  }

  /// Delete selected user data based on options
  Future<void> deleteSelectedUserData({
    required bool transactions,
    required bool records,
    required bool customCategories,
    required bool customPaymentMethods,
    required bool customUpiApps,
  }) async {
    try {
      if (transactions) await deleteTransactions();
      if (records) await deleteRecords();
      if (customCategories) await deleteCustomCategories();
      if (customPaymentMethods) await deleteCustomPaymentMethods();
      if (customUpiApps) await deleteCustomUpiApps();
    } catch (e) {
      throw Exception('Failed to delete selected data: $e');
    }
  }

  Future<void> deleteAllUserData() async {
    try {
      // Use batched writes for better performance and atomicity
      final batch = _db.batch();

      // Delete all transactions
      final transactionsSnapshot = await _db.collection('transactions').get();
      for (final doc in transactionsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all records (borrow/lend)
      final recordsSnapshot = await _db.collection('records').get();
      for (final doc in recordsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all custom categories (keep default ones or delete all)
      final categoriesSnapshot = await _db.collection('categories').get();
      for (final doc in categoriesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete all custom payment methods
      final paymentMethodsSnapshot =
          await _db.collection('payment_methods').get();
      for (final doc in paymentMethodsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit all deletions
      await batch.commit();

      // Reinitialize default data
      await initializeDefaultData();
    } catch (e) {
      throw Exception('Failed to delete all user data: $e');
    }
  }
}
