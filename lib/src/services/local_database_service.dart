import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../models/models.dart' as app;

class LocalDatabaseService {
  static Database? _database;
  static const String _databaseName = 'moneymanager_offline.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _transactionsTable = 'transactions';
  static const String _recordsTable = 'records';
  static const String _categoriesTable = 'categories';
  static const String _paymentMethodsTable = 'payment_methods';
  static const String _metadataTable = 'metadata';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE $_transactionsTable (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        categoryId TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        upiApp TEXT,
        notes TEXT,
        date TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        synced INTEGER DEFAULT 1
      )
    ''');

    // Create records table
    await db.execute('''
      CREATE TABLE $_recordsTable (
        id TEXT PRIMARY KEY,
        person TEXT NOT NULL,
        amount REAL NOT NULL,
        isBorrowed INTEGER NOT NULL,
        date TEXT NOT NULL,
        notes TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        synced INTEGER DEFAULT 1
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE $_categoriesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        iconFontFamily TEXT,
        isCustom INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create payment methods table
    await db.execute('''
      CREATE TABLE $_paymentMethodsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        iconFontFamily TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create metadata table for sync tracking
    await db.execute('''
      CREATE TABLE $_metadataTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Set initial last sync time
    await db.insert(_metadataTable, {
      'key': 'last_sync',
      'value': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < newVersion) {
      // Add migration logic here when schema changes
    }
  }

  // =============== TRANSACTION OPERATIONS ===============

  Future<void> cacheTransaction(app.Transaction transaction) async {
    final db = await database;
    await db.insert(
      _transactionsTable,
      {
        'id': transaction.id,
        'amount': transaction.amount,
        'categoryId': transaction.categoryId,
        'paymentMethod': transaction.paymentMethod,
        'upiApp': transaction.upiApp,
        'notes': transaction.notes,
        'date': transaction.date.toIso8601String(),
        'isIncome': transaction.isIncome ? 1 : 0,
        'createdAt': DateTime.now().toIso8601String(),
        'synced': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cacheTransactions(List<app.Transaction> transactions) async {
    final db = await database;
    final batch = db.batch();

    for (final transaction in transactions) {
      batch.insert(
        _transactionsTable,
        {
          'id': transaction.id,
          'amount': transaction.amount,
          'categoryId': transaction.categoryId,
          'paymentMethod': transaction.paymentMethod,
          'upiApp': transaction.upiApp,
          'notes': transaction.notes,
          'date': transaction.date.toIso8601String(),
          'isIncome': transaction.isIncome ? 1 : 0,
          'createdAt': DateTime.now().toIso8601String(),
          'synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<app.Transaction>> getCachedTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _transactionsTable,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return app.Transaction(
        id: maps[i]['id'],
        amount: maps[i]['amount'],
        categoryId: maps[i]['categoryId'],
        paymentMethod: maps[i]['paymentMethod'],
        upiApp: maps[i]['upiApp'],
        notes: maps[i]['notes'],
        date: DateTime.parse(maps[i]['date']),
        isIncome: maps[i]['isIncome'] == 1,
      );
    });
  }

  // =============== RECORD OPERATIONS ===============

  Future<void> cacheRecord(app.Record record) async {
    final db = await database;
    await db.insert(
      _recordsTable,
      {
        'id': record.id,
        'person': record.person,
        'amount': record.amount,
        'isBorrowed': record.isBorrowed ? 1 : 0,
        'date': record.date.toIso8601String(),
        'notes': record.notes,
        'createdAt': DateTime.now().toIso8601String(),
        'synced': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cacheRecords(List<app.Record> records) async {
    final db = await database;
    final batch = db.batch();

    for (final record in records) {
      batch.insert(
        _recordsTable,
        {
          'id': record.id,
          'person': record.person,
          'amount': record.amount,
          'isBorrowed': record.isBorrowed ? 1 : 0,
          'date': record.date.toIso8601String(),
          'notes': record.notes,
          'createdAt': DateTime.now().toIso8601String(),
          'synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<app.Record>> getCachedRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _recordsTable,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return app.Record(
        id: maps[i]['id'],
        person: maps[i]['person'],
        amount: maps[i]['amount'],
        isBorrowed: maps[i]['isBorrowed'] == 1,
        date: DateTime.parse(maps[i]['date']),
        notes: maps[i]['notes'],
      );
    });
  }

  // =============== CATEGORY OPERATIONS ===============

  Future<void> cacheCategory(app.Category category) async {
    final db = await database;
    await db.insert(
      _categoriesTable,
      {
        'id': category.id,
        'name': category.name,
        'iconCodePoint': category.icon.codePoint,
        'iconFontFamily': category.icon.fontFamily,
        'isCustom': category.isCustom ? 1 : 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cacheCategories(List<app.Category> categories) async {
    final db = await database;
    final batch = db.batch();

    for (final category in categories) {
      batch.insert(
        _categoriesTable,
        {
          'id': category.id,
          'name': category.name,
          'iconCodePoint': category.icon.codePoint,
          'iconFontFamily': category.icon.fontFamily,
          'isCustom': category.isCustom ? 1 : 0,
          'createdAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<app.Category>> getCachedCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _categoriesTable,
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return app.Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        icon: IconData(
          maps[i]['iconCodePoint'],
          fontFamily: maps[i]['iconFontFamily'],
        ),
        isCustom: maps[i]['isCustom'] == 1,
      );
    });
  }

  // =============== PAYMENT METHOD OPERATIONS ===============

  Future<void> cachePaymentMethod(app.PaymentMethod paymentMethod) async {
    final db = await database;
    await db.insert(
      _paymentMethodsTable,
      {
        'id': paymentMethod.id,
        'name': paymentMethod.name,
        'iconCodePoint': paymentMethod.icon.codePoint,
        'iconFontFamily': paymentMethod.icon.fontFamily,
        'isActive': paymentMethod.isActive ? 1 : 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cachePaymentMethods(
      List<app.PaymentMethod> paymentMethods) async {
    final db = await database;
    final batch = db.batch();

    for (final paymentMethod in paymentMethods) {
      batch.insert(
        _paymentMethodsTable,
        {
          'id': paymentMethod.id,
          'name': paymentMethod.name,
          'iconCodePoint': paymentMethod.icon.codePoint,
          'iconFontFamily': paymentMethod.icon.fontFamily,
          'isActive': paymentMethod.isActive ? 1 : 0,
          'createdAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<app.PaymentMethod>> getCachedPaymentMethods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _paymentMethodsTable,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return app.PaymentMethod(
        id: maps[i]['id'],
        name: maps[i]['name'],
        icon: IconData(
          maps[i]['iconCodePoint'],
          fontFamily: maps[i]['iconFontFamily'],
        ),
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }

  // =============== METADATA OPERATIONS ===============

  Future<void> updateLastSyncTime() async {
    final db = await database;
    await db.update(
      _metadataTable,
      {
        'value': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'key = ?',
      whereArgs: ['last_sync'],
    );
  }

  Future<DateTime?> getLastSyncTime() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _metadataTable,
      where: 'key = ?',
      whereArgs: ['last_sync'],
    );

    if (maps.isEmpty) return null;
    return DateTime.parse(maps[0]['value']);
  }

  // =============== CLEAR DATA OPERATIONS ===============

  Future<void> clearAllCachedData() async {
    final db = await database;
    await db.delete(_transactionsTable);
    await db.delete(_recordsTable);
    await db.delete(_categoriesTable);
    await db.delete(_paymentMethodsTable);
  }

  Future<void> clearCachedTransactions() async {
    final db = await database;
    await db.delete(_transactionsTable);
  }

  Future<void> clearCachedRecords() async {
    final db = await database;
    await db.delete(_recordsTable);
  }

  Future<void> clearCachedCategories() async {
    final db = await database;
    await db.delete(_categoriesTable);
  }

  Future<void> clearCachedPaymentMethods() async {
    final db = await database;
    await db.delete(_paymentMethodsTable);
  }

  // =============== DATABASE OPERATIONS ===============

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
