part of 'master_bloc.dart';

@immutable
sealed class MasterEvent {}

class UpdateMasterProfile extends MasterEvent {
  final MasterProfile masterProfile;

  UpdateMasterProfile({required this.masterProfile});
}

class GetMasterProfile extends MasterEvent {}

class GetServiceTypes extends MasterEvent {}
