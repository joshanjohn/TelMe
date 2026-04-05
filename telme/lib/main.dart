import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/foundation.dart';
import 'package:telme/core/constants/theme.dart';
import 'package:telme/router/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  
  try {
    await Supabase.initialize(
      url: 'https://toimnbvqcnapktktjbby.supabase.co',
      anonKey: 'sb_publishable_VhUawyV8qKEWaFGjJZZgJQ_eeQ96Kpm',
    );
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
    if (kIsWeb) {
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Initialization Error: $e\nPlease check your internet connection or Supabase configuration.'),
            ),
          ),
        ),
      ));
      return;
    }
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Tel Me',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
