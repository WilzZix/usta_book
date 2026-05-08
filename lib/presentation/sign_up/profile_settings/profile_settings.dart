import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/data/models/service_model.dart';

import '../../../core/ui_kit/app_theme_extension.dart';
import '../../bottom_nav_bar/bottom_nav_bar.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  static const String tag = '/profile-settings';

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  static const _dayKeys = ['mon', 'tue', 'wed', 'thurs', 'fri', 'sat', 'sun'];

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final nameController = TextEditingController();
  final serviceTypeController = TextEditingController();
  final beginTimeController = TextEditingController(text: '09:00');
  final endTimeController = TextEditingController(text: '18:00');

  final Map<String, bool> _enabled = {for (final k in _dayKeys) k: true};
  TimeOfDay _begin = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 18, minute: 0);

  File? _photoFile;
  String? _existingPhotoURL;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MasterBloc>(context).add(GetMasterProfile());
  }

  void _hydrate(MasterProfile profile) {
    _profileLoaded = true;
    nameController.text = profile.name;
    serviceTypeController.text = profile.serviceType;
    _existingPhotoURL = profile.photoURL;
    if (profile.workingHours.isNotEmpty) {
      for (final k in _dayKeys) {
        _enabled[k] = profile.workingHours.containsKey(k);
      }
      final firstRange = profile.workingHours.values.first;
      final parts = firstRange.split(' - ');
      if (parts.length == 2) {
        _begin = _parseTime(parts[0]) ?? _begin;
        _end = _parseTime(parts[1]) ?? _end;
        beginTimeController.text = _fmt(_begin);
        endTimeController.text = _fmt(_end);
      }
    }
  }

  TimeOfDay? _parseTime(String s) {
    final parts = s.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  @override
  void dispose() {
    nameController.dispose();
    serviceTypeController.dispose();
    beginTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _dayLabel(BuildContext context, String key) {
    final t = Translations.of(context).sign_up;
    return switch (key) {
      'mon' => t.monday,
      'tue' => t.tuesday,
      'wed' => t.wednesday,
      'thurs' => t.thursday,
      'fri' => t.friday,
      'sat' => t.saturday,
      'sun' => t.sunday,
      _ => key,
    };
  }

  Map<String, String> _buildWorkingHours() {
    final range = '${_fmt(_begin)} - ${_fmt(_end)}';
    return {
      for (final k in _dayKeys)
        if (_enabled[k] == true) k: range,
    };
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _pickBegin() async {
    final picked = await showTimePicker(context: context, initialTime: _begin);
    if (picked == null) return;
    setState(() {
      _begin = picked;
      beginTimeController.text = _fmt(picked);
    });
  }

  Future<void> _pickEnd() async {
    final tr = Translations.of(context);
    final picked = await showTimePicker(context: context, initialTime: _end);
    if (!mounted || picked == null) return;
    final beginMin = _begin.hour * 60 + _begin.minute;
    final pickedMin = picked.hour * 60 + picked.minute;
    if (pickedMin <= beginMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr.sign_up.choose_time),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _end = picked;
      endTimeController.text = _fmt(picked);
    });
  }

  void _showServiceSheet(List<ServiceModel> data) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    showModalBottomSheet(
      context: context,
      backgroundColor: custom.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, index) {
              final s = data[index];
              return ListTile(
                title: Text(
                  s.nameRu,
                  style: Typographies.regularInput.copyWith(color: TextColor.primary),
                ),
                onTap: () {
                  serviceTypeController.text = s.nameRu;
                  Navigator.of(sheetCtx).pop();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() != true) return;
    BlocProvider.of<MasterBloc>(context).add(
      UpdateMasterProfile(
        photoFile: _photoFile,
        masterProfile: MasterProfile(
          name: nameController.text,
          serviceType: serviceTypeController.text,
          workingHours: _buildWorkingHours(),
          profileCompleted: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return Scaffold(
      backgroundColor: custom.body,
      appBar: AppBar(
        backgroundColor: custom.body,
        elevation: 0,
      ),
      body: BlocListener<MasterBloc, MasterState>(
        listener: (context, state) {
          if (state is ServiceTypeLoaded) _showServiceSheet(state.data);
          if (state is MasterProfileLoaded &&
              state.profile != null &&
              !_profileLoaded) {
            setState(() => _hydrate(state.profile!));
          }
          if (state is MasterProfileUpdated) {
            context.read<AuthCubit>().setProfileComplete();
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(MainHomeScreen.tag);
            }
          }
          if (state is MasterProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.msg), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(tr.sign_up.profile_settings_title, style: Typographies.boldH1),
                  const SizedBox(height: 8),
                  Text(tr.sign_up.profile_settings_title_desc, style: Typographies.regularBody),
                  const SizedBox(height: 24),
                  _PhotoCard(
                    photoFile: _photoFile,
                    photoURL: _existingPhotoURL,
                    bg: custom.secondary,
                    placeholderBg: custom.body,
                    label: tr.sign_up.upload_photo,
                    onTap: _pickPhoto,
                  ),
                  const SizedBox(height: 24),
                  _BasicInfoCard(
                    bg: custom.secondary,
                    tr: tr,
                    nameController: nameController,
                    serviceTypeController: serviceTypeController,
                    onServiceTap: () =>
                        BlocProvider.of<MasterBloc>(context).add(GetServiceTypes()),
                  ),
                  const SizedBox(height: 24),
                  _ScheduleCard(
                    bg: custom.secondary,
                    tr: tr,
                    dayKeys: _dayKeys,
                    enabled: _enabled,
                    label: (k) => _dayLabel(context, k),
                    onToggle: (k, v) => setState(() => _enabled[k] = v),
                    beginController: beginTimeController,
                    endController: endTimeController,
                    onPickBegin: _pickBegin,
                    onPickEnd: _pickEnd,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<MasterBloc, MasterState>(
                    builder: (context, state) {
                      return MainButton.primary(
                        isLoading: state is MasterProfileUpdating,
                        title: tr.sign_up.complete_settings,
                        onTap: _submit,
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photoFile,
    required this.photoURL,
    required this.bg,
    required this.placeholderBg,
    required this.label,
    required this.onTap,
  });

  final File? photoFile;
  final String? photoURL;
  final Color bg;
  final Color placeholderBg;
  final String label;
  final VoidCallback onTap;

  ImageProvider? get _image {
    if (photoFile != null) return FileImage(photoFile!);
    if (photoURL != null && photoURL!.isNotEmpty) return NetworkImage(photoURL!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: bg),
        padding: const EdgeInsets.symmetric(vertical: 22.5),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: placeholderBg,
                    backgroundImage: image,
                    child: image == null ? AppIcons.icProfile : null,
                  ),
                  const SizedBox(height: 8),
                  Text(label, style: Typographies.regularBody2),
                ],
              ),
            ),
            Positioned(right: 10, top: 0, child: AppIcons.icCamera),
          ],
        ),
      ),
    );
  }
}

class _BasicInfoCard extends StatelessWidget {
  const _BasicInfoCard({
    required this.bg,
    required this.tr,
    required this.nameController,
    required this.serviceTypeController,
    required this.onServiceTap,
  });

  final Color bg;
  final Translations tr;
  final TextEditingController nameController;
  final TextEditingController serviceTypeController;
  final VoidCallback onServiceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: bg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.sign_up.main_desc),
          const SizedBox(height: 16),
          InputField.text(
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? tr.sign_up.required_field : null,
            hintText: tr.sign_up.enter_full_fio,
            fieldTitle: tr.sign_up.name,
            controller: nameController,
          ),
          const SizedBox(height: 16),
          InputField.selectableInput(
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? tr.sign_up.required_field : null,
            hintText: tr.sign_up.service_type_hint,
            fieldTitle: tr.sign_up.service_type,
            controller: serviceTypeController,
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
            onTap: onServiceTap,
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.bg,
    required this.tr,
    required this.dayKeys,
    required this.enabled,
    required this.label,
    required this.onToggle,
    required this.beginController,
    required this.endController,
    required this.onPickBegin,
    required this.onPickEnd,
  });

  final Color bg;
  final Translations tr;
  final List<String> dayKeys;
  final Map<String, bool> enabled;
  final String Function(String key) label;
  final void Function(String key, bool value) onToggle;
  final TextEditingController beginController;
  final TextEditingController endController;
  final Future<void> Function() onPickBegin;
  final Future<void> Function() onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: bg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.sign_up.work_schedule, style: Typographies.regularH3),
          const SizedBox(height: 16),
          ...dayKeys.map(
            (key) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Text(
                    label(key),
                    style: Typographies.regularBody.copyWith(color: TextColor.secondary),
                  ),
                  const Spacer(),
                  CupertinoSwitch(
                    value: enabled[key] ?? false,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) => onToggle(key, v),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InputField.selectableInput(
                  onTap: onPickBegin,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? tr.sign_up.required_field
                      : null,
                  fieldTitle: tr.sign_up.begin_time,
                  suffixIcon: AppIcons.icWatch,
                  controller: beginController,
                  hintText: '09:00',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InputField.selectableInput(
                  onTap: onPickEnd,
                  hintText: '18:00',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? tr.sign_up.required_field
                      : null,
                  fieldTitle: tr.sign_up.end_time,
                  suffixIcon: AppIcons.icWatch,
                  controller: endController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
