import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CategoryData {
  static final Map<String, IconData> _categoryIcons = {
    // Income Categories
    'salary': Icons.work,
    'business': Icons.business,
    'investment': Icons.trending_up,
    'bonus': Icons.card_giftcard,
    'freelance': Icons.laptop,
    'rental': Icons.home,
    'dividend': Icons.money,
    'gift': Icons.redeem,
    'refund': Icons.receipt_long,
    'other_income': Icons.add_circle,

    // Expense Categories
    'food': Icons.restaurant,
    'groceries': Icons.local_grocery_store,
    'transport': Icons.directions_car,
    'fuel': Icons.local_gas_station,
    'shopping': Icons.shopping_bag,
    'entertainment': Icons.movie,
    'health': Icons.local_hospital,
    'education': Icons.school,
    'bills': Icons.receipt,
    'rent': Icons.home_work,
    'insurance': Icons.security,
    'travel': Icons.flight,
    'clothing': Icons.checkroom,
    'beauty': Icons.face,
    'fitness': Icons.fitness_center,
    'pet': MdiIcons.dog,
    'gift_expense': Icons.card_giftcard,
    'charity': Icons.volunteer_activism,
    'tax': Icons.account_balance,
    'fine': Icons.gavel,
    'repair': Icons.build,
    'subscription': Icons.subscriptions,
    'recharge': Icons.phone_android,
    'social': Icons.people,
    'internet': Icons.wifi,
    'electricity': Icons.bolt,
    'water': Icons.water_drop,
    'gas': Icons.local_fire_department,
    'maintenance': Icons.home_repair_service,
    'other_expense': Icons.more_horiz,
  };

  static final Map<String, Color> _categoryColors = {
    // Income Categories (Green shades)
    'salary': Colors.green,
    'business': Colors.teal,
    'investment': Colors.lightGreen,
    'bonus': Colors.green.shade700,
    'freelance': Colors.teal.shade600,
    'rental': Colors.green.shade600,
    'dividend': Colors.teal.shade700,
    'gift': Colors.lightGreen.shade600,
    'refund': Colors.green.shade500,
    'other_income': Colors.teal.shade500,

    // Expense Categories (Various colors)
    'food': Colors.orange,
    'groceries': Colors.green.shade400,
    'transport': Colors.blue,
    'fuel': Colors.red.shade600,
    'shopping': Colors.purple,
    'entertainment': Colors.pink,
    'health': Colors.red,
    'education': Colors.indigo,
    'bills': Colors.amber,
    'rent': Colors.brown,
    'insurance': Colors.blueGrey,
    'travel': Colors.cyan,
    'clothing': Colors.deepPurple,
    'beauty': Colors.pink.shade300,
    'fitness': Colors.orange.shade600,
    'pet': Colors.brown.shade400,
    'gift_expense': Colors.pink.shade400,
    'charity': Colors.green.shade700,
    'tax': Colors.grey.shade600,
    'fine': Colors.red.shade700,
    'repair': Colors.orange.shade700,
    'subscription': Colors.blue.shade600,
    'recharge': Colors.blue.shade400,
    'social': Colors.purple.shade400,
    'internet': Colors.indigo.shade400,
    'electricity': Colors.yellow.shade600,
    'water': Colors.blue.shade300,
    'gas': Colors.orange.shade400,
    'maintenance': Colors.brown.shade500,
    'other_expense': Colors.grey,
  };

  static final List<Map<String, dynamic>> incomeCategories = [
    {'id': 'salary', 'name': 'Salary', 'icon': Icons.work},
    {'id': 'business', 'name': 'Business', 'icon': Icons.business},
    {'id': 'investment', 'name': 'Investment', 'icon': Icons.trending_up},
    {'id': 'bonus', 'name': 'Bonus', 'icon': Icons.card_giftcard},
    {'id': 'freelance', 'name': 'Freelance', 'icon': Icons.laptop},
    {'id': 'rental', 'name': 'Rental Income', 'icon': Icons.home},
    {'id': 'dividend', 'name': 'Dividend', 'icon': Icons.money},
    {'id': 'gift', 'name': 'Gift', 'icon': Icons.redeem},
    {'id': 'refund', 'name': 'Refund', 'icon': Icons.receipt_long},
    {'id': 'other_income', 'name': 'Other Income', 'icon': Icons.add_circle},
  ];

  static final List<Map<String, dynamic>> expenseCategories = [
    {'id': 'food', 'name': 'Food & Dining', 'icon': Icons.restaurant},
    {'id': 'groceries', 'name': 'Groceries', 'icon': Icons.local_grocery_store},
    {'id': 'transport', 'name': 'Transport', 'icon': Icons.directions_car},
    {'id': 'fuel', 'name': 'Fuel', 'icon': Icons.local_gas_station},
    {'id': 'shopping', 'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'id': 'entertainment', 'name': 'Entertainment', 'icon': Icons.movie},
    {'id': 'health', 'name': 'Health & Medical', 'icon': Icons.local_hospital},
    {'id': 'education', 'name': 'Education', 'icon': Icons.school},
    {'id': 'bills', 'name': 'Bills & Utilities', 'icon': Icons.receipt},
    {'id': 'rent', 'name': 'Rent', 'icon': Icons.home_work},
    {'id': 'insurance', 'name': 'Insurance', 'icon': Icons.security},
    {'id': 'travel', 'name': 'Travel', 'icon': Icons.flight},
    {'id': 'clothing', 'name': 'Clothing', 'icon': Icons.checkroom},
    {'id': 'beauty', 'name': 'Beauty & Personal Care', 'icon': Icons.face},
    {'id': 'fitness', 'name': 'Fitness & Sports', 'icon': Icons.fitness_center},
    {'id': 'pet', 'name': 'Pet Care', 'icon': MdiIcons.dog},
    {
      'id': 'gift_expense',
      'name': 'Gifts & Donations',
      'icon': Icons.card_giftcard
    },
    {'id': 'charity', 'name': 'Charity', 'icon': Icons.volunteer_activism},
    {'id': 'tax', 'name': 'Tax', 'icon': Icons.account_balance},
    {'id': 'fine', 'name': 'Fine & Penalty', 'icon': Icons.gavel},
    {'id': 'repair', 'name': 'Repair & Maintenance', 'icon': Icons.build},
    {
      'id': 'subscription',
      'name': 'Subscriptions',
      'icon': Icons.subscriptions
    },
    {'id': 'recharge', 'name': 'Mobile Recharge', 'icon': Icons.phone_android},
    {'id': 'social', 'name': 'Social', 'icon': Icons.people},
    {'id': 'internet', 'name': 'Internet', 'icon': Icons.wifi},
    {'id': 'electricity', 'name': 'Electricity', 'icon': Icons.bolt},
    {'id': 'water', 'name': 'Water', 'icon': Icons.water_drop},
    {'id': 'gas', 'name': 'Gas', 'icon': Icons.local_fire_department},
    {
      'id': 'maintenance',
      'name': 'Maintenance',
      'icon': Icons.home_repair_service
    },
    {'id': 'other_expense', 'name': 'Other Expenses', 'icon': Icons.more_horiz},
  ];

  static IconData getIcon(String categoryId) {
    return _categoryIcons[categoryId] ?? Icons.category;
  }

  static Color getColor(String categoryId) {
    return _categoryColors[categoryId] ?? Colors.grey;
  }

  static String getName(String categoryId) {
    // First check income categories
    for (var category in incomeCategories) {
      if (category['id'] == categoryId) {
        return category['name'];
      }
    }
    // Then check expense categories
    for (var category in expenseCategories) {
      if (category['id'] == categoryId) {
        return category['name'];
      }
    }
    return categoryId; // Fallback to ID if not found
  }

  static bool isIncomeCategory(String categoryId) {
    return incomeCategories.any((category) => category['id'] == categoryId);
  }

  static List<Map<String, dynamic>> getAllCategories() {
    return [...incomeCategories, ...expenseCategories];
  }
}
