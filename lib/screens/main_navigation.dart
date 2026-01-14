import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../../localization.dart';
import 'discover_screen.dart';
import 'chats_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'create_activity_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DiscoverScreen(),
    ChatsScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  void goToDiscover() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kCard,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: kBlue.withOpacity(0.2),
            labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: Colors.transparent,
            height: 65,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore, color: kBlue),
                label: tr('discover'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline),
                selectedIcon: const Icon(Icons.chat_bubble, color: kBlue),
                label: tr('chats'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.search_outlined),
                selectedIcon: const Icon(Icons.search, color: kBlue),
                label: tr('search'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person, color: kBlue),
                label: tr('profile'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
              ),
              backgroundColor: kBlue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
