import 'package:flutter/material.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/presentation/clients/clients_list_page.dart';
import 'package:usta_book/presentation/home/home_page.dart';
import 'package:usta_book/presentation/profile/profile_page.dart';

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
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom,
          top: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onItemSelected(index),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    !isSelected ? items[index].selectedIcon : items[index].icon,
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}