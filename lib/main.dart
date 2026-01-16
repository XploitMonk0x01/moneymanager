import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'src/screens/dashboard_screen.dart';
import 'src/screens/analysis_screen.dart';
import 'src/screens/accounts_screen.dart';
import 'src/screens/record_screen.dart';
import 'src/providers/providers.dart';
import 'src/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    // Firebase initialized successfully

    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('test').doc('connection').set({
      'timestamp': FieldValue.serverTimestamp(),
      'message': 'Firebase connection test successful'
    });
    // Firestore connection test successful
  } catch (e) {
    // Firebase initialization error: $e
  }

  runApp(const ProviderScope(child: MoneyManagerApp()));
}

class MoneyManagerApp extends ConsumerWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // Use the dynamic color scheme from the user's wallpaper
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          // Fallback to a Material 3 violet seed color when dynamic colors aren't available
          lightScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4), // Material 3 violet
            brightness: Brightness.light,
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'MoneyManager',
          theme: AppTheme.buildTheme(lightScheme, false),
          darkTheme: AppTheme.buildTheme(darkScheme, true),
          themeMode: themeMode,
          home: FutureBuilder(
            future: _initializeApp(ref),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to initialize app',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const MainNavigation();
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Future<void> _initializeApp(WidgetRef ref) async {
    try {
      // Initialize default data
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.initializeDefaultData();
    } catch (e) {
      // Error initializing app: $e
      // Don't rethrow - just log the error and continue
    }
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalysisScreen(),
    AccountsScreen(),
    RecordScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Analysis'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet), label: 'Accounts'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long), label: 'Record'),
        ],
      ),
    );
  }
}
