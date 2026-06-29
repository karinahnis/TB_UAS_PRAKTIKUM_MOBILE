import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/auth/login_page.dart';
import 'pages/home/home_page.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/order_provider.dart';
import 'providers/ticket_provider.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'services/order_service.dart';
import 'services/ticket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs: prefs);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService),
        ),
        Provider(create: (_) => EventService()),
        ChangeNotifierProvider(
          create: (_) => EventProvider(eventService: EventService()),
        ),
        Provider(create: (_) => OrderService()),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderService: OrderService()),
        ),
        Provider(create: (_) => TicketService()),
        ChangeNotifierProvider(
          create: (_) => TicketProvider(ticketService: TicketService()),
        ),
      ],
      child: MaterialApp(
        title: 'Ticketing App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/splash': (context) => const SplashScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.checkLoginStatus();

    if (!mounted) return;

    if (auth.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
