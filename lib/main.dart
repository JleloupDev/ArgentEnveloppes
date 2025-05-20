import 'package:argentenveloppes/firebase_options.dart';
import 'package:argentenveloppes/presentation/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes(),
    );
  }
}