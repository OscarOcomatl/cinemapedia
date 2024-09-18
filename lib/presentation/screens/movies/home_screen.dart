
import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/views/views.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {

  static const String name = 'home_screen';
  final int screenIndex;

  const HomeScreen({
    super.key, 
    required this.screenIndex
  });

  final viewRoutes = const <Widget> [
    HomeView(),
    SizedBox(),
    FavoritesView()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: screenIndex,
        children: viewRoutes,
      ),
      bottomNavigationBar: CustomBottomNavigationbar(currentIndex: screenIndex),
    );
  }
}
