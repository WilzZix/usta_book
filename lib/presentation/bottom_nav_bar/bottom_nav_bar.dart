import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/presentation/clients/clients_list_page.dart';
import 'package:usta_book/presentation/home/home_page.dart';
import 'package:usta_book/presentation/profile/profile_page.dart';

import '../../core/ui_kit/app_theme_extension.dart';
import '../add_new_record/add_new_record_page.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  static final String tag = '/main-home-screen';

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> widgetOptions = [
    const HomePage(),
    const ClientsListPage(),
    AddNewRecordPage(),
    const HomePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: _CustomBottomNavBar(
        items: [
          _NavItem(
            icon: AppIcons.icBottomNavCalendarSelected,
            selectedIcon: AppIcons.icBottomNavCalendarUnselected,
          ),
          _NavItem(
            icon: AppIcons.icCustomersSelected,
            selectedIcon: AppIcons.icCustomersUnselected,
          ),
          _NavItem(
            icon: AppIcons.icAddCustomer,
            selectedIcon: AppIcons.icAddCustomer,
          ),
          _NavItem(
            icon: AppIcons.icMasterStatisticsSelected,
            selectedIcon: AppIcons.icMasterStatisticsUnselected,
          ),
          _NavItem(
            icon: AppIcons.icMasterSettingsSelected,
            selectedIcon: AppIcons.icMasterSettingsUnselected,
          ),
        ],
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}

class _NavItem {
  final Widget icon;
  final Widget selectedIcon;

  _NavItem({required this.icon, required this.selectedIcon});
}

class _CustomBottomNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _CustomBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Get custom colors from our extension
    final customTheme = Theme.of(context).extension<AppThemeExtension>()!;
    // 2. Get standard theme data for background
    final theme = Theme.of(context);

    return Container(
      // Use the background color defined in your Theme factory
      color: theme.bottomNavigationBarTheme.backgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 8,
          top: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final isSelected = selectedIndex == index;

            // 3. Determine the icon color based on selection
            final iconColor = isSelected
                ? customTheme.primary  // Our dynamic accent color
                : theme.bottomNavigationBarTheme.unselectedItemColor;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onItemSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const Duration(milliseconds: 12) == Duration.zero
                    ? const EdgeInsets.all(12)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ColorFiltered(
                  // This allows your static AppIcons to change color dynamically
                  colorFilter: ColorFilter.mode(iconColor!, BlendMode.srcIn),
                  child: isSelected ? items[index].icon : items[index].selectedIcon,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}