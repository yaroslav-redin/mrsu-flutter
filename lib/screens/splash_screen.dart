import 'package:flutter/material.dart';
import '../services/network_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Check token and navigate immediately or after a minimal delay
    final networkService = NetworkService();
    final token = await networkService.getToken();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(token != null ? '/home' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a plain background or a simple logo while checking the token
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/logo.png'),
          width: 150,
        ),
      ),
    );
  }
}
