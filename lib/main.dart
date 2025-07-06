import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mini_app/screens/note_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only check auth state, don't watch for changes
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: isAuthenticated ? const NotesScreen() : const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
