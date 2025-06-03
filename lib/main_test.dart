import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pas d'initialisation Firebase pour les tests locaux
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    const ProviderScope(
      child: ArgentEnveloppesApp(),
    ),
  );
}

class ArgentEnveloppesApp extends StatelessWidget {
  const ArgentEnveloppesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArgentEnveloppes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Directement sur le dashboard pour les tests
      home: const DashboardPage(),
    );
  }
}
