import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holt_dog/core/widgets/app_drawer.dart';
import 'package:holt_dog/features/auth/cubit/auth_cubit.dart';
import 'package:holt_dog/features/auth/cubit/auth_state.dart';
import 'package:holt_dog/features/auth/models/user_model.dart';
import 'package:holt_dog/features/charity_side/screens/marketplace_screen.dart';
import 'package:holt_dog/features/retailer_side/screens/retailer_orders_screen.dart';
import '../widgets/retailer_nav_bar.dart';

class RetailerHomeScreen extends StatefulWidget {
  static const String routeName = '/retailerHome';
  const RetailerHomeScreen({super.key});

  @override
  State<RetailerHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<RetailerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MarketplaceScreen(),
    const RetailerOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final UserModel? user = state is Authenticated ? state.user : null;

    return Scaffold(
      drawer: user != null ? AppDrawer(user: user) : const Drawer(),
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: RetailerNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

