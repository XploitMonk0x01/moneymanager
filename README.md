# MoneyManager

MoneyManager is a modern Flutter app for tracking your expenses, managing your budget, and keeping records of your financial activities. Built with Material 3 expressive UI, it offers a beautiful, intuitive, and powerful experience for personal finance management.

## Features

- 📊 **Dashboard**: Visualize your income, expenses, and trends with expressive charts and analytics.
- 💸 **Record Transactions**: Add, edit, and categorize your income and expenses.
- 🏦 **Accounts**: Manage multiple payment methods and account balances.
- 📅 **Calendar View**: See your transactions by date and plan ahead.
- ☁️ **Cloud Sync**: Backup and restore your data securely with Firebase.
- 🗑️ **Delete & Reset**: Easily clear all data or reset app settings.
- 💬 **Feedback**: Send feedback directly from the app.
- 🎨 **Material 3 Design**: Enjoy a modern, adaptive, and expressive UI.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- A Firebase project (for cloud sync)

### Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/moneymanager.git
   cd moneymanager
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Firebase setup:**
   - Add your `google-services.json` to `android/app/` (not included in repo).
   - Configure Firebase in the [Firebase Console](https://console.firebase.google.com/).
4. **Run the app:**
   ```sh
   flutter run
   ```

### Building APK

To build a release APK:

```sh
flutter build apk --release
```

## Folder Structure

- `lib/` - Main Dart codebase
  - `src/screens/` - App screens (dashboard, analysis, accounts, record, etc.)
  - `src/models/` - Data models
  - `src/services/` - Data and cloud services
  - `src/widgets/` - Reusable widgets
  - `src/core/` - Theme and constants
- `assets/` - App icons and images

## Security & Credentials

- **Never commit your `google-services.json` or other credentials to GitHub.**
- Sensitive files are excluded via `.gitignore`.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](LICENSE)

---

> Built with ❤️ using Flutter and Firebase.
