import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/supabase_auth_provider.dart';
import 'providers/assessment_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                SupabaseAuthProvider()), // ✅ Using SupabaseAuthProvider
        ChangeNotifierProvider(create: (_) => AssessmentServiceProvider()),
      ],
      child: MaterialApp(
        title: 'KIRAN',
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
