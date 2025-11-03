part of 'master_bloc.dart';

@immutable
sealed class MasterState {}

final class MasterInitial extends MasterState {}

class MasterProfileUpdated extends MasterState {}

class MasterProfileLoaded extends MasterState {
  final MasterProfile? profile;

  MasterProfileLoaded({required this.profile});
}

class MasterProfileLoadError extends MasterState {
  final String msg;

  MasterProfileLoadError({required this.msg});
}

///Service type
class ServiceTypeLoaded extends MasterState {
  final List<ServiceModel> data;

  ServiceTypeLoaded({required this.data});
}

class ServiceTypeLoadFailure extends MasterState {
  final String msg;

  ServiceTypeLoadFailure({required this.msg});
}

//adding record for client
class AddingRecordState extends MasterState {}

class RecordAddedState extends MasterState {}

class AddingRecordFailureState extends MasterState {
  final String msg;

  AddingRecordFailureState({required this.msg});
}
