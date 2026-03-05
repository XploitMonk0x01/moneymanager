<div align="center">

# MoneyManager

**A modern, feature-rich personal finance app built with Flutter & Firebase.**

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.2.1%2B2-blue)](CHANGELOG.md)

</div>

---

## Overview

MoneyManager is a polished Flutter application for tracking expenses, managing budgets, and gaining insight into your personal finances. It combines a beautiful **Material 3 expressive UI** with powerful features like cloud sync, local CSV backup, detailed analytics, and OLED-optimised dark mode — all in a single, lightweight app.

---

## Features

| Category               | Details                                                                                  |
| ---------------------- | ---------------------------------------------------------------------------------------- |
| 📊 **Dashboard**       | Financial overview with expressive charts, income/expense summaries, and trend analytics |
| 💸 **Transactions**    | Add, edit, delete, and categorise income and expenses with ease                          |
| 🏦 **Accounts**        | Track multiple payment methods and account balances simultaneously                       |
| 📅 **Calendar View**   | Browse transactions by date with an interactive calendar                                 |
| 📈 **Analysis**        | Detailed monthly/yearly breakdowns and category-level insights                           |
| ☁️ **Cloud Sync**      | Real-time backup and restore via Firebase Firestore                                      |
| 💾 **CSV Export**      | Export and restore all transaction data as CSV files locally                             |
| 🔒 **Biometric Auth**  | Secure app access with fingerprint / face unlock                                         |
| 🌑 **OLED Dark Mode**  | True-black backgrounds for OLED displays — saves battery and looks stunning              |
| 🎨 **Material 3 UI**   | Dynamic colour theming, expressive animations, and adaptive layouts                      |
| 💬 **In-App Feedback** | Send feedback directly from the settings screen                                          |

---

## Tech Stack

| Layer                | Technology                                                           |
| -------------------- | -------------------------------------------------------------------- |
| **Framework**        | [Flutter 3.0+](https://flutter.dev)                                  |
| **Language**         | [Dart 3.0+](https://dart.dev)                                        |
| **State Management** | [Riverpod](https://riverpod.dev)                                     |
| **Cloud Database**   | [Firebase Firestore](https://firebase.google.com/docs/firestore)     |
| **Local Database**   | [SQLite (sqflite)](https://pub.dev/packages/sqflite)                 |
| **Charts**           | [fl_chart](https://pub.dev/packages/fl_chart)                        |
| **Theming**          | [dynamic_color](https://pub.dev/packages/dynamic_color) · Material 3 |
| **Authentication**   | [local_auth](https://pub.dev/packages/local_auth)                    |

---

## Getting Started

### Prerequisites

- [Flutter SDK ≥ 3.0](https://flutter.dev/docs/get-started/install)
- [Dart SDK ≥ 3.0](https://dart.dev/get-dart)
- A [Firebase project](https://console.firebase.google.com/) with Firestore enabled

### Installation

1. **Clone the repository**

   ```sh
   git clone https://github.com/yourusername/moneymanager.git
   cd moneymanager
   ```

2. **Install dependencies**

   ```sh
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a project in the [Firebase Console](https://console.firebase.google.com/).
   - Enable **Cloud Firestore** in the database section.
   - Download `google-services.json` and place it in `android/app/`.
     > `google-services.json` is excluded from version control — never commit it.

4. **Run the app**
   ```sh
   flutter run
   ```

### Build Release APK

```sh
flutter build apk --release
```

---

## Project Structure

```
lib/
└── src/
    ├── core/           # Theme, constants, and app-wide configuration
    ├── data/           # Repository and data-access layer
    ├── models/         # Data models (transaction, account, category, etc.)
    ├── providers/      # Riverpod state providers
    ├── screens/        # Feature screens (dashboard, analysis, accounts, …)
    ├── services/       # Firebase, SQLite, and CSV services
    ├── utils/          # Helper functions and extensions
    └── widgets/        # Reusable UI components

assets/
├── icons/              # App icon and category icons
└── images/             # Illustrations, logos, and onboarding graphics
```

---

## Security

- **Never commit `google-services.json`** or any other credentials to version control.
- All sensitive files are listed in `.gitignore`.
- See [SECURITY.md](SECURITY.md) for the full security policy and vulnerability reporting process.

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a pull request.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a full history of releases and changes.

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
Built with ❤️ using Flutter and Firebase
</div>
