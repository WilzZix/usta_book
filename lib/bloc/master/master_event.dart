part of 'master_bloc.dart';

@immutable
sealed class MasterEvent {}

class UpdateMasterProfile extends MasterEvent {
  final MasterProfile masterProfile;

  UpdateMasterProfile({required this.masterProfile});
}

class GetMasterProfile extends MasterEvent {}

class GetServiceTypes extends MasterEvent {}

//Add record for client
class AddRecordEvent extends MasterEvent {
  final RecordModel record;

  AddRecordEvent({required this.record});
}
//Update record

class UpdateRecordEvent extends MasterEvent {
  final RecordModel record;

  UpdateRecordEvent({required this.record});
}
