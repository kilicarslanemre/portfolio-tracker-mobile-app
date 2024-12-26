import 'package:flutter/material.dart';
import 'package:portfolio_tracker/features/auth/services/auth_service.dart';
import 'package:portfolio_tracker/features/add_asset/views/add_asset_view.dart';
import 'package:portfolio_tracker/features/portfolio/views/portfolio_view.dart';
import 'package:portfolio_tracker/app/theme/app_theme.dart';

class BaseLayout extends StatefulWidget {
  const BaseLayout({super.key});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  int _selectedIndex = 0;
  final _authService = AuthService();

  final List<Widget> _pages = const [
    PortfolioView(),
    AddAssetView(),
  ];

  final List<String> _titles = [
    'Portföyüm',
    'Varlık Ekle',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppTheme.textSecondary,
            ),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Portföyüm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Varlık Ekle',
          ),
        ],
      ),
    );
  }
}
