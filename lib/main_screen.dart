import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reworkmobile/view/Relation.dart';
import 'package:reworkmobile/view/home.dart';
import 'package:reworkmobile/view/view_profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final Duration _transitionDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _setupFCMListeners();
  }

  void _setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showSnackbar(
          message.notification!.title ?? 'Notifikasi',
          message.notification!.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📬 App dibuka dari background via notifikasi");
    });
  }

  void _showSnackbar(String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title\n$body'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const RelationsPage();
      case 2:
        return const ProfilePage();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    final offsetAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    return SlideTransition(
      position: offsetAnim,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: _transitionDuration,
        transitionBuilder: _buildTransition,
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _getPage(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        key: const Key('mainBottomNavBar'),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3), // naik bayangannya dari bawah
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF77C29B),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: List.generate(3, (index) {
              final isSelected = index == _selectedIndex;
              final iconData = [
                Icons.home_rounded,
                Icons.handshake_rounded,
                Icons.person_rounded,
              ][index];
              final label = ['Home', 'Relations', 'Profile'][index];

              return BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Transform.translate(
                    offset: Offset(0, isSelected ? -6 : 0),
                    child: Icon(
                      iconData,
                      size: isSelected ? 28 : 24,
                      color: isSelected ? const Color(0xFF77C29B) : Colors.grey,
                    ),
                  ),
                ),
                label: label,
              );
            }),
          ),
        ),
      ),
    );
  }
}
