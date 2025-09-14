class AppConstants {
  // App Information
  static const String appName = 'MoneyManager';
  static const String appVersion = '1.0.0';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 24.0;
  static const double smallBorderRadius = 12.0;
  static const double iconSize = 32.0;
  static const double smallIconSize = 16.0;

  // UPI App Icon Dimensions
  static const double upiIconSize = 28.0; // For list items and cards
  static const double upiIconSizeLarge = 48.0; // For prominent displays
  static const double upiIconSizeSmall = 20.0; // For compact layouts

  // Animation Durations
  static const int defaultAnimationDuration = 300;
  static const int longAnimationDuration = 600;
  static const int shortAnimationDuration = 150;

  // Date Formats
  static const String dateFormat = 'dd MMM, EEEE';
  static const String timeFormat = 'hh:mm a';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String shortDateFormat = 'dd MMM yyyy';

  // Messages
  static const String noTransactionsMessage = 'No transactions yet.';
  static const String noDataMessage = 'No data available';
  static const String startAddingTransactionsMessage =
      'Start adding transactions to see your spending analysis';

  // Default Values
  static const double defaultAmount = 0.0;
  static const String defaultCurrency = '₹';

  // Firebase Collections
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';
  static const String recordsCollection = 'records';
  static const String upiAppsCollection = 'upi_apps';

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String authErrorMessage =
      'Authentication failed. Please login again.';

  // Success Messages
  static const String transactionAddedMessage =
      'Transaction added successfully!';
  static const String recordAddedMessage = 'Record added successfully!';
  static const String dataUpdatedMessage = 'Data updated successfully!';

  // Validation Messages
  static const String emptyFieldMessage = 'This field cannot be empty';
  static const String invalidAmountMessage = 'Please enter a valid amount';
  static const String invalidDateMessage = 'Please select a valid date';

  // Limits
  static const int maxTransactionAmount = 1000000;
  static const int minTransactionAmount = 1;
  static const int maxDescriptionLength = 100;
  static const int maxPersonNameLength = 50;
}

class CategoryDefaults {
  static const Map<String, dynamic> defaultCategories = {
    'Food': {'icon': 'Icons.restaurant', 'color': 'Colors.orange'},
    'Transport': {'icon': 'Icons.directions_car', 'color': 'Colors.blue'},
    'Shopping': {'icon': 'Icons.shopping_bag', 'color': 'Colors.pink'},
    'Entertainment': {'icon': 'Icons.movie', 'color': 'Colors.purple'},
    'Healthcare': {'icon': 'Icons.local_hospital', 'color': 'Colors.red'},
    'Education': {'icon': 'Icons.school', 'color': 'Colors.green'},
    'Bills': {'icon': 'Icons.receipt', 'color': 'Colors.brown'},
    'Other': {'icon': 'Icons.category', 'color': 'Colors.grey'},
  };
}

class UPIDefaults {
  static const Map<String, String> defaultUPIApps = {
    'Google Pay': '', // Will use default icon
    'PhonePe': '', // Will use default icon
    'Paytm': '', // Will use default icon
    'Amazon Pay': '', // Will use default icon
    'BHIM': '', // Will use default icon
    'PayPal': '', // Will use default icon
  };

  // Icon mapping for UPI apps when assets are not available
  static const Map<String, int> upiAppIcons = {
    'Google Pay': 0xe57c, // Icons.account_balance_wallet
    'PhonePe': 0xe57c, // Icons.account_balance_wallet
    'Paytm': 0xe57c, // Icons.account_balance_wallet
    'Amazon Pay': 0xe57c, // Icons.account_balance_wallet
    'BHIM': 0xe57c, // Icons.account_balance_wallet
    'PayPal': 0xe57c, // Icons.account_balance_wallet
  };
}
