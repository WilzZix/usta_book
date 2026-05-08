import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/badges/badges_cubit.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/bloc/schedule/schedule_cubit.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/data/models/record_model.dart';
import 'package:usta_book/data/services/notifications/notification_service.dart';
import 'package:usta_book/domain/enums/enums.dart';
import 'package:usta_book/presentation/clients/clients_list_page.dart';
import 'package:usta_book/presentation/home/components/arrival_check_sheet.dart';
import 'package:usta_book/presentation/home/home_page.dart';
import 'package:usta_book/presentation/paywall/paywall_page.dart';
import 'package:usta_book/presentation/paywall/trial_banner.dart';
import 'package:usta_book/presentation/profile/profile_page.dart';
import 'package:usta_book/presentation/statistics/statistics_page.dart';

import '../../core/localization/i18n/strings.g.dart';
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
    const StatisticsPage(),
    const ProfilePage(),
  ];

  Timer? _arrivalTimer;
  StreamSubscription<String>? _tapSub;
  final Set<String> _promptedKeys = {};
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<MasterBloc>().add(GetMasterProfile());
    context.read<ScheduleCubit>().getTodayAppointments(date: DateTime.now());
    context.read<AppointmentBadgesCubit>().refresh();
    _arrivalTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkArrivals(),
    );
    _tapSub = NotificationService.instance.tapStream.listen(_onNotifTap);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkArrivals());
  }

  @override
  void dispose() {
    _arrivalTimer?.cancel();
    _tapSub?.cancel();
    super.dispose();
  }

  String _recordKey(RecordModel r) =>
      '${r.date}_${r.time}_${r.clientNumber}';

  int _recordNotifId(RecordModel r) => _recordKey(r).hashCode & 0x7FFFFFFF;

  DateTime? _parseAt(String date, String time) {
    final d = date.split('/');
    final t = time.split(':');
    if (d.length != 3 || t.length != 2) return null;
    final yy = int.tryParse(d[2]);
    final mm = int.tryParse(d[1]);
    final dd = int.tryParse(d[0]);
    final h = int.tryParse(t[0]);
    final mi = int.tryParse(t[1]);
    if ([yy, mm, dd, h, mi].any((v) => v == null)) return null;
    return DateTime(yy!, mm!, dd!, h!, mi!);
  }

  Future<void> _scheduleAll(List<RecordModel> records) async {
    await NotificationService.instance.cancelAll();
    final tr = Translations.of(context);
    for (final r in records) {
      if (r.status != ClientStatus.waiting) continue;
      final at = _parseAt(r.date, r.time);
      if (at == null) continue;
      await NotificationService.instance.scheduleArrivalCheck(
        id: _recordNotifId(r),
        when: at,
        title: tr.home.arrival_check_title,
        body: '${r.clientName} · ${r.time}',
        payload: _recordKey(r),
      );
    }
  }

  void _checkArrivals() {
    if (!mounted || _sheetOpen) return;
    final state = context.read<ScheduleCubit>().state;
    if (state is! TodayAppointmentLoaded) return;
    if (!_isToday(state.selectedDate)) return;
    final now = DateTime.now();
    for (final r in state.data) {
      if (r.status != ClientStatus.waiting) continue;
      final at = _parseAt(r.date, r.time);
      if (at == null) continue;
      final key = _recordKey(r);
      if (_promptedKeys.contains(key)) continue;
      final lateSeconds = now.difference(at).inSeconds;
      if (lateSeconds >= 0 && lateSeconds < 60 * 60) {
        _promptedKeys.add(key);
        _showSheetFor(r);
        break;
      }
    }
  }

  void _onNotifTap(String payload) {
    if (!mounted) return;
    final state = context.read<ScheduleCubit>().state;
    if (state is! TodayAppointmentLoaded) return;
    for (final r in state.data) {
      if (_recordKey(r) == payload && r.status == ClientStatus.waiting) {
        _showSheetFor(r);
        return;
      }
    }
  }

  Future<void> _showSheetFor(RecordModel record) async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    await NotificationService.instance.cancel(_recordNotifId(record));
    await ArrivalCheckSheet.show(context, record);
    if (mounted) _sheetOpen = false;
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      final masterState = context.read<MasterBloc>().state;
      if (masterState is MasterProfileLoaded &&
          masterState.profile != null &&
          masterState.profile!.subscriptionStatus == SubscriptionStatus.expired) {
        context.pushNamed(PaywallPage.tag);
        return;
      }
      final scheduleState = context.read<ScheduleCubit>().state;
      if (scheduleState is TodayAppointmentLoaded && scheduleState.isPast) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.of(context).home.cant_add_to_past),
          ),
        );
        return;
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ScheduleCubit, ScheduleState>(
            listener: (context, state) {
              if (state is TodayAppointmentLoaded &&
                  _isToday(state.selectedDate)) {
                _scheduleAll(state.data);
                _checkArrivals();
              }
            },
          ),
          BlocListener<MasterBloc, MasterState>(
            listener: (context, state) {
              if (state is RecordAddedState || state is RecordUpdated) {
                context.read<AppointmentBadgesCubit>().refresh();
              }
            },
          ),
        ],
        child: Column(
          children: [
            const TrialBanner(),
            Expanded(child: widgetOptions.elementAt(_selectedIndex)),
          ],
        ),
      ),
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