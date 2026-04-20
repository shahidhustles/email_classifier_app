import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../config/app_theme.dart';
import 'tabs/home_tab_screen.dart';
import 'tabs/inbox_tab_screen.dart';
import 'tabs/profile_tab_screen.dart';
import 'tabs/settings_tab_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = <String>[
    'Organizer',
    'Inbox',
    'Profile',
    'Settings',
  ];

  static const List<Widget> _tabs = <Widget>[
    HomeTabScreen(),
    InboxTabScreen(),
    ProfileTabScreen(),
    SettingsTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            final bool selected = states.contains(WidgetState.selected);
            return Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.houseSimple),
              selectedIcon: Icon(PhosphorIconsFill.houseSimple),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.envelopeSimple),
              selectedIcon: Icon(PhosphorIconsFill.envelopeSimple),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.userCircle),
              selectedIcon: Icon(PhosphorIconsFill.userCircle),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.gear),
              selectedIcon: Icon(PhosphorIconsFill.gear),
              label: 'Settings',
            ),
          ],
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
