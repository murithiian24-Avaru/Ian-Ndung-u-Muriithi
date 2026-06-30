import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/wallet_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/providers/ad_provider.dart';
import 'package:adlease/screens/home/home_screen.dart';
import 'package:adlease/screens/ads/ads_screen.dart';
import 'package:adlease/screens/wallet/wallet_screen.dart';
import 'package:adlease/screens/ownership/ownership_screen.dart';
import 'package:adlease/screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AdsScreen(),
    WalletScreen(),
    OwnershipScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await Future.wait([
        context.read<WalletProvider>().loadWallet(user.uid),
        context.read<OwnershipProvider>().loadOwnership(user.uid),
        context.read<AdProvider>().loadAds(user.uid),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle),
            label: 'Watch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smartphone_outlined),
            activeIcon: Icon(Icons.smartphone),
            label: 'Phone',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
