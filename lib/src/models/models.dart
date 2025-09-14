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
