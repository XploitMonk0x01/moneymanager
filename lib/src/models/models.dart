import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final double amount;
  final String categoryId;
  final String paymentMethod; // UPI, Cash, Card, Bank Transfer
  final String? upiApp; // If paymentMethod == UPI
  final DateTime date;
  final String? notes;
  final bool isIncome; // true: income, false: expense

  Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.paymentMethod,
    this.upiApp,
    required this.date,
    this.notes,
    required this.isIncome,
  });
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final bool isCustom;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.isCustom = false,
  });
}

class UpiApp {
  final String id;
  final String name;
  final String iconAsset;

  UpiApp({
    required this.id,
    required this.name,
    required this.iconAsset,
  });
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isActive = true,
  });
}

class Record {
  final String id;
  final String person;
  final double amount;
  final bool isBorrowed; // true: borrowed, false: given
  final DateTime date;
  final String notes;

  Record({
    required this.id,
    required this.person,
    required this.amount,
    required this.isBorrowed,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person': person,
      'amount': amount,
      'isBorrowed': isBorrowed,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'] as String,
      person: json['person'] as String,
      amount: (json['amount'] as num).toDouble(),
      isBorrowed: json['isBorrowed'] as bool,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String,
    );
  }

  Record copyWith({
    String? id,
    String? person,
    double? amount,
    bool? isBorrowed,
    DateTime? date,
    String? notes,
  }) {
    return Record(
      id: id ?? this.id,
      person: person ?? this.person,
      amount: amount ?? this.amount,
      isBorrowed: isBorrowed ?? this.isBorrowed,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}

class AutoPay {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final String upiApp;
  final DateTime startDate;
  final DateTime validUntil;
  final String? notes;
  final bool isActive;

  AutoPay({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.upiApp,
    required this.startDate,
    required this.validUntil,
    this.notes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'upiApp': upiApp,
      'startDate': startDate.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
    };
  }

  factory AutoPay.fromJson(Map<String, dynamic> json) {
    return AutoPay(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      upiApp: json['upiApp'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  AutoPay copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    String? upiApp,
    DateTime? startDate,
    DateTime? validUntil,
    String? notes,
    bool? isActive,
  }) {
    return AutoPay(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      upiApp: upiApp ?? this.upiApp,
      startDate: startDate ?? this.startDate,
      validUntil: validUntil ?? this.validUntil,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);

  int get daysRemaining => validUntil.difference(DateTime.now()).inDays;
}
