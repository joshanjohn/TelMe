import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telme/core/constants/theme.dart';
import 'package:telme/core/providers/providers.dart';
import 'package:telme/router/routes.dart';
import 'package:telme/services/notification_service.dart';

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
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
    if (kIsWeb) {
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  'Initialization Error: $e\nPlease check your internet connection or Supabase configuration.'),
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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ProviderSubscription<AsyncValue<AuthState>>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = ref.listenManual<AsyncValue<AuthState>>(
      authStateProvider,
      (previous, next) {
        final user = next.value?.session?.user;
        final shiftSyncService = ref.read(shiftSyncServiceProvider);
        if (user == null) {
          shiftSyncService.stop();
        } else {
          shiftSyncService.startForUser(user.id);
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _authSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
