import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_tracker/app/theme/app_theme.dart';
import 'package:portfolio_tracker/features/auth/views/login_view.dart';
import 'package:portfolio_tracker/features/auth/views/register_view.dart';
import 'package:portfolio_tracker/features/shared/layouts/base_layout.dart';
import 'package:portfolio_tracker/features/portfolio/viewmodels/portfolio_viewmodel.dart';
import 'package:portfolio_tracker/data/repositories/portfolio_repository.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PortfolioViewModel(PortfolioRepositoryImpl()),
        ),
      ],
      child: MaterialApp(
        title: 'Portföy Takip',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => _handleAuth(),
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/home': (context) => const BaseLayout(),
        },
      ),
    );
  }

  Widget _handleAuth() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const BaseLayout();
        }
        return const LoginView();
      },
    );
  }
}
